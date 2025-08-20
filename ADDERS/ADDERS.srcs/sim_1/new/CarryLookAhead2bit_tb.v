`timescale 1ns / 1ps


module CarryLookAhead2bit_tb;

wire [1:0] sum;
wire cout;
reg [1:0]a,b;
reg cin;

CarryLookAhead2bit CLA2bit(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b),
    .cin(cin)
);
reg [10*8:0]msg;
initial begin

$monitor("a = %d | b = %d | cin = %d || sum = %d | carry = %d || total sum = %d || %s ",a,b,cin,sum,cout,{cout,sum},msg);
end

integer i,j,l;
reg [2:0] expected;
initial begin 
#10;
    for( i=0;i<=3;i=i+1)begin
        for(j =0;j<=3;j=j+1)begin 
            for(l =0;l<=1;l=l+1)begin
                a= i[1:0];
                b = j[1:0];
                cin = l[0];
                #1;
                expected = a+b+cin;
                if({cout,sum}!==expected)msg = "incorrect";
                else msg = "correct";
                #10;
                
            end
        end
    end
    
end
endmodule
