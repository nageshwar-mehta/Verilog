`timescale 1ns / 1ps
//4-bit Ripple carry adder using 4 full adder 

module ripple_carry_adder(output [3:0]sum, output carry,input[3:0]a,input[3:0]b,input cin);
wire cout1,cout2,cout3;
full_adder FA1(sum[0],cout1,a[0],b[0],cin);
full_adder FA2(sum[1],cout2,a[1],b[1],cout1);
full_adder FA3(sum[2],cout3,a[2],b[2],cout2);
full_adder FA4(sum[3],carry,a[3],b[3],cout3);

endmodule
