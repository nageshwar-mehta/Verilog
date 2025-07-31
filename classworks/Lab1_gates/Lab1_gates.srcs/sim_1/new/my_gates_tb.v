`timescale 1ns / 1ps

module my_gates_tb;
    wire y1,y2;
    reg a,b,en;
    
    my_gates uut(
        .y1(y1),
        .y2(y2),
        .a(a),
        .b(b),
        .en(en)
    );
    
    initial begin
        //tests 
        #10 a = 1'b0;b= 1'b0; en= 1'b0;
        #10 a = 1'b0;b= 1'b0; en= 1'b1;
        #10 a = 1'b0;b= 1'b1; en= 1'b0;
        #10 a = 1'b0;b= 1'b1; en= 1'b1;
        #10 a = 1'b1;b= 1'b0; en= 1'b0;
        #10 a = 1'b1;b= 1'b0; en= 1'b1;
        #10 a = 1'b1;b= 1'b1; en= 1'b0;
        #10 a = 1'b1;b= 1'b1; en= 1'b1; 
        $finish;
    end
    initial  begin
    $monitor("time: %0t, a = %b, b = %b, en = %b, y1 = %b, y2 = %b",$time,a,b,en,y1,y2);
    end
    
endmodule
