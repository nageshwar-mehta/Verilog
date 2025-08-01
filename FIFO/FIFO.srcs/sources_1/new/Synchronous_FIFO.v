`timescale 1ns / 1ps
//Input ports : data_in,w_in,r_in,clk,rst
//Output ports : data_out,fifo_empty,fifo_full

module Synchronous_FIFO#(parameter 
width = 4,
depth = 8)
(clk,data_in,w_in,r_in,rst,data_out,fifo_empty,fifo_full);

input wire [width-1:0]data_in;
input wire clk,w_in,r_in,rst;
output reg [width-1:0]data_out;
output wire fifo_empty,fifo_full;

reg [$clog2(depth)-1:0] r_ptr,w_ptr;
reg [$clog2(depth):0] counter;
reg [width-1:0] fifo_mem[0:depth-1];


always @(posedge clk or negedge rst)begin
    if(!rst)begin
        counter<=0;
        r_ptr<=0;
        w_ptr<=0;
        data_out<=0;
    end
    else begin 
        if(w_in && !fifo_full)begin
            fifo_mem[w_ptr]<=data_in;
            w_ptr<=(w_ptr+1)%depth;
            counter<=counter+1;
        end
        if(r_in && !fifo_empty)begin
            data_out<=fifo_mem[r_ptr];
            r_ptr<=(r_ptr+1)%depth;
            counter<=counter-1;
        end
    end
end
assign fifo_empty = (counter==0);
assign fifo_full = (counter==depth);

endmodule
