`timescale 1ns / 1ps
//module dff (
//    input clk,    // Clocks are used in sequential circuits
//    input d,
//    output reg q );//

module dff_tb();
wire q;
reg clk,d;

dff df1(
    .d(d),
    .clk(clk),
    .q(q)
);
initial begin 
#10 clk = 0;
forever #5 clk = ~clk;
end

initial begin
#10;
#10 d = 0;
#10 d = 1;
#10;
$finish;

end
initial begin
$monitor("time : %0t :: d = %b || q = %b",$time,d,q);
end

endmodule
