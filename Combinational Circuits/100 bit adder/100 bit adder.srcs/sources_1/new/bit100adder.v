`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 21:25:43
// Design Name: 
// Module Name: bit100adder
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


module bit100adder(a,b,cin,sum,carry);
input [99:0]a,b;
input cin;
output [99:0]sum;
output carry;
assign {carry,sum} = a+b+cin;
endmodule
