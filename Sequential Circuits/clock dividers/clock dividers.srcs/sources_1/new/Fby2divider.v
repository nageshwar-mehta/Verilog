`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2025 01:39:16
// Design Name: 
// Module Name: Fby2divider
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


module Fby2divider(input clk,reset,
                   output clk_out);
    reg clk_init;
    always @(posedge clk)begin
        if(!reset)begin
            clk_init<=0;
        end
        else begin
            clk_init <= ~clk_init;
        end
    end     
    assign clk_out = clk_init;              
endmodule
