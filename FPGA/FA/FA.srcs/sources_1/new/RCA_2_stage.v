`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.09.2025 14:25:25
// Design Name: 
// Module Name: RCA_2_stage
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

///RCA - 1 Stage 
module RCA_2_stage(input clk,
                        input [3:0] a,b,
                        input cin,
                        output [3:0] sum,
                        output cout
    );
    
    wire s0,s1,s2,s3;
    wire c0,c1,c2,c3;
    wire c1_reg,a2_reg,b2_reg,a3_reg,b3_reg;
    Full_adder FA1(.a(a[0]),.b(b[0]),.c(cin),.sum(s0),.carry(c0));
    DFF reg1(.clk(clk),.d(s0),.q(sum[0]));
    
    Full_adder FA2(.a(a[1]),.b(b[1]),.c(c0),.sum(s1),.carry(c1));
    DFF reg2(.clk(clk),.d(s1),.q(sum[1]));
    DFF reg3(.clk(clk),.d(c1),.q(c1_reg));
    
    DFF reg4(.clk(clk),.d(a[2]),.q(a2_reg));
    DFF reg5(.clk(clk),.d(b[2]),.q(b2_reg));
    Full_adder FA3(.a(a2_reg),.b(b2_reg),.c(c1_reg),.sum(sum[2]),.carry(c2));
    
    DFF reg6(.clk(clk),.d(a[3]),.q(a3_reg));
    DFF reg7(.clk(clk),.d(b[3]),.q(b3_reg));
    Full_adder FA4(.a(a3_reg),.b(b3_reg),.c(c2),.sum(sum[3]),.carry(cout));
  
    
endmodule
