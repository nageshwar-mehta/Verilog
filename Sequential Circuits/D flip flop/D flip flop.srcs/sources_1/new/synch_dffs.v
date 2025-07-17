module synch_dffs (
    input clk,
    input reset,   // active high asynchronous reset
    input [7:0] d,
    output reg[7:0] q
);
    always@(posedge clk)begin
        if(reset)q<=8'b0;
        else q<=d;
    end

endmodule
