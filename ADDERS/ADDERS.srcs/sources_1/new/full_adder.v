`timescale 1ns / 1ps


module full_adder(output sum, output carry,input a, input b, input cin);
 wire s1,c1,s2,c2;
half_adder HA2(s2,c2,b,cin);
half_adder HA1(sum,c1,a,s2);
assign sum = s1;
assign carry  = c1 | c2;
endmodule
