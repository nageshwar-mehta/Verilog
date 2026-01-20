`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.01.2026 12:38:30
// Design Name: 
// Module Name: bit4PE_if_else
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


module bit4PE_if_else(
    input [3:0] in,
    output reg [1:0] pos 

    );
    always @(*)begin
        if(in[0])begin
            pos = 2'd0;
        end
        else if(in[1]) pos = 2'd1;
        else if(in[2]) pos = 2'd2;
        else if(in[3]) pos = 2'd3;
        else pos = 2'd0;
    end
endmodule
