`timescale 1ns / 1ps


module RCA_W0_pipelining(input [3:0] a,b,
                        input cin,
                        output [3:0] sum,
                        output cout
    );
    wire c0,c1,c2;
    Full_adder FA1(.a(a[0]),.b(b[0]),.c(cin),.sum(sum[0]),.carry(c0));
    Full_adder FA2(.a(a[1]),.b(b[1]),.c(c0),.sum(sum[1]),.carry(c1));
    Full_adder FA3(.a(a[2]),.b(b[2]),.c(c1),.sum(sum[2]),.carry(c2));
    Full_adder FA4(.a(a[3]),.b(b[3]),.c(c2),.sum(sum[3]),.carry(cout));
    
endmodule
