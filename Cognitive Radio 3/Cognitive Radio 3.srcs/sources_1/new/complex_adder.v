`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2025 05:42:51
// Design Name: 
// Module Name: complex_adder
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

module complex_adder#(parameter WIDTH = 16)(
    input  signed [WIDTH-1:0] a_re, a_im,
    input  signed [WIDTH-1:0] b_re, b_im,
    output signed [WIDTH-1:0] x_re, x_im
);//1bit extra to manage any overflow
    assign x_re = a_re + b_re;
    assign x_im = a_im + b_im;
endmodule

