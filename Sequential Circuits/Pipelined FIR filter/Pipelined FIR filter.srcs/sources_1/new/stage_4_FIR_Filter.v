//Project Name: 4-tap FIR Filter
// Nagesh____

`timescale 1ns / 1ps
// y[n] = h0.x[n] + h1.x[n-1] + h2.x[n-2] + h3.x[n-3]
//x: input
//y: output
//h: coefficents
//Note : posedge reset used instead of level reset becoz i wanted to to see it's schematic and Vivado doesn't allow level triggering of reset inside always block to generate schematic
module stage_4_FIR_Filter(clk,reset,x_in,y_out);
input clk,reset;
input signed[7:0]x_in;
output reg signed [15:0]y_out;

//Example coefficients : 
parameter signed[7:0] h0 = 8'sd1;
parameter signed[7:0] h1 = -8'sd1;
parameter signed[7:0] h2 = 8'sd0;
parameter signed[7:0] h3 = 8'sd2;

//input registers
reg signed[7:0]xn1,xn2,xn3;
reg signed[15:0]p0,p1,p2,p3;
reg signed[15:0] out_sum1,out_sum2;

//stage 1 : delay inputs assignment
always@(posedge clk or posedge reset)begin
    if(reset)begin
        xn1<=0;
        xn2<=0;
        xn3<=0;
    end
    else begin
    //Concept of Non-blocking Assignment
        xn1<=x_in;//x_in = x[n] and xn1 = x[n-1]
        xn2<=xn1;//xn2 = x[n-2] 
        xn3<=xn2;//xn3 = x[n-3] 
    end
end
//stage 2 : product 
always@(posedge clk or posedge reset)begin
    if(reset)begin
        p0<=0;
        p1<=0;
        p2<=0;
        p3<=0;
    end
    else begin
        p0<=h0*x_in;
        p1<=h1*xn1;
        p2<=h2*xn2;
        p3<=h3*xn3;
    end
end
//stage 3  sum : compression == 4:2
always@(posedge clk or posedge reset)begin
    if(reset)begin
        out_sum1<=0;
        out_sum2<=0;
    end
    else begin
        out_sum1 <= p0+p1;
        out_sum2 <= p2+p3;
    end
end
//stage 4  final sum
always@(posedge clk or posedge reset)begin
    if(reset)begin
        y_out<=0;
    end
    else begin
        y_out<=out_sum1+out_sum2;
    end
end

endmodule
