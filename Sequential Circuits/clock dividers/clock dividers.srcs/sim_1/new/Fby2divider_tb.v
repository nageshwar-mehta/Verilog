`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2025 01:50:48
// Design Name: 
// Design Name: 
// Module Name: Fby2divider_tb
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


module Fby2divider_tb;

wire clk_out;

reg clk,rstn;

Fby2divider DUT(
    .clk(clk),.reset(rstn),
    .clk_out(clk_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    rstn = 0;
    #10;
    rstn = 1;
end
initial begin
    #200;     // run for 200 ns
    $finish;
end


endmodule
