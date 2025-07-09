`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 21:14:42
// Design Name: 
// Module Name: bit_2_comparator
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


module bit_2_comparator(greater,lesser,equal,a,b);
input a,b;
output greater,lesser,equal;
assign greater = a&(~b); 
assign lesser = (~a)&b;
assign equal  = ~(a^b);
endmodule
