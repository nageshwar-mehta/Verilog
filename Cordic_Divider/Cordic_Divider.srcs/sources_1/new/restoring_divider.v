// restoring_divider.v
// Signed restoring iterative divider for fixed-point numbers.
// Compute quotient = a / b assuming fixed point Q with FL fractional bits.
// Implementation uses non-restoring style with left-shift of remainder approach.
// start pulse triggers a new division; done asserted for one cycle when complete.

`timescale 1ns/1ps
module restoring_divider #(
    parameter integer WL = 32,
    parameter integer FL = 16
)(
    input  wire                clk,
    input  wire                rstn,
    input  wire                start,     // start one division
    input  wire signed [WL-1:0] a,        // dividend (numerator_rot)
    input  wire signed [WL-1:0] b,        // divisor (den_rot) must be non-zero
    output reg  signed [WL-1:0] quotient,
    output reg                 done
);

    // We'll convert to unsigned magnitude approach with sign handling:
    reg [WL-1:0] abs_a, abs_b;
    reg sign_q;

    // internal remainder and quotient registers (extend remainder width by 1+WL to keep shifts)
    reg [(WL*2)-1:0] rem;  // extended to accomodate shifts
    reg [WL-1:0] q_reg;
    reg [6:0] cnt;         // up to WL cycles, log2(WL) bits (here 7 bits enough up to 128)
    reg running;

    // compute absolute values and sign
    wire a_sign = a[WL-1];
    wire b_sign = b[WL-1];

    wire [WL-1:0] a_mag = a_sign ? (~a + 1) : a;
    wire [WL-1:0] b_mag = b_sign ? (~b + 1) : b;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            quotient <= 0; done <= 0;
            abs_a <= 0; abs_b <= 0; sign_q <= 0;
            rem <= 0; q_reg <= 0; cnt <= 0; running <= 0;
        end else begin
            done <= 1'b0; // default
            if (start && !running) begin
                // load values and start
                abs_a <= a_mag;
                abs_b <= b_mag;
                sign_q <= a_sign ^ b_sign;
                // initialize remainder: shift left by FL to account for fractional division
                // we want quotient = (a / b); if inputs are fixed point, we perform:
                //   (a << FL) / b  to keep FL fractional bits in quotient
                rem <= { {WL{1'b0}}, a_mag } << FL; // rem width 2*WL
                q_reg <= 0;
                cnt <= WL; // produce WL bits
                running <= 1'b1;
            end else if (running) begin
                if (cnt > 0) begin
                    // shift left rem by 1 (implicitly already prepared by subtracting)
                    rem <= (rem << 1);
                    // trial subtract
                    if (rem[(WL*2)-1 -: WL] >= abs_b) begin
                        // top WL bits (msb part) >= divisor -> subtract and set quotient bit
                        rem[(WL*2)-1 -: WL] <= rem[(WL*2)-1 -: WL] - abs_b;
                        q_reg <= {q_reg[WL-2:0], 1'b1};
                    end else begin
                        q_reg <= {q_reg[WL-2:0], 1'b0};
                    end
                    cnt <= cnt - 1;
                end else begin
                    // Finish
                    running <= 1'b0;
                    // apply sign to quotient
                    if (sign_q) quotient <= -$signed(q_reg); else quotient <= $signed(q_reg);
                    done <= 1'b1;
                end
            end
        end
    end

endmodule
