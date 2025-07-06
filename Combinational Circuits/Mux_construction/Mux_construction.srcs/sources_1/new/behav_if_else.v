`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 04:14:35
// Design Name: 
// Module Name: behav_if_else
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


module behav_if_else(ip,s,y);
input s;
input [1:0]ip;
output reg y;

always @(*) begin
    if(s) begin
        y = ip[1];
    end
    else begin
        y = ip[0];
    end
end

endmodule
