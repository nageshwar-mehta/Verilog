`timescale 1ns / 1ps


module Four_deep_FIFO(clk,data_in,push,pop,fifo_empty,fifo_full,data_out);
input [3:0]data_in;
input push,pop,clk;
output reg fifo_empty,fifo_full;
output reg [3:0] data_out;

reg [2:0]counter = 0;
reg [3:0]fifo_mem[3:0];
always@(posedge clk)begin
    if(fifo_empty!=0)data_out <= fifo_mem[counter-1];
    if(push==1)begin
        fifo_mem[counter] <=data_in;
        counter <= counter+1;
    end
    if(pop==1)begin
        counter <= counter-1;
        fifo_mem[counter] <=0;
    end
    if(counter==0) fifo_empty <=0;
    if(counter==4) fifo_full <=0;
    
    
end

endmodule
