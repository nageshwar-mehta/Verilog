`timescale 1ns / 1ps
//Also Known as 3:2 Compressor
//a+b+c = sum and carry
//sum of each bit not dependent on their past carry
module CarrySaveAdder4bit(sum,carry,a,b,c);
input [3:0]a,b,c;
output [3:0]sum,carry;

//full adders for each bit

full_adder FA0(sum[0],carry[0],a[0],b[0],c[0]);
full_adder FA1(sum[1],carry[1],a[1],b[1],c[1]);
full_adder FA2(sum[2],carry[2],a[2],b[2],c[2]);
full_adder FA3(sum[3],carry[3],a[3],b[3],c[3]);
endmodule
