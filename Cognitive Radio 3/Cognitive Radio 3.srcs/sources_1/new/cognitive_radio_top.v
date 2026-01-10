`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 11:20:11
// Design Name: 
// Module Name: cognitive_radio_top
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

//module FFT64pt
//  #(parameter integer WIDTH    = 16,
//    parameter integer QF       = 9,    // fractional bits (Qm.QF)
//    parameter integer TW_WIDTH = 16    // twiddle constant width
//  )
//  (
//    input  wire                     clk,
//    input  wire                     rstn,
//    input  wire                     in_valid,
//    input  signed [WIDTH-1:0]       in_real,
//    input  signed [WIDTH-1:0]       in_imag,
//    output reg                      out_valid,
//    output reg                      out_last,
//    output reg signed [WIDTH-1:0]   out_real,
//    output reg signed [WIDTH-1:0]   out_imag
//  );


//module detail_coffn #(
//    parameter WIDTH = 16
//)(
//    input                      clk,
//    input                      rstn,       
//    input signed [WIDTH-1:0]   h_re,
//    input signed [WIDTH-1:0]   h_im,
//    input                      in_last,    
//    input                      in_valid,   
//    output reg signed [WIDTH-1:0] Di_re,
//    output reg signed [WIDTH-1:0] Di_im,
//    output reg                 out_last, 
//    output reg                 out_valid    
//);
module cognitive_radio_top
#(parameter integer WIDTH    = 16,
    parameter integer QF       = 9,    // fractional bits (Qm.QF)
    parameter integer TW_WIDTH = 16    // twiddle constant width
  )(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     in_valid,
    input  signed [2*WIDTH-1:0]       sf_in, //msb 16 bit -> real; lsb 16 bit imag (both in 7.9 format)
    input  signed [2*WIDTH-1:0]       hs1_in,
    input  signed [2*WIDTH-1:0]       w1_in,
    output reg                      out_valid
  

    );
    
    
    reg [3:0] state;
    localparam  S_ffts = 3'd0,
                S_div = 3'd1,
                S_SIchannel = 3'd2,
                S_ifft = 3'd3,
                S_Di = 3'd4;
                
    reg [2*WIDTH-1:0] sf_rom [63:0];
    reg [2*WIDTH-1:0] hs1_rom [63:0];
    reg [2*WIDTH-1:0] w1_rom [63:0];
    reg [2*WIDTH-1:0] w_by_s_rom [63:0];
    reg [2*WIDTH-1:0] hs_est_rom [63:0];
    reg [2*WIDTH-1:0] hs_ifft_rom [63:0];
    reg [2*WIDTH-1:0] Di_rom [31:0]; //downsampled by 2;
    
    reg [6:0]count_sf,count_hs1,count_w1, count_hifft;
    
    wire [WIDTH-1:0] sf_out_real, sf_out_imag;
    reg sf_out_valid, sf_out_last;
    FFT64pt #(WIDTH, QF, TW_WIDTH) fft_sf (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .in_real(sf_in[2*WIDTH-1:WIDTH]), .in_imag(sf_in[WIDTH-1:0]),
        .out_valid(sf_out_valid), .out_last(sf_out_last),
        .out_real(sf_out_real), .out_imag(sf_out_imag)
      );
      
      wire [WIDTH-1:0] hs1_out_real, hs1_out_imag;
      reg hs1_out_valid, hs1_out_last;
      FFT64pt #(WIDTH, QF, TW_WIDTH) fft_hs1 (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .in_real(hs1_in[2*WIDTH-1:WIDTH]), .in_imag(hs1_in[WIDTH-1:0]),
        .out_valid(hs1_out_valid), .out_last(hs1_out_last),
        .out_real(hs1_out_real), .out_imag(hs1_out_imag)
      );
      
      wire [WIDTH-1:0] w1_out_real, w1_out_imag;
      reg w1_out_valid, w1_out_last;
      FFT64pt #(WIDTH, QF, TW_WIDTH) fft_w1 (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .in_real(w1_in[2*WIDTH-1:WIDTH]), .in_imag(w1_in[WIDTH-1:0]),
        .out_valid(w1_out_valid), .out_last(w1_out_last),
        .out_real(w1_out_real), .out_imag(w1_out_imag)
      );
      
      reg [WIDTH-1:0]w_by_s_re, w_by_s_im, hs_re, hs_im;
      reg [WIDTH-1:0]hs_est_re, hs_est_im;
      complex_adder #(WIDTH) hs_est(
        .a_re(hs_re), .a_im(hs_im),
        .b_re(w_by_s_re), .b_im(w_by_s_im),
        .x_re(hs_est_re), .x_im(hs_est_im) 
      );
      
      reg [WIDTH-1:0] hifft_out_real, hifft_out_imag,hifft_in_re, hifft_in_im;
      reg hifft_out_valid, hifft_out_last;
      reg ifft_in_valid;
        IFFT64pt #(WIDTH, QF, TW_WIDTH) IFFT_module1  (
        .clk(clk),
        .rstn(rstn),
        .in_valid(iffft_in_valid),
        .in_real(hifft_in_re),
        .in_imag(hifft_in_im), 
        .out_valid(hifft_out_valid),
        .out_last(hifft_out_last),
        .out_real(hifft_out_real),
        .out_imag(hifft_out_imag)
    );
    
    reg [WIDTH-1:0] Di_in_re, Di_in_im, Di_out_re, Di_out_im;
    reg Di_in_last, Di_out_valid, Di_out_last;
    reg Di_in_valid;
    detail_coffn #(WIDTH) Di(
        .clk(clk),
        .rstn(rstn),
        .h_re(Di_n_re),
        .h_im(Di_in_im),
        .in_last(Di_in_last),
        .in_valid(Di_in_valid),
        .Di_re(Di_out_re),
        .Di_im(Di_out_im),
        .out_last(Di_out_last),
        .out_valid(Di_out_valid)
    );
      
      
   integer i;
    
    always @(posedge clk or negedge rstn)begin
    if(!rstn)begin
        count_sf = 0;
        count_hs1 = 0;
        count_w1 = 0;
        ifft_in_valid = 0;
        count_hifft = 0;
    end
    else if(state == S_ffts)begin
        if(sf_out_valid)begin
            sf_rom[count_sf][2*WIDTH-1:WIDTH] <= sf_out_real;
            sf_rom[count_sf][WIDTH-1:0] <= sf_out_imag;
            count_sf=count_sf+1;
            if(sf_out_last)begin
                count_sf = 0;                
            end
        end
        if(hs1_out_valid)begin
            hs1_rom[count_hs1][2*WIDTH-1:WIDTH] <= hs1_out_real;
            hs1_rom[count_hs1][WIDTH-1:0] <= hs1_out_imag;
            count_hs1=count_hs1+1;
            if(hs1_out_last)begin
                count_hs1 = 0;                
            end
        end
        if(w1_out_valid)begin
            w1_rom[count_hs1][2*WIDTH-1:WIDTH] <= w1_out_real;
            w1_rom[count_hs1][WIDTH-1:0] <= w1_out_imag;
            count_w1=count_w1+1;
            if(w1_out_last)begin
                count_w1 = 0;                
            end
        end
        
        if(sf_out_last&hs1_out_last&w1_out_last)begin
            state <= S_div;
        end
          
    end
    
    else if(state == S_div)begin
        for(i=0;i<64;i=i+1)begin
            w_by_s_rom[i][2*WIDTH-1:WIDTH] <= (((w1_rom[i][2*WIDTH-1:WIDTH])*(sf_rom[i][2*WIDTH-1:WIDTH]))+((w1_rom[i][WIDTH-1:0])*(sf_rom[i][WIDTH-1:0])))/((sf_rom[i][2*WIDTH-1:WIDTH])^2+(sf_rom[i][WIDTH-1:0])^2);
            w_by_s_rom[i][WIDTH-1:0] <= (((w1_rom[i][WIDTH-1:0])*(sf_rom[i][2*WIDTH-1:WIDTH]))-((w1_rom[i][2*WIDTH-1:WIDTH])*(sf_rom[i][WIDTH-1:0])))/((sf_rom[i][2*WIDTH-1:WIDTH])^2+(sf_rom[i][WIDTH-1:0])^2);
        end
        state <= S_SIchannel;
        i <=0;
    end
    else if(state == S_SIchannel) begin
        for(i=0;i<64;i=i+1)begin
            hs_re <= hs1_rom[i][2*WIDTH-1:WIDTH];
            hs_im <= hs1_rom[i][WIDTH-1:0];
            w_by_s_re <= w_by_s_rom[i][2*WIDTH-1:WIDTH];
            w_by_s_im <= w_by_s_rom[i][WIDTH-1:0];
            hs_est_rom[i][2*WIDTH-1:WIDTH] <= hs_est_re;
            hs_est_rom[i][WIDTH-1:0] <= hs_est_im;
        end
        state <= S_ifft;
        ifft_in_valid <= 1'b1;
    end
    
    else if(state == S_ifft)begin
        if(hifft_out_valid)begin
            hs_ifft_rom[count_hifft][2*WIDTH-1:WIDTH] <= hifft_out_real;
            hs_ifft_rom[count_hifft][WIDTH-1:0] <= hifft_out_imag;
            count_hifft=count_hifft+1;
            if(hifft_out_last)begin
                count_hifft = 0; 
                state <= S_Di;               
            end
        end
    end
    
    else if(state == S_Di) begin
        for(i=0;i<64;i=i+1)begin
            Di_in_valid <=1'b1;
            Di_in_re <= hs_ifft_rom[i][2*WIDTH-1:WIDTH];
            Di_in_im <= hs_ifft_rom[i][WIDTH-1:0];
            if(
        end
    end
    
        
    end
    
endmodule
