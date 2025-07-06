`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 04:00:30
// Design Name: 
// Module Name: behavioral_code
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


module behavioral_code(ip,s,y);
input [1:0]ip;
input s;
output reg y;

always @(*) begin
    case (s)
        1'b0 : y = ip[0];
        1'b1 : y = ip[1];
        default : y = 1'bx;
    endcase 
end

endmodule
