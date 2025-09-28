`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2025 21:29:16
// Design Name: 
// Module Name: gray_bin
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


module gray_bin #(parameter ADDR_WIDTH = 4)( gray,bin);
input [ADDR_WIDTH:0]gray;
output reg [ADDR_WIDTH:0]bin;

//reg [ADDR_WIDTH:0] temp;
integer i;

always @(*)begin
    bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
    for(i=ADDR_WIDTH-1;i>=0;i=i-1)begin
        bin[i] = bin[i+1] ^ gray[i]; 
    end
end

endmodule
