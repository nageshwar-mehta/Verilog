// ============================================================================
// File Name: complex_divide_pipelined.v
// Description: High-throughput pipelined complex divider using unfolded CORDIC
// Author: Nageshwar Kumar (IIT Jammu) - assisted design
// ============================================================================

`timescale 1ns / 1ps

module complex_divide_pipelined #(
    parameter WL = 32,       // Word length
    parameter FL = 16,       // Fractional bits
    parameter ITERS = 31     // CORDIC iterations (pipeline stages)
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     validIn,
    input  wire signed [WL-1:0]     num_re,
    input  wire signed [WL-1:0]     num_im,
    input  wire signed [WL-1:0]     den_re,
    input  wire signed [WL-1:0]     den_im,
    output reg  signed [WL-1:0]     out_re,
    output reg  signed [WL-1:0]     out_im,
    output reg                      dbz,       // Divide-by-zero flag
    output reg                      validOut
);

    // =====================================================================
    // Stage 1: Pipelined CORDIC Pair (Vectoring Mode)
    // Rotates denominator to real axis and applies same rotation to numerator
    // =====================================================================
    wire signed [WL-1:0] den_re_rot, den_im_rot;
    wire signed [WL-1:0] num_re_rot, num_im_rot;
    wire cordic_valid;

    cordic_pipeline_pair #(.WL(WL), .FL(FL), .ITERS(ITERS)) CORDIC_PAIR (
        .clk(clk),
        .rstn(rstn),
        .validIn(validIn),
        .x_in(den_re),
        .y_in(den_im),
        .xn_in(num_re),
        .yn_in(num_im),
        .x_out(den_re_rot),
        .y_out(den_im_rot),
        .xn_out(num_re_rot),
        .yn_out(num_im_rot),
        .validOut(cordic_valid)
    );

    // Divide-by-zero detection
    wire den_zero = (den_re_rot == 0);

    // =====================================================================
    // Stage 2: Fixed-Point Restoring Dividers (for real and imaginary parts)
    // =====================================================================
    wire signed [WL-1:0] quot_re, quot_im;
    wire div_done_re, div_done_im;
    wire start_div = cordic_valid && !den_zero;

    restoring_divider #(.WL(WL), .FL(FL)) DIV_RE (
        .clk(clk),
        .rstn(rstn),
        .start(start_div),
        .a(num_re_rot),
        .b(den_re_rot),
        .quotient(quot_re),
        .done(div_done_re)
    );

    restoring_divider #(.WL(WL), .FL(FL)) DIV_IM (
        .clk(clk),
        .rstn(rstn),
        .start(start_div),
        .a(num_im_rot),
        .b(den_re_rot),
        .quotient(quot_im),
        .done(div_done_im)
    );

    // =====================================================================
    // Stage 3: Output Latching
    // =====================================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_re    <= 0;
            out_im    <= 0;
            dbz       <= 0;
            validOut  <= 0;
        end else begin
            validOut <= 0;  // default

            if (cordic_valid && den_zero) begin
                // Divide-by-zero condition
                out_re   <= 0;
                out_im   <= 0;
                dbz      <= 1'b1;
                validOut <= 1'b1;

            end else if (div_done_re) begin
                // Normal operation
                out_re   <= quot_re;
                out_im   <= quot_im;
                dbz      <= 1'b0;
                validOut <= 1'b1;
            end
        end
    end

endmodule
