`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2025 23:23:49
// Design Name: 
// Module Name: Asynchronous_FIFO
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

module Asynchronous_FIFO #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wr_clk,
    input rd_clk,
    input rst_n,
    input wr_en,
    input [DATA_WIDTH-1:0] din,
    input rd_en,
    output [DATA_WIDTH-1:0] dout,
    output fifo_full,
    output fifo_empty
);

    wire [ADDR_WIDTH:0] wr_ptr_bin, rd_ptr_bin;
    wire [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
    wire [ADDR_WIDTH:0] wr_ptr_gray_sync, rd_ptr_gray_sync;

    // Write Pointer
    write_ptr #(ADDR_WIDTH) wp (
        .wr_clk(wr_clk), .rst_n(rst_n), .wr_en(wr_en),
        .rd_ptr_gray_sync(rd_ptr_gray_sync),
        .wr_ptr_bin(wr_ptr_bin), .wr_ptr_gray(wr_ptr_gray),
        .fifo_full(fifo_full)
    );

    // Read Pointer
    read_ptr #(ADDR_WIDTH) rp (
        .rd_clk(rd_clk), .rst_n(rst_n), .rd_en(rd_en),
        .wr_ptr_gray_sync(wr_ptr_gray_sync),
        .rd_ptr_bin(rd_ptr_bin), .rd_ptr_gray(rd_ptr_gray),
        .fifo_empty(fifo_empty)
    );

    // Synchronizers
    sync_gray #(ADDR_WIDTH) sync_wr (
        .clk(rd_clk), .rst_n(rst_n),
        .gray_in(wr_ptr_gray), .gray_out(wr_ptr_gray_sync)
    );
    sync_gray #(ADDR_WIDTH) sync_rd (
        .clk(wr_clk), .rst_n(rst_n),
        .gray_in(rd_ptr_gray), .gray_out(rd_ptr_gray_sync)
    );

    // FIFO Memory
    fifo_memory #(DATA_WIDTH, ADDR_WIDTH) mem (
        .wr_clk(wr_clk), .wr_en(wr_en & ~fifo_full),
        .wr_addr(wr_ptr_bin[ADDR_WIDTH-1:0]), .din(din),
        .rd_clk(rd_clk), .rd_en(rd_en & ~fifo_empty),
        .rd_addr(rd_ptr_bin[ADDR_WIDTH-1:0]), .dout(dout)
    );

endmodule

