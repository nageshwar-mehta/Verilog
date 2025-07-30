`timescale 1ns / 1ps


module Four_deep_FIFO(data_in,push,pop,fifo_empty,fifo_full,data_out);
input [3:0]data_in;
input push,pop;
output fifo_empty,fifo_full;
output[3:0] data_out;
endmodule
