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
wire signed[1:0] ka,kb; //values of ra and rb after passing it throug decoder
wire signed[7:0] ka_shifted,kb_shifted;//shifted values of decoder output, length = len(ka) + len(exp)
wire [23:0]fa_24,fb_24;//for the calculation of 1+f
wire [47:0]fc_full; //store the fraction multiplication result
assign sc = sa^sb;
decode d1(ra,ka);//input ra => output ka
decode d2(rb,kb);//input rab => output kb
assign ka_shifted = ka<<6;//left shifted by es
assign kb_shifted = kb<<6;//left shifted by es
assign fa_24 = {1'b1,fa};//1+fa
assign fb_24 = {1'b1,fb};// 1+fb
assign fc_full = fa_24*fb_24;
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
