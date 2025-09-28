`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2025 22:55:07
// Design Name: 
// Module Name: write_ptr
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

module read_ptr #(parameter ADDR_WIDTH = 4)(
    input rd_clk,
    input rst_n,
    input rd_en,
    input [ADDR_WIDTH:0] wr_ptr_gray_sync,
    output reg [ADDR_WIDTH:0] rd_ptr_bin,
    output [ADDR_WIDTH:0] rd_ptr_gray,
    output fifo_empty
);
    wire [ADDR_WIDTH:0] rd_ptr_bin_next;
    wire [ADDR_WIDTH:0] rd_ptr_gray_next;

    assign rd_ptr_bin_next  = rd_ptr_bin + (rd_en & ~fifo_empty);
    
    bin_gray #(ADDR_WIDTH) GrayEncoder (
        .bin(rd_ptr_bin_next),
        .gray(rd_ptr_gray_next)
    );

    assign rd_ptr_gray = rd_ptr_gray_next;

    // Update read pointer
    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr_bin <= 0;
        else
            rd_ptr_bin <= rd_ptr_bin_next;
    end

    // Empty condition: read pointer == synchronized write pointer
    assign fifo_empty = (rd_ptr_gray_next == wr_ptr_gray_sync);
endmodule
