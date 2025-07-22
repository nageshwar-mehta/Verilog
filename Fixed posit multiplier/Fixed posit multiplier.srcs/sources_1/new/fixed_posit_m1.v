`timescale 1ns / 1ps
// (32,6,2,23) => (bit width, exp width, regime bits, fraction bits)

module fixed_posit_m1(
    sa, ra, ea, fa,
    sb, rb, eb, fb,
    sc, rc, ec, fc
);

// Input ports
input sa, sb;
input [5:0] ea, eb;
input [1:0] ra, rb;
input [22:0] fa, fb;

// Output ports
output sc;
output [1:0] rc;
output [5:0] ec;
output [22:0] fc;

// Internal wires
wire signed [1:0] ka, kb, kc; // Decoded regime values [-2, 1]
wire signed [8:0] ka_scaled, kb_scaled; // ka*64, kb*64 (useed simplification)
wire carry; // Carry from fraction multiplication
wire signed [11:0] posit_sum; // Sufficient for 64*2 + 63 + 63 + 1 = 255

// Sign calculation for product
assign sc = sa ^ sb;

// Decode regime values
decode d1(ra, ka);
decode d2(rb, kb);

// Scale regimes with es=6: use ka*64 and kb*64 instead of ka<<<6
assign ka_scaled = ka * 9'sd64;
assign kb_scaled = kb * 9'sd64;

// Fraction multiplication
frac_mult f1(fa, fb, fc, carry);

// Posit exponent + regime calculation:
// posit_sum = ka*64 + kb*64 + ea + eb + carry
assign posit_sum = ka_scaled + kb_scaled + $signed({1'b0, ea}) + $signed({1'b0, eb}) + carry;

// Extract kc (regime) and ec (exponent)
assign kc = posit_sum / 64;      // Equivalent to floor(posit_sum / 64)
assign ec = posit_sum % 64;      // Equivalent to posit_sum mod 64

// Encode kc back to rc
encode e1(kc, rc);

endmodule

//================== Regime Decoder ==================
module decode(r, k);
input [1:0] r;
output reg signed [1:0] k;
always @(*) begin
    case (r)
        2'b00: k = -2; // -2
        2'b01: k = -1; // -1
        2'b10: k =  0; // 0
        2'b11: k =  1; // 1
        default: k = 0;
    endcase
end
endmodule

//================== Regime Encoder ==================
module encode(kc, rc);
input signed [1:0] kc;
output reg [1:0] rc;
always @(*) begin
    case (kc)
        -2: rc = 2'b00;
        -1: rc = 2'b01;
         0: rc = 2'b10;
         1: rc = 2'b11;
        default: rc = 2'b00;
    endcase
end
endmodule

//================== Fraction Multiplication ==================
module frac_mult(fa, fb, fc, carry);
input [22:0] fa, fb;
output reg [22:0] fc;
output reg carry;

reg [23:0] fa_ext, fb_ext;       // Extended fraction with implicit 1
reg [47:0] product_full, product_norm;

always @(*) begin
    // Append implicit 1: (1 + fa) and (1 + fb)
    fa_ext = {1'b1, fa};
    fb_ext = {1'b1, fb};

    // Multiply fractions
    product_full = fa_ext * fb_ext; // 24 x 24 = 48 bits

    // Normalization:
    // If MSB = 1, shift right by 1 (divide by 2), set carry = 1
    // Else pass as is, carry = 0
    if (product_full[47]) begin
        product_norm = product_full >> 1;
        carry = 1'b1;
    end else begin
        product_norm = product_full;
        carry = 1'b0;
    end

    // Extract normalized fraction bits: take bits [45:23] for fc
    fc = product_norm[45:23];
end
endmodule
