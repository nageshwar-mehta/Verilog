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

module write_ptr #(parameter ADDR_WIDTH = 4)(
    input wr_clk,
    input rst_n,
    input wr_en,
    input [ADDR_WIDTH:0] rd_ptr_gray_sync,
    output reg [ADDR_WIDTH:0] wr_ptr_bin,
    output [ADDR_WIDTH:0] wr_ptr_gray,
    output fifo_full
);
    wire [ADDR_WIDTH:0] wr_ptr_bin_next;
    wire [ADDR_WIDTH:0] wr_ptr_gray_next;

    assign wr_ptr_bin_next  = wr_ptr_bin + (wr_en & ~fifo_full);
    
    bin_gray #(ADDR_WIDTH) GrayEncoder (
        .bin(wr_ptr_bin_next),
        .gray(wr_ptr_gray_next)
    );

    assign wr_ptr_gray = wr_ptr_gray_next;

    // Update write pointer
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr_bin <= 0;
        else
            wr_ptr_bin <= wr_ptr_bin_next;
    end

    // Full condition: next write pointer == read pointer with MSB inverted (take eg : r_ptr_bin = 0xyz and w_ptr_bin = 1xyz in binary 
    assign fifo_full = (wr_ptr_gray_next == {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],rd_ptr_gray_sync[ADDR_WIDTH-2:0]});
endmodule
