`timescale 1ns / 1ps

module ripple_carry_adder_8_bit_tb;
wire [7:0]sum;
wire carry;
reg [7:0]a,b;
reg cin;

ripple_carry_adder_8_bit RCA8bit(
    .sum(sum),
    .carry(carry),
    .a(a),
    .b(b),
    .cin(cin)
);


initial begin
$monitor("a = %d | b = %d | cin = %d || sum = %d | carry = %d || total sum = %d ",a,b,cin,sum,carry,{carry,sum});
end

initial begin
    //tests
    #10;
    a = 'd10;
    b = 'd20; 
    cin = 1'b0;
    
    #10;
    a = 'd10;
    b = 'd12; 
    cin = 1'b0;
    
    #10;
    a = 'd10;
    b = 'd21; 
    cin = 1'b0;
    
    #10;
    a = 'd10;
    b = 'd13; 
    cin = 1'b0;
    
    #10;
    a = 'd0;
    b = 'd4; 
    cin = 1'b0;
    
    #10;
    a = 4'd0;
    b = 4'd5; 
    cin = 1'b0;
    
    #10;
    a = 'd10;
    b = 'd16; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd17; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd18; 
    cin = 1'b0;
    
    #10;
    a = 8'd10;
    b = 8'd9; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd10; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd11; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd12; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd13; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd14; 
    cin = 1'b0;
    
    #10;
    a = 8'd0;
    b = 8'd15; 
    cin = 1'b0;
    
    
//    =============   //

     #10;
    a = 8'd0;
    b = 8'd0; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd1; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd2; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd3; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd4; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd5; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd6; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd7; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd8; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd9; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd10; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd11; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd12; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd13; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd14; 
    cin = 1'b1;
    
    #10;
    a = 8'd0;
    b = 8'd15; 
    cin = 1'b1;
    
//    tests
    #10;
    a = 8'd15;
    b = 8'd15; 
    cin = 1'b1;
    #10;
    a = 8'd15;
    b = 8'd15; 
    cin = 1'b0;
    #10;
    a = 8'd10;
    b = 8'd15; 
    cin = 1'b1;
    #10;
    a = 8'd15;
    b = 8'd10; 
    cin = 1'b1;
    #10;
    a = 8'd8;
    b = 8'd5; 
    cin = 1'b1;
    
    #10;
    $finish;
    
end
endmodule
