`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2025 00:27:01
// Design Name: 
// Module Name: UART_top
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


module UART_top(
                input clk, rst, wr_en, rdy_clr,
                input [7:0] data_in,
                output rdy, busy,
                output [7:0] data_out                
    );
    wire rx_clk_en;
    wire tx_clk_en;
    wire tx_temp;
    
    baud_rate_generator brg(
        .clk(clk),
        .rst(rst),
        .rx_en(rx_clk_en),
        .tx_en(tx_clk_en)
    );
    
    uart_tx utx(
        .clk(clk),
        .wr_en(wr_en),
        .rst(rst),
        .tx_en(tx_clk_en),
        .data_in(data_in),
        .tx(tx_temp),
        .busy(busy)
    );   

    uart_rx urx(
        .clk(clk),
        .rst(rst),
        .rx(tx_temp),
        .rdy_clr(rdy_clr),
        .rx_en(rx_clk_en),
        .rdy(rdy),
        .data_out(data_out)
    );         
    
endmodule
