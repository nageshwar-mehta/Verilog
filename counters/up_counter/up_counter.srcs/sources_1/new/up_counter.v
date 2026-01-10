`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.01.2026 13:50:04
// Design Name: 
// Module Name: up_counter
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


module up_counter(input[3:0]Din,input clk,rst,load,
                    output reg[3:0]count);
    always@(posedge clk)begin
        if(rst)begin
            count<=1'b0;            
        end
        else if(load)begin
            count<=Din;
        end
        else begin
            count<=count+1'b1;
        end
    end                    
endmodule
