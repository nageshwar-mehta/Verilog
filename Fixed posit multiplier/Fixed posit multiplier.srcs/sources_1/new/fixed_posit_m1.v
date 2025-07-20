`timescale 1ns / 1ps
//(32,6,2,23)->(bit width, exp width, regime bits, fraction bits)

module fixed_posit_m1(sa,ra,ea,fa,sb,rb,eb,fb,sc,rc,ec,fc);
//defining input ports
input sa,sb;
input[5:0] ea,eb;
input[1:0] ra,rb;
input[22:0] fa,fb;
//defining output ports
output  sc;
output [5:0]ec;
output [1:0] rc;
output [22:0] fc;
//wires to store intermidiate values 
wire signed[1:0] ka,kb; //values of ra and rb after passing it throug decoder [-2,1]
wire signed[8:0] ka_shifted,kb_shifted,kc_shifted;//shifted values of decoder output,shift by es, length = len{max(-2*2^6,1*2^6)} = len{max(-128,64)} = 8+1 signed bit
wire carry; //carry from fraction multiplication
wire [10:0]posit_sum;
assign sc = sa^sb;
decode d1(ra,ka);//input ra => output ka
decode d2(rb,kb);//input rab => output kb
assign ka_shifted = ka<<<6;//left shifted by es
assign kb_shifted = kb<<<6;//left shifted by es
frac_mult f1(fa,fb,fc,carry);
//Posit adder
assign posit_sum = ka_shifted+kb_shifted+$signed(ea)+$signed(eb)+carry; //total bits = 9+9+6+6+1 can be stored in maximum 11 bits
assign kc_shifted = posit_sum[9:2];
assign kc = kc>>>6;
assign ec = posit_sum[2:0];
//encoding
encode e1(kc,rc);
endmodule

//decode module
module decode( r, k);
input [1:0] r;
output reg signed [1:0] k;
always@(*)begin
    case(r)
        2'b00: k = -2'sd2;
        2'b01: k = -2'sd1;
        2'b10: k = 2'sd0;
        2'b11: k = 2'sd1;
    endcase
end
endmodule

//encode module 
module encode(kc,rc);
input signed[1:0]kc;
output reg [1:0]rc;
always@(*) begin
    case (kc)
        -2'b10: rc =2'b00;
        -2'b01: rc = 2'b01; 
        2'b00 : rc = 2'b10;
        2'b01 : rc = 2'b11;
    endcase
end
endmodule

//Fracction Multiplication module
module frac_mult(fa,fb,fc,carry);
input [22:0]fa,fb;
output reg [22:0]fc;
output reg carry;
reg [23:0]fa_24,fb_24;//for the calculation of 1+f
reg [47:0]fc_full,fc_norm; //store the fraction multiplication result
always@(*)begin
    fa_24 = {1'b1,fa};//1+fa
    fb_24 = {1'b1,fb};// 1+fb
    fc_full = fa_24*fb_24;//// 24x24 multiplication => 48 bits
     // Normalization: shift if MSB=1, else pass as is
     //Possible ranges:
//[1,2): MSB fc_full[47] = 0
//[2,4): MSB fc_full[47] = 1 ? shift right by 1 to divide it by 2 and update carry as 1;
    if(fc_full[47])begin
        fc_norm=fc_full>>1;
        carry = 1'b1;
    end
    else begin
        fc_norm = fc_full;
        carry = 1'b0;
    end
    //here MSB of fc_norm is always 0 2nd MSB is 1+ fc therefore we need to store fc = 45 to 23 
    fc=fc_norm[45:23];
end
endmodule
