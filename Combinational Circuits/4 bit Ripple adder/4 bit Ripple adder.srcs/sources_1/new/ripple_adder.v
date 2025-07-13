`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 09:25:13
// Design Name: 
// Module Name: ripple_adder
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


module ripple_adder(input [3:0]a,input [3:0]b,output [3:0]sum,output carry);
wire c1,c2,c3,c4;
half_adder HA0(a[0],b[0],sum[0],c1);
full_adder FA0(a[1],b[1],c1,sum[1],c2);
full_adder FA1(a[2],b[2],c2,sum[2],c3);
full_adder FA2(a[3],b[3],c3,sum[3],c4);
assign carry = c4;
endmodule
