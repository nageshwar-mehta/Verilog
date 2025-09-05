`timescale 1ns / 1ps

module FFT_wrapper(
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
    
    
    wire [63:0] data_fft;
    wire [63:0] out_fft;
    //concatanating real and imaginary values to insert in FFT IP
    assign data_fft = {in_data_imag, in_data_real};
    
    
    wire 
    event_frame_started,
    event_tlast_unexpected,
    event_tlast_missing,
    event_status_channel_halt,
    event_data_in_channel_halt,
    event_data_out_channel_halt ;//additional event signals
    
  xfft_0 FFT_fixed_pt1 (
  .aclk(aclk),                                                // input wire aclk
  .aresetn(aresetn),                                          // input wire aresetn
  
  .s_axis_config_tdata(config_data),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(config_valid),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(config_ready),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata(data_fft),                      // input wire [63 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(in_valid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(in_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(in_last),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(out_fft),                      // output wire [63 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(out_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(out_ready),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(out_last),                      // output wire m_axis_data_tlast
  
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);

assign out_data_real = out_fft[31:0];
assign out_data_imag = out_fft[63:32];


endmodule
