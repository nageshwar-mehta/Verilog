`timescale 1ns / 1ps

module FFT8pt_tb ;
//=================cONTROLABLE AND OBSERVABLE PORTS===========// 
    parameter WIDTH = 16;
    reg clk, rstn,in_valid; 
    reg signed [WIDTH -1:0] in_real;
    reg signed [WIDTH -1:0] in_imag;
    wire out_valid, out_last;
    wire signed [WIDTH -1:0] out_real;
    wire signed [WIDTH -1:0] out_imag;
    
//=======================DUT============================//    
    FFT8pt dut(
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
    reg signed [WIDTH-1:0] in_real_reg[0:7];
    reg signed [WIDTH-1:0] in_imag_reg[0:7];
    
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
        // x0 =  3.25 - j2.50
        in_real_reg[0] = 16'b0000011010000000; // 1664
        in_imag_reg[0] = 16'b1111101100000000; // -1280

        // x1 = -1.75 + j0.50
        in_real_reg[1] = 16'b1111110010000000; // -896
        in_imag_reg[1] = 16'b0000000100000000; // 256

        // x2 = 0.00 - j4.00
        in_real_reg[2] = 16'b0000000000000000; // 0
        in_imag_reg[2] = 16'b1111100000000000; // -2048

        // x3 = -2.50 - j1.25
        in_real_reg[3] = 16'b1111101100000000; // -1280
        in_imag_reg[3] = 16'b1111110110000000; // -640

        // x4 = 1.50 - j0.75
        in_real_reg[4] = 16'b0000001100000000; // 768
        in_imag_reg[4] = 16'b1111111010000000; // -384

        // x5 = -3.00 + j2.25
        in_real_reg[5] = 16'b1111101000000000; // -1536
        in_imag_reg[5] = 16'b0000010010000000; // 1152

        // x6 = 0.50 + j0.00
        in_real_reg[6] = 16'b0000000100000000; // 256
        in_imag_reg[6] = 16'b0000000000000000; // 0

        // x7 = -1.00 - j1.00
        in_real_reg[7] = 16'b1111111000000000; // -512
        in_imag_reg[7] = 16'b1111111000000000; // -512
    end  

//===================FFT 8PT ACTIVATED================//    
integer i;
    initial begin
        @(posedge rstn);
        @(posedge clk);
        
        #20;
        for (i = 0; i < 8; i = i +1) begin
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
