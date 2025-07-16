
module top_module (
    input [3:0] in,
    output reg [1:0] pos  );
    always @(*) begin 
        case(1'b1)
            in[0] : pos = 2'd0;
            in[1] : pos = 2'd1;
            in[2] : pos = 2'd2;
            in[3] : pos = 2'd3;
            default pos = 2'd0;
        endcase
    end

endmodule


////THEORY:
//A priority encoder is a combinational circuit that, when given an input bit vector, outputs the position of the first 1 bit in the vector. For example, a 8-bit priority encoder given the input 8'b10010000 would output 3'd4, because bit[4] is first bit that is high.

//Build a 4-bit priority encoder. For this problem, if none of the input bits are high (i.e., input is zero), output zero. Note that a 4-bit number has 16 possible combinations.