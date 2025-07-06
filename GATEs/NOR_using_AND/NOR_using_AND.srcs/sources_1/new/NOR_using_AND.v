`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar kumar
// 
// Create Date: 07.07.2025 02:47:01
// Design Name: 
// Module Name: NOR_using_AND
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


module NOR_using_AND(a,b,y);
input a,b;
output y; 
wire w1,w2; 
assign w1 = ~a; 
assign w2 = ~b;
assign y = w1 & w2;
endmodule
