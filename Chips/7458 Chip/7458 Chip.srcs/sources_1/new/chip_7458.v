`timescale 1ns / 1ps

//The 7458 is a chip with four AND gates and two OR gates
module top_module ( 
    input p1a, p1b, p1c, p1d, p1e, p1f,
    output p1y,
    input p2a, p2b, p2c, p2d,
    output p2y );
    wire pab2, pcd2,pacb1, pfed1;
    assign pab2 = p2a & p2b;
    assign pcd2 = p2c & p2d;
    assign p2y = pab2 | pcd2;
    assign pacb1 = p1a & p1c & p1b;
    assign pfed1 = p1f & p1e & p1d;
    assign p1y = pacb1 | pfed1;

endmodule