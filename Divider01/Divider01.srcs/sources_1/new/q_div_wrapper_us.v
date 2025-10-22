`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 12:38:31
// Design Name: 
// Module Name: q_div_wrapper_us
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


module q_div_wrapper_us#(
    parameter Q = 9,          // fractional bits
    parameter N = 16          // total bits
)(
    input  [N-1:0] i_dividend_s,
    input  [N-1:0] i_divisor_s,
    input           i_start,
    input           i_clk,
    output reg [N-1:0]  o_quotient_out_s,
    output          o_complete,
    output          o_overflow
);

wire out_sign = i_dividend_s[N-1]^i_divisor_s[N-1];
wire [N-1:0]i_dividend_us = i_dividend_s[N-1] ? (~i_dividend_s + 1'b1) : i_dividend_s;
wire [N-1:0]i_divisor_us = i_divisor_s[N-1] ? (~i_divisor_s + 1'b1) : i_divisor_s;
wire [N-1:0] o_quotient_out;
qdiv_unsigned #(.Q(9), .N(16)) us_div_module1 (
        .i_dividend(i_dividend_us),
        .i_divisor(i_divisor_us),
        .i_start(i_start),
        .i_clk(i_clk),
        .o_quotient_out(o_quotient_out),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );
// Register output only when division completes
    always @(posedge i_clk) begin
        if (o_complete) begin
            o_quotient_out_s <= out_sign ? (~o_quotient_out + 1'b1) : o_quotient_out;
        end
    end   
endmodule
