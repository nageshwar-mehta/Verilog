`timescale 1ns / 1ps

module JK_2_tb();
reg clk,j,k;
wire Q;

JK2 uut(
    .clk(clk),
    .j(j),
    .k(k),
    .Q(Q)
);

initial begin
    clk = 0;
    forever #5 clk=~clk;
end

initial begin
    $monitor("time : %0t | J = %b K = %b Q = %b",$time,j,k,Q);
    j=0;k=0;
    #10;
    j=0;k=1;
    #20;
    j=1;k=0;
    #20;
    j=1;k=1;
    #40;
    $finish;
end
initial begin
    $dumpfile("JK2_tb.vcd");
    $dumpvars(0, JK_2_tb);
end

endmodule
