`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.01.2026 13:52:56
// Design Name: 
// Module Name: up_counter_tb
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


module up_counter_tb;
    reg [3:0] Din;
    reg clk,rst,load;
    wire [3:0] count;

    up_counter dut(
                    .Din(Din),
                    .clk(clk),
                    .rst(rst),
                    .load(load),
                    .count(count)
                    );
    initial begin
    clk = 0;
    rst = 1;    
    forever #5 clk = ~clk;
    end     
    initial begin
    #5 rst =1;
    #5 rst = 0;
    //else condn check
    rst = 0;
    load = 0;
 
    #25;
    
    
    // load on
    load = 1;
    Din = 5;
    #10;
    Din = 10;
    // rst on
    #15;
    rst = 1;
    #5;
    load = 0;
    rst = 0;
//    load on
    
    
    end               
endmodule
