`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 03:35:12
// Design Name: 
// Module Name: bit_4_gray_to_bin
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


module bit_4_gray_to_bin(gray,bin);
input [3:0]gray;
output [3:0]bin;

assign bin[3] = gray[3];
assign bin[2] = gray[2] ^ bin[3];
assign bin[1] = gray[1] ^ bin[2];
assign bin[0] = gray[0] ^ bin[1];
endmodule
