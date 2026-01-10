`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2025 19:16:54
// Design Name: 
// Module Name: complex_sub
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

module complex_sub#(parameter WIDTH = 16)(
    input clk,sub_out,
    input  signed [WIDTH-1:0] a_re, a_im,
    input  signed [WIDTH-1:0] b_re, b_im,
    output reg signed [WIDTH-1:0] x_re, x_im
);

    always @(posedge clk)begin
        if(sub_out)begin
            x_re <= a_re - b_re;
            x_im <= a_im - b_im;
        end
    end
endmodule


