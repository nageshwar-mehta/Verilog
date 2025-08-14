`timescale 1ns / 1ps

module demux_tb();

wire [1:0] out;
reg inp,s;

demux uut(
    .out(out),
    .inp(inp),
    .s(s)
);

initial begin

//Tests 
    #10;
    s = 0;
    inp = 0;
    #10;
    inp = 1;
    #10;
    #10;
    s = 1;
    inp = 0;
    #10;
    inp = 1;
    #10;
    $finish;
end
initial begin 
$monitor("select : %b, input : %b || output : s0 = %b , s1 = %b", s, inp, out[0], out[1]);  
end
endmodule
