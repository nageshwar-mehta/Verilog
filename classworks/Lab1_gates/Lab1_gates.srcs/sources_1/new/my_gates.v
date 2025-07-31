`timescale 1ns / 1ps


module my_gates(a,b,en,y1,y2);
//inputs
input a,b,en;

//outputs
output y1,y2;

//gates
and a1(y1,a,b);//2 input ports
and a2(y2,a,b,en);//3 input ports

endmodule
