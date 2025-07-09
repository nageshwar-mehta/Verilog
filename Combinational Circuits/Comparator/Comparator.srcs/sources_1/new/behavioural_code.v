`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 21:51:13
// Design Name: 
// Module Name: behavioural_code
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


module behavioural_code(a,b,greater,lesser,equal);
//input,output
input [1:0]a,b;
output reg greater,lesser,equal;
always @(*) begin
    greater = (a>b);
    lesser = (a<b);
    equal = (a==b);
end
endmodule
