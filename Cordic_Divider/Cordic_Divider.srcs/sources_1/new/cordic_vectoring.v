// cordic_vectoring.v
// Pipelined CORDIC vectoring (circular) - signed fixed point
// Basic version: uses iterative shift-add operations, pipeline register per iteration.
// WARNING: For clarity this implementation is straightforward; vendor-specific optimizations (block RAM, DSP) can be added.

`timescale 1ns/1ps
module cordic_vectoring #(
    parameter integer WL = 32,
    parameter integer FL = 16,
    parameter integer ITERS = 31
)(
    input  wire                clk,
    input  wire                rstn,
    input  wire                validIn,
    input  wire signed [WL-1:0] x_in, // denom_re
    input  wire signed [WL-1:0] y_in, // denom_im
    input  wire signed [WL-1:0] x_num_in, // num_re
    input  wire signed [WL-1:0] y_num_in, // num_im
    output wire signed [WL-1:0] x_out, // rotated denom real (scaled by K)
    output wire                unused_y_out,
    output wire signed [WL-1:0] x_num_out,
    output wire signed [WL-1:0] y_num_out,
    output wire                validOut
);

    // precompute sign shifting indices 0..ITERS-1

    // We build pipeline arrays for x,y and numerator counterparts.
    // For simplicity, we use arrays of regs sized [0:ITERS]
    // Start registers: stage 0 is input.

    localparam integer STAGES = ITERS + 1;

    reg signed [WL-1:0] x_reg [0:STAGES-1];
    reg signed [WL-1:0] y_reg [0:STAGES-1];
    reg signed [WL-1:0] xn_reg[0:STAGES-1];
    reg signed [WL-1:0] yn_reg[0:STAGES-1];
    reg valid_reg [0:STAGES-1];

    integer i;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<STAGES;i=i+1) begin
                x_reg[i] <= 0;
                y_reg[i] <= 0;
                xn_reg[i] <= 0;
                yn_reg[i] <= 0;
                valid_reg[i] <= 1'b0;
            end
        end else begin
            // stage 0 load
            x_reg[0] <= x_in;
            y_reg[0] <= y_in;
            xn_reg[0] <= x_num_in;
            yn_reg[0] <= y_num_in;
            valid_reg[0] <= validIn;

            // iterative stages
            for (i=0;i<ITERS;i=i+1) begin
                // decide rotation direction based on sign of y (vectoring)
                if (y_reg[i] >= 0) begin
                    // rotate + => x' = x + (y>>>i) ; y' = y - (x>>>i)
                    x_reg[i+1] <= x_reg[i] + (y_reg[i] >>> i);
                    y_reg[i+1] <= y_reg[i] - (x_reg[i] >>> i);
                    // apply same rotation to numerator
                    xn_reg[i+1] <= xn_reg[i] + (yn_reg[i] >>> i);
                    yn_reg[i+1] <= yn_reg[i] - (xn_reg[i] >>> i);
                    valid_reg[i+1] <= valid_reg[i];
                end else begin
                    // rotate - => x' = x - (y>>>i) ; y' = y + (x>>>i)
                    x_reg[i+1] <= x_reg[i] - (y_reg[i] >>> i);
                    y_reg[i+1] <= y_reg[i] + (x_reg[i] >>> i);
                    xn_reg[i+1] <= xn_reg[i] - (yn_reg[i] >>> i);
                    yn_reg[i+1] <= yn_reg[i] + (xn_reg[i] >>> i);
                    valid_reg[i+1] <= valid_reg[i];
                end
            end
        end
    end

    assign x_out = x_reg[ITERS];   // denom real (scaled)
    assign unused_y_out = (y_reg[ITERS] != 0); // mostly zero
    assign x_num_out = xn_reg[ITERS];
    assign y_num_out = yn_reg[ITERS];
    assign validOut = valid_reg[ITERS];

endmodule
