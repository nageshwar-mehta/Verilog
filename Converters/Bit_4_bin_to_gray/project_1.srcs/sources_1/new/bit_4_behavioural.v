`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 03:17:59
// Design Name: 
// Module Name: bit_4_behavioural
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


module bit_4_behavioural(bin,gray);
input [3:0]bin;
output [3:0]gray;
assign gray = bin ^ (bin>>1);
endmodule
