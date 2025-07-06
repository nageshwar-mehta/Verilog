`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar Kumar
// 
// Create Date: 03.07.2025 23:18:47
// Design Name: NAND using OR Gate
// Module Name: NAND
// Project Name: NAND using OR Gate
// Target Devices: NA
// Tool Versions: 1.0
// Description: NA
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module NAND(a,b,y);
input a,b;
output y;
wire w1,w2;
assign w1 = ~a;
assign w2 = ~b;
assign y = w1|w2;
endmodule


