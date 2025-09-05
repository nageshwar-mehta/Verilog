`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2025 18:35:23
// Design Name: 
// Module Name: tb_FFT
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


module tb_FFT();

    reg aclk;
    reg aresetn;
    reg [31:0] in_data_real;
    reg [31:0] in_data_imag;
    reg in_valid;
    reg in_last;
    wire in_ready;
    
    reg [63:0] config_data;
    reg config_valid;
    wire config_ready;
    
    wire [31:0] out_data_real;
    wire [31:0] out_data_imag;
    wire out_valid;
    wire  out_last;
    reg  out_ready;
    
    reg [31:0] input_data[63:0]; //creating a ROM to input the data
    
    integer i;
    
    top_wrapper tb_in(
        .aclk(aclk),
        .aresetn(aresetn),
        .in_data_real(in_data_real),
        .in_data_imag(in_data_imag),
        .in_valid(in_valid),
        .in_last(in_last),
        .in_ready(in_ready),
        
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready),
        
        .out_data(out_data),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_ready(out_ready)
        );
        
    initial begin
    aclk = 0;
    end
    
    always begin
    #5 aclk = ~aclk;
    end
    
    initial begin
        aresetn = 0;
        in_valid = 0;
        
        in_valid = 1'b0;
        in_data_real = 32'd0;
        in_data_imag = 32'd0;
        in_last = 1'b0;
        
        out_ready = 1'b1;
        
        config_data = 8'd0;
        config_valid = 1'd0;
        
    end
    
    initial  begin
    #200
    aresetn = 1;
    input_data[0] = 32'b000000000000000000000000;

    end
    
endmodule
