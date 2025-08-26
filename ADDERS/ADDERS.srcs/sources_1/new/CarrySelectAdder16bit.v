`timescale 1ns / 1ps

module CarrySelectAdder16bit(sum,carry,a,b,cin);
output[15:0]sum;
output carry;
input[15:0] a,b;
input cin;

wire c10,c11,       c20,c21     ,c30,c31    ,c40,c41;
wire c4,            c8          ,c12;
wire [3:0]s10,s11,  s20,s21     ,s30,s31    ,s40,s41;

//0-3 bit (group 1)
ripple_carry_adder_HW RCA_G10(s10,c10,a[3:0],b[3:0],1'b0);
ripple_carry_adder_HW RCA_G11(s11,c11,a[3:0],b[3:0],1'b1);

muxCSA out3_0(sum[3:0],c4,s10,s11,c10,c11,cin);


//4-7 bit (group 2)
ripple_carry_adder_HW RCA_G20(s20,c20,a[7:4],b[7:4],1'b0);
ripple_carry_adder_HW RCA_G21(s21,c21,a[7:4],b[7:4],1'b1);

muxCSA out7_4(sum[7:4],c8,s20,s21,c20,c21,c4);



//8-11 bit (group 1)
ripple_carry_adder_HW RCA_G30(s30,c30,a[11:8],b[11:8],1'b0);
ripple_carry_adder_HW RCA_G31(s31,c31,a[11:8],b[11:8],1'b1);

muxCSA out11_8(sum[11:8],c12,s30,s31,c30,c31,c8);


//12-15 bit (group 2)
ripple_carry_adder_HW RCA_G40(s40,c40,a[15:12],b[15:12],1'b0);
ripple_carry_adder_HW RCA_G41(s41,c41,a[15:12],b[15:12],1'b1);

muxCSA out15_8(sum[15:12],carry,s40,s41,c40,c41,c12);

endmodule

