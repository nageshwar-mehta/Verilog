`timescale 1ns / 1ps


module demux(inp,s,out);
input inp,s;
output reg [1:0] out;

always@(*) begin
    case(s) 
        1'b0: out[0] = inp;
        1'b1: out[1] = inp;
        default: out = 2'b00;
    endcase 
end
endmodule
