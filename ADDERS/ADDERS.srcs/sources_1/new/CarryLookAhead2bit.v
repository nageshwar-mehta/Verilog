`timescale 1ns / 1ps
//==========CALCULATIONS============//
/*
input = {a0,a1},{b0,b1},C0 = cin; 
output = {s0,s1},c2 = cout;

propagator pi = ai ^ bi;
generator gi = ai & bi;

si = pi ^ ci;
c(i+1) = pi&ci | gi;

s0 = p0 ^ c0;
s1 = p1^(p0c0 | g0);

c0 = cin;
c1 = p0c0 | g0;
c2 = cout = p1&p0&c0 | p1&g0 | g1;


variables : p0,p1,c0,g0,g1;

*/
module CarryLookAhead2bit(sum,cout,a,b,cin);
input [1:0] a,b;
input cin;
output[1:0] sum;
output cout;
wire p0,p1,c0,g0,g1,c2;

assign p0 = a[0] ^ b[0];
assign p1 = a[1] ^ b[1];

assign g0 = a[0]&b[0];
assign g1 = a[1]&b[1];

assign sum[0] = p0 ^ c0;
assign sum[1] = p1^(p0&c0 | g0);

assign c0 = cin ;

assign c1 = p0&c0 | g0;
assign c2 = p1&p0&c0 | p1&g0 | g1;

assign cout = c2;

endmodule
