`timescale 1ns / 1ps


module stage_4_FIR_Filter_tb;
reg clk, reset;
reg signed[7:0]x_in;
wire signed[15:0]y_out;
//design under test
stage_4_FIR_Filter uut(
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y_out(y_out)
);
//clock initialization
initial begin
    clk = 0;
    forever #5 clk=~clk; // 10ns period
end

//Testbenches
initial begin
    $monitor("Time:%0t, clk:%b, reset:%b, x_in:%d, y_out: %d",$time,clk,reset,x_in,y_out);
    //settleing down the output
    reset = 1;
    #10;
    reset= 0;
    #10;
    repeat(4)begin
        x_in = 0;
    end
//======Tests=====//
    #10 x_in = 1;
    #10 x_in = 0;
    #10 x_in = 1;
    #10 x_in = -1;
    #10 x_in = 2;
    #10 x_in = 3;
    #10 x_in = 1;
    #10 x_in = -2;
    #10 x_in = 4;
    #10 x_in = -4;
$finish;
end

endmodule
