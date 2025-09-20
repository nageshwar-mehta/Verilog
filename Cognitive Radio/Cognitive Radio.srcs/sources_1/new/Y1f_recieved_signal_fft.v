`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2025 05:51:14
// Design Name: 
// Module Name: Y1f_recieved_signal_fft
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

// ----NOTE---- 
//h : time domain 
//H : frequency domain
//----------------------
module Y1f_recieved_signal_fft (
    input  aclk,
    input  aresetn,
    // Inputs: s(n), h(n), w(n)
    input  [15:0] s_re, s_im,
    input  [15:0] h_re, h_im,
    input  [15:0] w_re, w_im,
    input         in_valid, in_last,
    output        in_ready,
    // Output: Y1(f)
    output [15:0] Y_re, Y_im,
    output        Y_valid, Y_last
);

    wire [15:0] S_re, S_im;
    wire [15:0] H_re, H_im;
    wire [15:0] W_re, W_im;
    wire        S_valid, H_valid, W_valid;
    wire        S_last, H_last, W_last;

    // FFT instances
    FFT64pt_wrapper fft_s (
        .aclk(aclk), .aresetn(aresetn),
        .in_data_real(s_re), .in_data_imag(s_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(),
        //config_data = 1 for fft calculation and 0 for IFFT calculation
        .config_data(8'd1), .config_valid(1'b1), .config_ready(),
        .out_data_real(S_re), .out_data_imag(S_im),
        .out_valid(S_valid), .out_last(S_last), .out_ready(1'b1)
    );

    FFT64pt_wrapper fft_h (
        .aclk(aclk), .aresetn(aresetn),
        .in_data_real(h_re), .in_data_imag(h_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(),
        //config_data = 1 for fft calculation and 0 for IFFT calculation
        .config_data(8'd1), .config_valid(1'b1), .config_ready(),
        .out_data_real(H_re), .out_data_imag(H_im),
        .out_valid(H_valid), .out_last(H_last), .out_ready(1'b1)
    );

    FFT64pt_wrapper fft_w (
        .aclk(aclk), .aresetn(aresetn),
        .in_data_real(w_re), .in_data_imag(w_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(),
        //config_data = 1 for fft calculation and 0 for IFFT calculation
        .config_data(8'd1), .config_valid(1'b1), .config_ready(),
        .out_data_real(W_re), .out_data_imag(W_im),
        .out_valid(W_valid), .out_last(W_last), .out_ready(1'b1)
    );

    // Multiply S(f)*H(f)
    wire [15:0] SH_re, SH_im;
    complex_multiplier mult_u (
        .a_re(S_re), .a_im(S_im),
        .b_re(H_re), .b_im(H_im),
        .p_re(SH_re), .p_im(SH_im)
    );

    // Add W(f)
    complex_adder add_u (
        .a_re(SH_re), .a_im(SH_im),
        .b_re(W_re),  .b_im(W_im),
        .x_re(Y_re),  .x_im(Y_im)
    );

    // Control signals (simplified: assume all FFTs aligned)
    assign Y_valid = S_valid & H_valid & W_valid;
    assign Y_last  = S_last;

endmodule

