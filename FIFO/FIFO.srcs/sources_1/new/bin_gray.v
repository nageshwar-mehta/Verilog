`timescale 1ns / 1ps
//input and output width = ADDR_WIDTH-1 : 0 for actual memory address
//                       = ADDR_WIDTH for wrap around flag : this is used for implementation of ASYNCH FIFO full and empty condition

module bin_gray #(parameter ADDR_WIDTH=4)(
    input [ADDR_WIDTH:0] bin,
    output [ADDR_WIDTH:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

