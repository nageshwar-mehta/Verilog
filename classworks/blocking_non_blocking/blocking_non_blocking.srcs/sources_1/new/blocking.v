
//`timescale 1ns / 1ps
//module blocking;
//    reg [3:0] data = 4'h5;  
//    reg [3:0] y = 4'h3;
//    real  r_value;
//    integer i_value;

//    initial begin
//        r_value = 3.14;
//        i_value = 4;
//        #2 data = 4'd6;   // triggers monitor
//        #3 data = 4'd7;   // triggers monitor
//           i_value = 10;  // triggers monitor (included in print)
//           i_value = 6;   // triggers monitor
//        #1 $finish;       // allow printing before ending
//    end

//    initial begin
//        $monitor("time : %0t | data = %0d | y = %0d | r_value = %0f | i_value = %0d", 
//                 $time, data, y, r_value, i_value);
//    end
//endmodule


`timescale 1ns / 1ps
module blocking;
    reg [3:0] data = 4'h5;  
    reg [3:0] y = 4'h3;
    real  r_value;
    integer i_value;

    initial begin
        r_value <= 3.14;
        i_value <= 4;
        #2 data <= 4'd6;   // triggers monitor
        #3 data <= 4'd7;   // triggers monitor
           i_value <= 10;  // triggers monitor (included in print)
           i_value <= 6;   // triggers monitor
        #1 $finish;       // allow printing before ending
    end

    initial begin
        $monitor("time : %0t | data = %0d | y = %0d | r_value = %0f | i_value = %0d", 
                 $time, data, y, r_value, i_value);
    end
endmodule

