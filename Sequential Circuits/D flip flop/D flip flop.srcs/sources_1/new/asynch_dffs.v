module asynch_dffs (
    input clk,
    input areset,   // active high asynchronous reset
    input [7:0] d,
    output reg [7:0] q
);
    always@(posedge clk or posedge areset)begin
        if(areset)q<=8'b0;
        else q<=d;
    end

endmodule
