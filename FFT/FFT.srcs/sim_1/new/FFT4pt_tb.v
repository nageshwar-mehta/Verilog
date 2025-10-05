`timescale 1ns / 1ps

module FFT4pt_tb ;
//=================cONTROLABLE AND OBSERVABLE PORTS===========// 
    parameter WIDTH = 16;
    reg clk, rstn,in_valid; 
    reg signed [WIDTH -1:0] in_real;
    reg signed [WIDTH -1:0] in_imag;
    wire out_valid, out_last;
    wire signed [WIDTH -1:0] out_real;
    wire signed [WIDTH -1:0] out_imag;
    
//=======================DUT============================//    
    FFT4pt dut(
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .in_real(in_real),
        .in_imag(in_imag),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_real(out_real),
        .out_imag(out_imag)        
    );
    
//==========MEMORY BLOCK FOR REAL I/P AND IMAG I/P=========//    
    reg signed [WIDTH-1:0] in_real_reg[0:3];
    reg signed [WIDTH-1:0] in_imag_reg[0:3];
    
//==================CLOCK INITIALIZATION=====================//    
    initial clk = 0;
    always #5 clk = ~clk; //1 clk cycle = 10 units
    
//====================RESET=============//  
    initial begin    
        rstn = 0;
        in_valid = 0;
        in_real = 0;
        in_imag = 0;
        repeat(2) @(posedge clk);
        rstn = 1;
    end 
    
//=================ROM INITIALISATION=========//    
    initial begin 
        @(posedge rstn);
        #10;
//        // TEST 1 :  test: input = [1,2,3,4], imag=0
//        in_real_reg[0] = 16'b0000000100000000; // 1.0
//        in_real_reg[1] = 16'b0000001000000000; // 2.0
//        in_real_reg[2] = 16'b0000001100000000; // 3.0
//        in_real_reg[3] = 16'b0000010000000000; // 4.0

//        in_imag_reg[0] = 0;
//        in_imag_reg[1] = 0;
//        in_imag_reg[2] = 0;
//        in_imag_reg[3] = 0;

        //TEST 2 : 
        // x0 = 3.25 - j2.50
        in_real_reg[0] = 16'b0000011010000000;  // +3.25
        in_imag_reg[0] = 16'b1111101100000000;  // -2.50
    
        // x1 = -1.75 + j0.50
        in_real_reg[1] = 16'b1111100110000000;  // -1.75
        in_imag_reg[1] = 16'b0000000100000000;  // +0.50
    
        // x2 = 0.00 - j4.00
        in_real_reg[2] = 16'b0000000000000000;  // 0.00
        in_imag_reg[2] = 16'b1111100000000000;  // -4.00
    
        // x3 = -2.50 - j1.25
        in_real_reg[3] = 16'b1111101100000000;  // -2.50
        in_imag_reg[3] = 16'b1111101111000000;  // -1.25
    end  

//===================FFT 4PT ACTIVATED================//    
integer i;
    initial begin
        @(posedge rstn);
        @(posedge clk);
        
        #20;
        for (i = 0; i < 4; i = i +1) begin
            @(posedge clk);             
            in_valid = 1'b1;                  
            in_real = in_real_reg[i];
            in_imag = in_imag_reg[i];  
        end
        #5;
        in_valid = 1'b0;
        in_real = 0;
        in_imag = 0;   
    end

//===================OUTPUT OBSERVATION==============//               
    initial begin
        $monitor("t=%0t | rstn=%b in_valid=%b in_real=%d in_imag=%d | out_valid=%b out_last=%b out_real=%d out_imag=%d",
                 $time, rstn, in_valid, in_real, in_imag, out_valid, out_last, out_real, out_imag);
    end

endmodule
