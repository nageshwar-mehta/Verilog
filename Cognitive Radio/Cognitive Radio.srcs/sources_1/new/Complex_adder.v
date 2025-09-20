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

module complex_adder(
    input  signed [15:0] a_re, a_im,
    input  signed [15:0] b_re, b_im,
    output signed [15:0] x_re, x_im
);
    assign x_re = a_re + b_re;
    assign x_im = a_im + b_im;
endmodule

