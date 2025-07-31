`timescale 1ns / 1ps


module Four_deep_FIFO(clk,data_in,push,pop,fifo_empty,fifo_full,data_out);
input [3:0]data_in;
input push,pop,clk;
output reg fifo_empty,fifo_full;
output reg [3:0] data_out;
reg [2:0]counter =0;
reg [3:0]fifo_mem[3:0];
always@(posedge clk)begin

//PUSH
    if(push==1)begin
        fifo_mem[3] <= fifo_mem[2];
        fifo_mem[2] <= fifo_mem[1];
        fifo_mem[1] <= fifo_mem[0];
        fifo_mem[0] <= data_in;
        counter <= counter+1;
    end
    
//POP    
    if (pop == 1 && counter > 0) begin
        fifo_mem[counter-1] <= 0;
        counter <= counter - 1;
    end
//DATA : first inserted data     
    if(counter>0)data_out <= fifo_mem[counter-1];
//    else data_out<=0;

// empty and full check
    fifo_empty  <= (counter==0);
    fifo_full <= (counter==4);
end

endmodule
