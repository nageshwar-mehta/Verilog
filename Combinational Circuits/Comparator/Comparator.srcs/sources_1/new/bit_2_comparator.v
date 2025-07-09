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
input [1:0]a,b;
output greater,lesser,equal;
wire mid1, mid2;
assign mid1 = ~(a[0]^b[0]);
assign mid2 = ~(a[1]^b[1]); 
assign greater = ( a[1] & (~b[1]) ) | ( mid2 & a[0] & (~b[0]) ); 
assign lesser = ( (~a[1]) & b[1] ) | ( mid2 & (~a[0]) & b[0] );
assign equal  = mid1 & mid2 ;
endmodule
