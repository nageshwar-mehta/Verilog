`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar Kumar <2022uee0138@iitjammu.ac.in>
// 
// Create Date: 28.09.2025 18:56:56
// Design Name: 
// Module Name: fifo_memory
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


module fifo_memory #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4   // FIFO depth = 2^ADDR_WIDTH
)(
//Write
    input wr_clk,
    input wr_en,
    input [ADDR_WIDTH-1:0]wr_addr,
    input [DATA_WIDTH-1:0]din,
//Read
    input rd_clk,
    input rd_en,
    input [ADDR_WIDTH-1:0]rd_addr,
    output reg  [DATA_WIDTH-1:0]  dout
);

    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    // Write port
    always @(posedge wr_clk) begin
        if (wr_en) mem[wr_addr] <= din;
    end

    // Read port
    always @(posedge rd_clk) begin
        if (rd_en) dout <= mem[rd_addr];
    end

endmodule

