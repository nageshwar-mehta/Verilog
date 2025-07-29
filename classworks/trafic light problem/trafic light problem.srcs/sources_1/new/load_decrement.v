`timescale 1ns / 1ps

module load_decrement(dec,load,init,clk,count);
input[5:0] init;
input clk,load,dec;
output reg [5:0] count;
always@(posedge clk)begin
    if(load==1)begin
        count <= init;
    end
    if(dec==1)begin
        count<=count-1;
    end
end
endmodule
