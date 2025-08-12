`timescale 1ns / 1ps

module ripple_carry_adder_tb();

wire [3:0]sum;
wire carry;

reg [3:0]a,b;
reg cin;

ripple_carry_adder RPA(
    .sum(sum),
    .carry(carry),
    .a(a), 
    .b(b), 
    .cin(cin)
);

initial begin
    //tests
    #10;
    a = 4'd0;
    b = 4'd0; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd1; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd2; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd3; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd4; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd5; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd6; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd7; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd8; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd9; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd10; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd11; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd12; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd13; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd14; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd15; 
    cin = 1'b0;
    
    
//    =============   //

     #10;
    a = 4'd0;
    b = 4'd0; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd1; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd2; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd3; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd4; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd5; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd6; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd7; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd8; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd9; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd10; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd11; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd12; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd13; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd14; 
    cin = 1'b1;
    
    #10;
    a = 4'd0;
    b = 4'd15; 
    cin = 1'b1;
    
//    tests
    #10;
    a = 4'd15;
    b = 4'd15; 
    cin = 1'b1;
    #10;
    a = 4'd15;
    b = 4'd15; 
    cin = 1'b0;
    #10;
    a = 4'd10;
    b = 4'd15; 
    cin = 1'b1;
    #10;
    a = 4'd15;
    b = 4'd10; 
    cin = 1'b1;
    #10;
    a = 4'd8;
    b = 4'd5; 
    cin = 1'b1;
    
    #10;
    $finish;
    
end

initial begin
    $monitor("a = %b | b = %b | cin = %b || sum = %d | carry = %b",a,b,cin,sum,carry);
end

endmodule
