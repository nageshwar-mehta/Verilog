`timescale 1ns / 1ps
//logic shifter preserve sign bit
//shift : 0 -> No shift
//shift : 1 to 8 -> Right shift 
//shift : 15 to 9 -> Left Shift
module LogicShifter8bit(output reg [7:0]y,
input [3:0]shift,input[7:0]x);

//MUX
always @(*) begin 
    case(shift)
        4'b0000: y = x; //No Shift
        
        4'b0001: y = {x[7],x[7:1]}; // right shift by 1 bit
        4'b0010: y = {{2{x[7]}}, x[7:2]};  // right shift by 2 bit
        4'b0011: y = {{3{x[7]}},x[7:3]}; // right shift by 3 bit
        4'b0100: y = {{4{x[7]}},x[7:4]}; // right shift by 4 bit
        4'b0101: y = {{5{x[7]}},x[7:5]}; // right shift by 5 bit
        4'b0110: y = {{6{x[7]}},x[7:6]}; // right shift by 6 bit
        4'b0111: y = {{7{x[7]}},x[7]}; // right shift by 7 bit
        4'b1000: y = {8{x[7]}}; //// right shift by 8 bit
        
        4'b1001: y = {x[0],7'b0}; // left shift by  7 bit
        4'b1010: y = {x[1:0],6'b0}; // left shift by 6 bit
        4'b1011: y = {x[2:0],5'b0}; // left shift by 5 bit
        4'b1100: y = {x[3:0],4'b0}; // left shift by 4 bit
        4'b1101: y = {x[4:0],3'b0}; // left shift by 3 bit
        4'b1110: y = {x[5:0],2'b0}; // left shift by 2 bit
        4'b1111: y = {x[6:0],1'b0}; // left shift by 1 bit
        
        default : y = 8'b0;
    endcase 
end

endmodule
