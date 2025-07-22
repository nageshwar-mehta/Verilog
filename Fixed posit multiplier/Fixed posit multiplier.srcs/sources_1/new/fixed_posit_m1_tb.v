`timescale 1ns / 1ps


module fixed_posit_m1_tb;
//inputs (min,max)
reg sa,sb;//(0,1)
reg[5:0] ea,eb; //(0,63)
reg[1:0] ra,rb;//(3,0)
reg[22:0] fa,fb;//(7fffff,0)
//outputs
wire  sc;
wire [5:0]ec;
wire [1:0] rc;
wire [22:0] fc;

fixed_posit_m1 uut(
    .sa(sa),.sb(sb),
    .ea(ea),.eb(eb),
    .ra(ra),.rb(rb),
    .fa(fa),.fb(fb)
);

//Intialization 
initial begin
//    initialization
    repeat(2)begin
    sa = 1'b0;sb=1'b0; //sc = 0
    ra = 2'b10;rb=2'b10; //(ka = 0, kb=0) => useed^0 = 1
    ea = 6'b000000;eb=6'b000000; // 2^ea = 2^0 = 1
    fa = 23'b0;fb=23'b0;//fa = fb =0; (1+f) = 1
//    result : v1 = 1 , v2 = 1, product = 1;
    #20;
    end
    
    //Test 1 
    
    $stop;
end
initial begin
    $monitor("Time : %0t sa = %b ra = %b ea = %d fa = %h",$time,sa,ra,ea,fa);
    $monitor("\t\t sb = %b rb = %b eb = %d fb = %h",sb,rb,eb,fb);
    $monitor("\t\t sc = %b rc = %b ec = %d fc = %h",sc,rc,ec,fc);

end

endmodule