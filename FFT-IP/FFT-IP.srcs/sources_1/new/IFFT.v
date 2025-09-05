`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2025 11:56:49
// Design Name: 
// Module Name: IFFT
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


module IFFT(
    input aclk,
    input aresetn,
    
    input [31:0] in_data_real,
    input [31:0] in_data_imag,
    
    input in_valid,
    input in_last,
    output in_ready,
    
    input [7:0] config_data,
    input config_valid,
    output config_ready,
    
    output [31:0] out_data_real,
    output [31:0] out_data_imag,
    
    output out_valid,
    output  out_last,
    input  out_ready
    );
    //Step 1 : Data complex conjugation 
    wire [63:0] data_ifft;
    Complex_conjugate CC1(
    .real_in(in_data_real),
    .imag_in(in_data_imag),
    .out_imag_real(data_ifft));
    
      
    //Step 2 : FFT IP  
    wire [63:0] fft_out;
    wire fft_out_valid;
    wire fft_out_ready;
    
    wire 
    event_frame_started,
    event_tlast_unexpected,
    event_tlast_missing,
    event_status_channel_halt,
    event_data_in_channel_halt,
    event_data_out_channel_halt ;//additional event signals
    
  fft_64 FFT_IP (
  .aclk(aclk),                                                // input wire aclk
  .aresetn(aresetn), // input wire aresetn
  
  .s_axis_config_tdata(config_data),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(config_valid),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(config_ready),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata(data_ifft),                      // input wire [63 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(in_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(in_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(in_last),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(fft_out),                      // output wire [63 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(fft_out_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(fft_out_ready),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(out_last),                      // output wire m_axis_data_tlast
  
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);

// Step 3 : Register FFT output to handle latency
reg [63:0] fft_out_reg;
reg fft_valid_reg;
reg out_last_reg;

    always @(posedge aclk) begin 
        if(!aresetn)begin
            fft_out_reg <=64'd0;
            fft_valid_reg <=1'b0;
            out_last_reg  <= 1'b0;
        end
        else begin 
            fft_out_reg <= fft_out;
            fft_valid_reg <= fft_out_valid;
            out_last_reg  <= out_last;
        end
    end
    
// Step 4 : Floating Point division by 64
wire real_div_valid, imag_div_valid;
wire real_div_ready, imag_div_ready;
 ///it's a floating point division IP (ignore name instantiation)
floating_point_multiplication divide_real (
  .aclk(aclk),                                  // input wire aclk
  
  .s_axis_a_tvalid(fft_valid_reg),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(real_div_ready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(fft_out_reg[31:0]),              // input wire [31 : 0] s_axis_a_tdata
  
  .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid, Always valid
  .s_axis_b_tready(),            // output wire s_axis_b_tready , Always ready
  .s_axis_b_tdata(32'b01000010100000000000000000000000),// input wire [31 : 0] s_axis_b_tdata ,floating point reps of 64
  
  .m_axis_result_tvalid(real_div_valid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(out_ready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(out_data_real)    // output wire [31 : 0] m_axis_result_tdata
);


floating_point_multiplication divide_imag (
  .aclk(aclk),                                  // input wire aclk
  
  .s_axis_a_tvalid(fft_valid_reg),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(imag_div_ready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(fft_out_reg[63:32]),              // input wire [31 : 0] s_axis_a_tdata
  
  .s_axis_b_tvalid(1'b1),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(),            // output wire s_axis_b_tready
  .s_axis_b_tdata(32'b01000010100000000000000000000000), // input wire [31 : 0] s_axis_b_tdata, floating point reps of 64
  
  .m_axis_result_tvalid(imag_div_valid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(out_ready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(out_data_imag)    // output wire [31 : 0] m_axis_result_tdata
);

//Step 5 : Combine multiplier outputs for final valid signal
assign out_valid = real_div_valid & imag_div_valid;

//step 6 : Propagate out_last correctly 
assign out_last = out_last_reg;

//Step 7 : FFT Ready Signal
assign fft_out_ready  = real_div_ready & imag_div_ready;



    
endmodule
