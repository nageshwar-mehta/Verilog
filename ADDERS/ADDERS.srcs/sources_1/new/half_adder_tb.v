`timescale 1ns / 1ps


module half_adder_tb();
reg a,b;
wire sum,carry;

half_adder uut(
    .sum(sum),
    .carry(carry),
    .a(a), 
    .b(b)
);

initial begin 
#10;
a = 0;
b = 0;

#10;
a = 0;
b = 1;

#10;
a = 1;
b = 0;

#10;
a = 1;
b = 1;
 
#10;
$finish;
end
//monitor
initial begin
$monitor("a : %b | b : %b | sum : %b | carry : %b",a,b,sum,carry); 
end
endmodule
