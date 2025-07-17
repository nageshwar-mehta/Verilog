module JK2 (
    input clk,
    input j,
    input k,
    output reg Q); 
    always@(posedge clk)begin
        Q<=j&~Q|~k&Q;
    end

endmodule
