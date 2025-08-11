`timescale 1ns / 1ps


module full_adder_tb();
wire sum,carry;
reg a,b,cin;

full_adder FA(
    .sum(sum),
    .carry(carry),
    .a(a),
    .b(b),
    .cin(cin)
    );
    
    
//test cases
initial begin
#10;
a=0;b=0;cin=0;
#10;
a=0;b=0;cin=1;
#10;
a=0;b=1;cin=0;
#10;
a=0;b=1;cin=1;
#10;
a=1;b=0;cin=0;
#10;
a=1;b=0;cin=1;
#10;
a=1;b=1;cin=0;
#10;
a=1;b=1;cin=1;
#10;
$finish;
end

//
initial begin
$monitor("a = %b | b = %b | cin = %b | sum = %b | carry = %b",a,b,cin,sum,carry);
end

endmodule
