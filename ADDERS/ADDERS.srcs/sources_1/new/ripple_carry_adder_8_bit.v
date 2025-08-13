`timescale 1ns / 1ps


module ripple_carry_adder_8_bit(output [7:0]sum,output carry, input [7:0]a,input [7:0]b,input cin);
wire carry1;
ripple_carry_adder_HW RCA1(sum[3:0],carry1,a[3:0],b[3:0],cin);
ripple_carry_adder_HW RCA2(sum[7:4],carry,a[7:4],b[7:4],carry1);


endmodule
