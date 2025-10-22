// cordic_pipeline_pair.v
// Pipelined/unfolded CORDIC vectoring that rotates (x,y) (denominator) towards real axis
// and applies identical micro-rotations to (xn,yn) (numerator).
`timescale 1ns/1ps
module cordic_pipeline_pair #(
    parameter integer WL = 32,
    parameter integer FL = 16,
    parameter integer ITERS = 31
)(
    input  wire                 clk,
    input  wire                 rstn,
    input  wire                 validIn,
    input  wire signed [WL-1:0] x_in,   // denom_re
    input  wire signed [WL-1:0] y_in,   // denom_im
    input  wire signed [WL-1:0] xn_in,  // num_re
    input  wire signed [WL-1:0] yn_in,  // num_im
    output wire signed [WL-1:0] x_out,  // denom_real_rot
    output wire signed [WL-1:0] y_out,  // should be ~0
    output wire signed [WL-1:0] xn_out, // num_re_rot
    output wire signed [WL-1:0] yn_out, // num_im_rot
    output wire                 validOut
);

    reg signed [WL-1:0] xreg [0:ITERS];
    reg signed [WL-1:0] yreg [0:ITERS];
    reg signed [WL-1:0] xnreg[0:ITERS];
    reg signed [WL-1:0] ynreg[0:ITERS];
    reg vreg[0:ITERS];

    reg signed [WL-1:0] atan_table [0:ITERS-1];

    integer i;
    real aval;
    initial begin
        for (i=0;i<ITERS;i=i+1) begin
            aval = $atan(2.0**(-i));
            atan_table[i] = $rtoi(aval * (2.0**FL));
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<=ITERS;i=i+1) begin
                xreg[i] <= 0;
                yreg[i] <= 0;
                xnreg[i] <= 0;
                ynreg[i] <= 0;
                vreg[i] <= 1'b0;
            end
        end else begin
            xreg[0] <= x_in;
            yreg[0] <= y_in;
            xnreg[0] <= xn_in;
            ynreg[0] <= yn_in;
            vreg[0] <= validIn;
            for (i=0;i<ITERS;i=i+1) begin
                // vectoring mode sigma = -sign(yreg[i])
                if (yreg[i][WL-1] == 1'b1) begin
                    // y < 0 -> sigma = +1
                    xreg[i+1] <= xreg[i] - (yreg[i] >>> i);
                    yreg[i+1] <= yreg[i] + (xreg[i] >>> i);
                    xnreg[i+1] <= xnreg[i] - (ynreg[i] >>> i);
                    ynreg[i+1] <= ynreg[i] + (xnreg[i] >>> i);
                    // z not stored (not needed for division)
                end else begin
                    // sigma = -1
                    xreg[i+1] <= xreg[i] + (yreg[i] >>> i);
                    yreg[i+1] <= yreg[i] - (xreg[i] >>> i);
                    xnreg[i+1] <= xnreg[i] + (ynreg[i] >>> i);
                    ynreg[i+1] <= ynreg[i] - (xnreg[i] >>> i);
                end
                vreg[i+1] <= vreg[i];
            end
        end
    end

    assign x_out = xreg[ITERS];
    assign y_out = yreg[ITERS];
    assign xn_out = xnreg[ITERS];
    assign yn_out = ynreg[ITERS];
    assign validOut = vreg[ITERS];

endmodule
