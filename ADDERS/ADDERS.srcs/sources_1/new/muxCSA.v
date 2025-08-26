module muxCSA(output reg [3:0]sum, output reg carry,
input[3:0]sum0,input[3:0]sum1,
input c0,input c1, input cin);
always @(*) begin
    case (cin)
        1'b0: begin
            sum = sum0;
            carry = c0;
        end
        1'b1: begin 
            sum = sum1;
            carry =c1;
        end
        default : begin 
            sum =4'b0000;
            carry =1'b0;
        end 
    endcase 
end

endmodule