`timescale 1ns / 1ps


module LogicShifter8bit_tb;
logic [7:0]y;
logic [7:0]x;
logic [3:0]shift;

LogicShifter8bit dut(
    .y(y),
    .x(x),
    .shift(shift)
);

task shift_by_bits(input logic [7:0]tx,
            input logic [3:0]tshift
            );
    begin  
     x = tx;
//     y = ty;
     shift = tshift;
     #10; // to settle down the outputs
     $display("time = %0t, x = %b, shift = %d, | y = %b",$time,x,shift,y);
     end
endtask
    
initial begin
    repeat(20)begin 
        shift_by_bits($urandom,$urandom);
    end
    $display("---- Testbench Completed ----");
    $finish;
end    

endmodule
