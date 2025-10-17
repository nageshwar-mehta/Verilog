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

//for 16-bit real and 16-bit imaginary [Q7.9 * Q7.9]
module complex_multiplier#(parameter WIDTH = 16,
                           parameter OUT_WIDTH = 32,
                           parameter QF = 9)
    (
    input  signed [WIDTH-1:0] a_re, a_im,  // S(f)
    input  signed [WIDTH-1:0] b_re, b_im,  // H(f)
    output signed [OUT_WIDTH-1:0] p_re, p_im   // product
);
    wire signed [OUT_WIDTH-1:0] ac = a_re * b_re;
    wire signed [OUT_WIDTH-1:0] bd = a_im * b_im;
    wire signed [OUT_WIDTH-1:0] ad = a_re * b_im;
    wire signed [OUT_WIDTH-1:0] bc = a_im * b_re;

    wire signed [OUT_WIDTH-1:0] x = ac - bd; //[Q14.18]
    wire signed [OUT_WIDTH-1:0] y = ad + bc; //[Q14.18]

    // scale back to Q7.9 (keep 15 fractional bits only and one sign/integer part) 
    assign p_re = x[WIDTH+QF-1:QF];
    assign p_im = y[WIDTH+QF-1:QF];
endmodule

