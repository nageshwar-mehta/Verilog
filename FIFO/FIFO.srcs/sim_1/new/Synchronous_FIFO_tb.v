`timescale 1ns / 1ps
//Input ports : data_in,w_in,r_in,clk,rst
//Output ports : data_out,fifo_empty,fifo_full

module Synchronous_FIFO_tb();

parameter width = 4;
parameter depth = 8;

reg [width-1:0]data_in;
reg w_in,r_in,clk,rst;

wire [width-1:0]data_out;
wire fifo_empty,fifo_full;

Synchronous_FIFO uut(
    .data_in(data_in),
    .w_in(w_in),
    .r_in(r_in),
    .clk(clk),
    .rst(rst),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full),
    .data_out(data_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial  begin
    // stablization test
    rst = 1;
    #10 rst = 0;
    #10 rst = 1;
    
    // Write Test
    w_in = 1;
    data_in = 5; //1
    #10;
    w_in = 1;
    data_in = 7; //2
    #10;
    w_in = 1;
    data_in = 0; //3
    #10;
    w_in = 1;
    data_in = 2; //4
    #10;
    w_in = 1;
    data_in = 3; //5
    #10;
    w_in =0;
    
    
    // Read test
    #10r_in = 1; //1
    #10r_in = 1; //2
    #10r_in = 1; //3
    #10r_in = 0;
    
    $finish;
end

initial begin
    $monitor("time: %0t | reset : %b  data_in : %d  r_in : %b  w_in : %b  d_out : %d  full : %b  empty : %b",$time,rst,data_in,r_in,w_in,data_out,fifo_full,fifo_empty);
end

endmodule
