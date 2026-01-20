`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 22:56:53
// Design Name: 
// Module Name: packed_unpacked
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


module packed_unpacked;
 bit [7:0] packed_1d_arr;
 initial begin
    packed_1d_arr = 8'd19;
    for(int i=0;i<8;i++)begin
        $display("packed_1d_arr[%0d] = %0b",i,packed_1d_arr[i]);
    end
 end
endmodule
