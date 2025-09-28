`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2025 22:21:24
// Design Name: 
// Module Name: sync_gray
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 2FF Synchronizer
// 
//////////////////////////////////////////////////////////////////////////////////
module sync_gray #(parameter ADDR_WIDTH = 4)(
    input clk,
    input rst_n,
    input [ADDR_WIDTH:0]gray_in,
    output reg [ADDR_WIDTH:0]gray_out
);
    reg [ADDR_WIDTH:0]sync1;

    always @(posedge clk or negedge rst_n)begin
        if (!rst_n)begin
            sync1 <= 0;
            gray_out <= 0;
        end else begin
            sync1 <= gray_in;
            gray_out <= sync1;
        end
    end
endmodule

