`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2025 02:54:10
// Design Name: 
// Module Name: fft_divider_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fft_divider_top#(parameter N = 16,
                        parameter Q = 9)(
    input  wire clk, rstn, start,
    input  wire signed [N-1:0] in_a_real,
    input  wire signed [N-1:0] in_a_imag,
    input  wire signed [N-1:0] in_b_real,
    input  wire signed [N-1:0] in_b_imag,
    input  wire in_valid,
    output wire signed [N-1:0] div_out_real,
    output wire signed [N-1:0] div_out_imag,
    output wire div_out_valid,
    output wire out_last
    );
    
    
    // ===================== 64 point FFT Modules ======================
    wire fft_a_valid, fft_b_valid;
    wire out_last_a, out_last_b;
    wire signed [N-1:0] fft_a_re, fft_a_im;
    wire signed [N-1:0] fft_b_re, fft_b_im;
    
    FFT64pt fft_A (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .in_real(in_a_real),
        .in_imag(in_a_imag),
        .out_valid(fft_a_valid),
        .out_real(fft_a_re),
        .out_imag(fft_a_im),
        .out_last(out_last_a)
    );
    FFT64pt fft_B (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .in_real(in_b_real),
        .in_imag(in_b_imag),
        .out_valid(fft_b_valid),
        .out_real(fft_b_re),
        .out_imag(fft_b_im),
        .out_last(out_last_b)
    );
    // ===================== FIFO Buffers ======================
    wire fifo_a_empty, fifo_b_empty;
    wire fifo_a_full, fifo_b_full;
    wire signed [N-1:0] a_re_out, a_im_out, b_re_out, b_im_out;
    reg r_en;

    // Separate FIFOs for real and imag parts of each FFT
    //-------------------------------------A+iB------------------------------------------------
    Synchronous_FIFO #(.width(N), .depth(64)) fifo_a_re (
        .clk(clk), .rst(rstn),
        .data_in(fft_a_re),
        .w_in(fft_a_valid),
        .r_in(r_en),
        .data_out(a_re_out),
        .fifo_empty(fifo_a_re_empty),
        .fifo_full(fifo_a_re_full)
    );
     Synchronous_FIFO #(.width(N), .depth(64)) fifo_a_im (
        .clk(clk), .rst(rstn),
        .data_in(fft_a_im),
        .w_in(fft_a_valid),
        .r_in(r_en),
        .data_out(a_im_out),
        .fifo_empty(fifo_a_im_empty),
        .fifo_full(fifo_a_im_full)
    );
    
    //------------------------------------------------------------------------------------------------
    //-------------------------------------C+iD-------------------------------------------------------
    Synchronous_FIFO #(.width(N), .depth(64)) fifo_b_re (
        .clk(clk), .rst(rstn),
        .data_in(fft_b_re),
        .w_in(fft_b_valid),
        .r_in(r_en),
        .data_out(b_re_out),
        .fifo_empty(fifo_b_re_empty),
        .fifo_full(fifo_b_re_full)
    );

    Synchronous_FIFO #(.width(N), .depth(64)) fifo_b_im (
        .clk(clk), .rst(rstn),
        .data_in(fft_b_im),
        .w_in(fft_b_valid),
        .r_in(r_en),
        .data_out(b_im_out),
        .fifo_empty(fifo_b_im_empty),
        .fifo_full(fifo_b_im_full)
    );
    //------------------------------------------------------------------------------------------------
    
    // ===================== Divider ===========================
    wire busy, valid;
    complex_divider_s #(.Q(Q), .N(N)) u_divider (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_start(start_div),
        .a_re(a_re_out),
        .a_im(a_im_out),
        .b_re(b_re_out),
        .b_im(b_im_out),
        .o_re(div_out_real),
        .o_im(div_out_imag),
        .o_valid(valid),
        .o_busy(busy)
    );
    
endmodule
