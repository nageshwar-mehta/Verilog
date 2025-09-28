`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar
// 
// Create Date: 20.09.2025
// Module Name: Hs1_cap
// Description: Computes Hs1_cap(f) = Y1(f) / S(f)
//              Uses FFT64pt_wrapper, Y1f_recieved_signal_fft, complex_divider
//////////////////////////////////////////////////////////////////////////////////

module Hs1_cap (
    input  aclk,
    input  aresetn,

    // Time-domain inputs
    input signed [15:0] s_re, s_im,   // s(n)
    input signed [15:0] h_re, h_im,   // h(n)
    input signed [15:0] w_re, w_im,   // w(n)
    input         in_valid,
    input         in_last,
    output        in_ready,

    // Config for FFT
    input  [7:0]  config_data,
    input         config_valid,
    output        config_ready,

    // Output: Hs1_cap(f)
    output signed [15:0] Hs1_re,
    output signed [15:0] Hs1_im,
    output        Hs1_valid,
    output        Hs1_last
);

    
    wire signed [15:0] Y_re, Y_im;
    wire        Y_valid, Y_last;
    wire in_ready_y1, config_ready_y1;
   
    // Step 1: Compute Y1(f) using provided module
    Y1f_recieved_signal_fft y1_block (
        .aclk(aclk),
        .aresetn(aresetn),

        // Time-domain inputs
        .s_re(s_re), .s_im(s_im),
        .h_re(h_re), .h_im(h_im),
        .w_re(w_re), .w_im(w_im),
        .in_valid(in_valid),
        .in_last(in_last),
        .in_ready(in_ready_y1),

        // Output Y1(f)
        .Y_re(Y_re), .Y_im(Y_im),
        .Y_valid(Y_valid), .Y_last(Y_last),

        // Config
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready_y1)
    );

    // To get S(f), we need another FFT64pt_wrapper instance 
    // (since Y1f_recieved_signal_fft only outputs Y1(f) ----> optimization : generate S(f) as output from Y1f_recieved_signal_fft : will be done in final optimization ).
    // -------------------------------------------------------------------------
    
    // Step 2: Calculate FFT of s(n)
    wire signed [15:0] S_re,S_im;
    wire in_ready_s, config_ready_s;
    wire S_valid, S_last;
    
    FFT64pt_wrapper fft_s_only (
        .aclk(aclk), .aresetn(aresetn),
        .in_data_real(s_re), .in_data_imag(s_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(in_ready_s), 

        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready_s), 

        .out_data_real(S_re), .out_data_imag(S_im),
        .out_valid(S_valid), .out_last(S_last),
        .out_ready(1'b1) 
    );
    
    assign in_ready = in_ready_s & in_ready_y1;
    assign config_ready = config_ready_s & config_ready_y1;

    // -------------------------------------------------------------------------
    // Step 3: Divide Y1(f) / S(f) to get Hs1_cap(f)
    // -------------------------------------------------------------------------
    complex_divider div_y1s (
        .y_re(Y_re), .y_im(Y_im),
        .s_re(S_re), .s_im(S_im),
        .h_re(Hs1_re), .h_im(Hs1_im)
    );

    assign Hs1_valid = Y_valid & S_valid;
    assign Hs1_last  = Y_last  & S_last;

endmodule
