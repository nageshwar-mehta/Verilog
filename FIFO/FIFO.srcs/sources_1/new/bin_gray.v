`timescale 1ns / 1ps

module bin_gray #(parameter WIDTH=8)(bin_num,gray_num);
input[WIDTH-1:0] bin_num;
output[WIDTH-1:0] gray_num;
assign gray_num = bin_num ^ (bin_num>>1);
endmodule
