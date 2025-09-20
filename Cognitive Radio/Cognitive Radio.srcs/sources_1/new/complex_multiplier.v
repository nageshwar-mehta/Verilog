`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar <<nagesh03mehta@gmail.com>>
// 
// Create Date: 20.09.2025 05:26:47
// Design Name: 
// Module Name: complex_multiplier
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

//for 16-bit real and 16-bit imaginary [Q1.15 * Q1.15]
module complex_multiplier(
    input  signed [15:0] a_re, a_im,  // S(f)
    input  signed [15:0] b_re, b_im,  // H(f)
    output signed [15:0] p_re, p_im   // product
);
    wire signed [31:0] ac = a_re * b_re;
    wire signed [31:0] bd = a_im * b_im;
    wire signed [31:0] ad = a_re * b_im;
    wire signed [31:0] bc = a_im * b_re;

    wire signed [31:0] x = ac - bd; //[Q2.32]
    wire signed [31:0] y = ad + bc; //[Q2.32]

    // scale back to Q1.15 (keep 15 fractional bits only and one sign/integer part) 
    assign p_re = x[30:15];
    assign p_im = y[30:15];
endmodule

