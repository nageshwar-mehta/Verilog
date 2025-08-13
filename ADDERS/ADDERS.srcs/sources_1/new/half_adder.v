`timescale 1ns / 1ps


module half_adder(output  sum, output  carry,input a, input b);
assign sum = a^b;
assign carry = a&b;
//always @(a or b) begin
//    sum <= a^b; 
//    carry <= a&b;
//end
endmodule
