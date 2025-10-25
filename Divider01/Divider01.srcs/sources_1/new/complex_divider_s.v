`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar
// Date:      25 Oct 2025
// Design:    Parallel Complex Signed Fixed-Point Divider (Qm.n)
// Description:
//   Performs (a + jb) / (c + jd) using two q_div_wrapper_us instances.
//   Both real and imaginary parts divided in parallel.
//   Output valid asserted once both divisions complete.
////////////////////////////////////////////////////////////////////////////////

module complex_divider_s #(
    parameter integer Q = 9,   // fractional bits
    parameter integer N = 16   // total bits
)(
    input  wire              i_clk,
    input  wire              i_rstn,
    input  wire              i_start,          // start division
    input  wire signed [N-1:0] a_re, a_im,     // numerator: A + jB
    input  wire signed [N-1:0] b_re, b_im,     // denominator: C + jD
    output reg  signed [N-1:0] o_re, o_im,     // output: result real/imag
    output reg               o_valid,          // final result valid
    output reg               o_busy            // high while dividing
);

    // Step 1: Intermediate fixed-point products
    wire signed [2*N-1:0] AC = a_re * b_re;
    wire signed [2*N-1:0] BD = a_im * b_im;
    wire signed [2*N-1:0] BC = a_im * b_re;
    wire signed [2*N-1:0] AD = a_re * b_im;
    wire signed [2*N-1:0] C2 = b_re * b_re;
    wire signed [2*N-1:0] D2 = b_im * b_im;

    // Step 2: Scale back to Q format
    wire signed [N-1:0] num_real = (AC + BD) >>> Q;  // (AC + BD)
    wire signed [N-1:0] num_imag = (BC - AD) >>> Q;  // (BC - AD)
    wire signed [N-1:0] denom    = (C2 + D2) >>> Q;  // (C^2 + D^2)

    // Step 3: Parallel signed dividers
    wire [N-1:0] quot_re, quot_im;
    wire done_re, done_im;
    wire ovf_re, ovf_im;
    reg  start_div_re, start_div_im;
//----------------------------------------------------//
             //Division of Real part//
//----------------------------------------------------//
    q_div_wrapper_us #(.Q(Q), .N(N)) u_div_real (
        .i_dividend_s(num_real),
        .i_divisor_s(denom),
        .i_start(start_div_re),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .o_quotient_out_s(quot_re),
        .o_complete(done_re),
        .o_overflow(ovf_re)
    );
//----------------------------------------------------//
             //Division of Inaginary part//
//----------------------------------------------------//
    q_div_wrapper_us #(.Q(Q), .N(N)) u_div_imag (
        .i_dividend_s(num_imag),
        .i_divisor_s(denom),
        .i_start(start_div_im),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .o_quotient_out_s(quot_im),
        .o_complete(done_im),
        .o_overflow(ovf_im)
    );

    // Step 4: Parallel control FSM
    localparam IDLE = 1'b0;
    localparam BUSY = 1'b1;
    reg state;

    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            state <= IDLE;
            start_div_re <= 0;
            start_div_im <= 0;
            o_busy <= 0;
            o_valid <= 0;
            o_re <= 0;
            o_im <= 0;
        end else begin
            start_div_re <= 0;
            start_div_im <= 0;
            o_valid <= 0;

            case (state)
                IDLE: if (i_start) begin
                    start_div_re <= 1'b1;
                    start_div_im <= 1'b1;
                    o_busy <= 1'b1;
                    state <= BUSY;
                end

                BUSY: if (done_re && done_im) begin
                    o_re <= quot_re;
                    o_im <= quot_im;
                    o_valid <= 1'b1;
                    o_busy <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
