`timescale 1ns / 1ps
//module asynch_dffs (
//    input clk,
//    input areset,   // active high asynchronous reset
//    input [7:0] d,
//    output reg [7:0] q
//);
//    always@(posedge clk or posedge areset)begin
//        if(areset)q<=8'b0;
//        else q<=d;
//    end

//endmodule


module asynch_dffs_tb();
wire [7:0] q;
reg clk,areset;
reg [7:0] d;

asynch_dffs df2(
    .clk(clk),
    .q(q),
    .areset(areset),
    .d(d)
    );
    
    initial begin 
        clk = 0;
        d = 0;
        areset = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        #10 d = 4;
        #10 d = 5;
        #10 d = 32; areset = 1;
        #10 d = 33; areset = 0;
        #10 d = 12;
//        #10 $finish;
        
    end
    
    initial begin
    $monitor("time : %0t :: d = %d  areset = %b || q = %d ",$time,d,areset,q);
    end

endmodule
