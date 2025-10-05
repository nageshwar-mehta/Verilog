`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2025 13:55:09
// Design Name: 
// Module Name: FFT2pt_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFT2pt_tb ;
//=================cONTROLABLE AND OBSERVABLE PORTS===========// 
    parameter WIDTH = 16;
    reg clk, rstn,in_valid; 
    reg signed [WIDTH -1:0] in_real;
    reg signed [WIDTH -1:0] in_imag;
    wire out_valid, out_last;
    wire signed [WIDTH -1:0] out_real;
    wire signed [WIDTH -1:0] out_imag;
    
//=======================DUT============================//    
    FFT2pt dut(
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
    reg signed [WIDTH-1:0] in_real_reg[0:1];
    reg signed [WIDTH-1:0] in_imag_reg[0:1];
    
//==================CLOCK INITIALIZATION=====================//    
    initial clk = 0;
    always #5 clk = ~clk; //1 clk cycle = 10 units
    
//====================RESET=============//  
    initial begin    
        rstn = 0;
        repeat(2) @(posedge clk);
        rstn = 1;
        //reset activity time : 10*2 = 20 units 
    end 
    
//=================ROM INITIALISATION=========//    
    initial begin 
        @(posedge rstn);
        #10;
        //TEST -1 
////        Real inputs : Q7.9 format
//        in_real_reg[0] = 16'b0000011010000000;  // 3.2500
//        in_real_reg[1] = 16'b0000100000000000;  // 4.0000
        
//        //Real inputs : Q7.9 format
//        in_imag_reg[0] = 16'b0000000000000000;  // 0.0000
//        in_imag_reg[1] = 16'b0000000000000000;  // 0.0000
        
//        //TEST -2 
//        //Real inputs : Q7.9 format
//        in_real_reg[0] = 16'b0000000000000000;  // 0.0000
//        in_real_reg[1] = 16'b0000000000000000;  // 0.0000
        
//        //Real inputs : Q7.9 format
//        in_imag_reg[0] = 16'b0000000000000000;  // 0.0000
//        in_imag_reg[1] = 16'b0000000000000000;  // 0.0000

                //TEST -3
        //Real inputs : Q7.9 format
        in_real_reg[0] = 16'b0000101000000000;  // 5.0000
        in_real_reg[1] = 16'b0000000000000000;  // 0.0000
        
        //Real inputs : Q7.9 format
        in_imag_reg[0] = 16'b1111010111111111;  // -5.0000
        in_imag_reg[1] = 16'b1100111000000000;  // -25.0000
        
    end  

//===================FFT 2PT ACTIVATED================//    
integer i;
    initial begin
        @(posedge rstn);
        @(posedge clk);
        
        #20;
        for (i = 0; i < 2; i = i +1) begin
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
