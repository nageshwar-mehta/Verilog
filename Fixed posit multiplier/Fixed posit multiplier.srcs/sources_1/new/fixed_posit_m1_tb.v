`timescale 1ns / 1ps

module fixed_posit_m1_tb;

// Inputs
reg sa, sb;
reg [5:0] ea, eb;
reg [1:0] ra, rb;
reg [22:0] fa, fb;

// Outputs
wire sc;
wire [5:0] ec;
wire [1:0] rc;
wire [22:0] fc;

// Instantiate the DUT
fixed_posit_m1 dut (
    .sa(sa), .sb(sb),
    .ea(ea), .eb(eb),
    .ra(ra), .rb(rb),
    .fa(fa), .fb(fb),
    .sc(sc), .rc(rc), .ec(ec), .fc(fc)
);

// Decode function for testbench
function signed [31:0] decode_regime;
    input [1:0] r;
    begin
        case (r)
            2'b00: decode_regime = -2;
            2'b01: decode_regime = -1;
            2'b10: decode_regime = 0;
            2'b11: decode_regime = 1;
            default: decode_regime = 0;
        endcase
    end
endfunction

// Calculate posit value as real
function real compute_value;
    input sa_local;
    input [1:0] ra_local;
    input [5:0] ea_local;
    input [22:0] fa_local;
    real regime, exponent, fraction, result;
    begin
        regime = 2.0 ** (64.0 * decode_regime(ra_local));
        exponent = 2.0 ** ea_local;
        fraction = 1.0 + (fa_local / (2.0 ** 23));
        result = regime * exponent * fraction;
        if (sa_local)
            result = -result;
        compute_value = result;
    end
endfunction

integer i, j, k, l;
real expected, actual, rel_error;

initial begin
    $display("Time | sa sb ra rb ea eb fa fb || sc rc ec fc || Expected || Actual || RelError %%");
    
    // Systematic test sweep over sa, sb, ra, rb with fixed ea, eb, fa, fb
    for (i = 0; i < 2; i = i + 1) begin
        for (j = 0; j < 2; j = j + 1) begin
            for (k = 0; k < 4; k = k + 1) begin
                for (l = 0; l < 4; l = l + 1) begin
                    sa = i;
                    sb = j;
                    ra = k;
                    rb = l;
                    ea = 6'd1;
                    eb = 6'd2;
                    fa = 23'd0;
                    fb = 23'd0;
                    #20;

                    expected = compute_value(sa, ra, ea, fa) * compute_value(sb, rb, eb, fb);
                    actual = compute_value(sc, rc, ec, fc);

                    if (expected != 0)
                        rel_error = ((actual - expected) / expected) * 100.0;
                    else
                        rel_error = actual == 0 ? 0 : 100;

                    $display("%0t | %b %b %b %b %d %d %h %h || %b %b %d %h || %.10e || %.10e || %.6f%%",
                        $time, sa, sb, ra, rb, ea, eb, fa, fb, sc, rc, ec, fc, expected, actual, rel_error);
                end
            end
        end
    end
    $finish;
end

endmodule
