`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 03:50:58
// Design Name: 
// Module Name: MUX_2X1
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


module MUX_2X1(ip,s,y);
input [0:1]ip,s;
output y;
assign y = (~s & ip[0]) | (s & ip[1]) ;

endmodule
