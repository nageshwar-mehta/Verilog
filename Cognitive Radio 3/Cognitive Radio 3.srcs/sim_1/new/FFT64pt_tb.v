`timescale 1ns / 1ps

module FFT64pt_tb;
//================= CONTROL AND OBSERVABLE PORTS ===========// 
    parameter WIDTH = 16;
    reg clk, rstn, in_valid; 
    reg signed [WIDTH -1:0] in_real;
    reg signed [WIDTH -1:0] in_imag;
    wire out_valid, out_last;
    wire signed [WIDTH -1:0] out_real;
    wire signed [WIDTH -1:0] out_imag;
    
//======================= DUT ============================//    
    FFT64pt dut(
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
    
//========== MEMORY BLOCK FOR REAL I/P AND IMAG I/P =========//    
    reg signed [WIDTH-1:0] in_real_reg[0:63];
    reg signed [WIDTH-1:0] in_imag_reg[0:63];
    
//================== CLOCK INITIALIZATION =====================//    
    initial clk = 0;
    always #5 clk = ~clk; // 1 clk cycle = 10 ns
    
//==================== RESET =============//  
    initial begin    
        rstn = 0;
        in_valid = 0;
        in_real = 0;
        in_imag = 0;
        repeat(2) @(posedge clk);
        rstn = 1;
    end 
    
//================= ROM INITIALISATION (64 INPUTS) =========//    
    initial begin 
        @(posedge rstn);
        #10;

        // Example 64 complex inputs
        // Extend from your previous 32-point input set
        // You can replace these later with MATLAB/NumPy generated test vectors
        in_real_reg[0]  =  16'sd1664;   in_imag_reg[0]  = -16'sd1280;
        in_real_reg[1]  = -16'sd896;    in_imag_reg[1]  =  16'sd256;
        in_real_reg[2]  =  16'sd0;      in_imag_reg[2]  = -16'sd2048;
        in_real_reg[3]  = -16'sd1280;   in_imag_reg[3]  = -16'sd640;
        in_real_reg[4]  =  16'sd768;    in_imag_reg[4]  = -16'sd384;
        in_real_reg[5]  = -16'sd1536;   in_imag_reg[5]  =  16'sd1152;
        in_real_reg[6]  =  16'sd256;    in_imag_reg[6]  =  16'sd0;
        in_real_reg[7]  = -16'sd512;    in_imag_reg[7]  = -16'sd512;
        in_real_reg[8]  =  16'sd1024;   in_imag_reg[8]  =  16'sd0;
        in_real_reg[9]  =  16'sd512;    in_imag_reg[9]  = -16'sd768;
        in_real_reg[10] = -16'sd640;    in_imag_reg[10] =  16'sd512;
        in_real_reg[11] =  16'sd128;    in_imag_reg[11] = -16'sd128;
        in_real_reg[12] = -16'sd1792;   in_imag_reg[12] =  16'sd0;
        in_real_reg[13] =  16'sd896;    in_imag_reg[13] =  16'sd640;
        in_real_reg[14] = -16'sd256;    in_imag_reg[14] = -16'sd1024;
        in_real_reg[15] =  16'sd2048;   in_imag_reg[15] =  16'sd512;

        in_real_reg[16] =  16'sd512;    in_imag_reg[16] = -16'sd256;
        in_real_reg[17] = -16'sd1280;   in_imag_reg[17] =  16'sd1024;
        in_real_reg[18] =  16'sd384;    in_imag_reg[18] =  16'sd256;
        in_real_reg[19] = -16'sd768;    in_imag_reg[19] = -16'sd128;
        in_real_reg[20] =  16'sd640;    in_imag_reg[20] = -16'sd768;
        in_real_reg[21] = -16'sd1792;   in_imag_reg[21] =  16'sd256;
        in_real_reg[22] =  16'sd896;    in_imag_reg[22] =  16'sd896;
        in_real_reg[23] = -16'sd512;    in_imag_reg[23] =  16'sd0;
        in_real_reg[24] =  16'sd256;    in_imag_reg[24] = -16'sd384;
        in_real_reg[25] = -16'sd896;    in_imag_reg[25] =  16'sd128;
        in_real_reg[26] =  16'sd512;    in_imag_reg[26] =  16'sd768;
        in_real_reg[27] = -16'sd640;    in_imag_reg[27] = -16'sd640;
        in_real_reg[28] =  16'sd1280;   in_imag_reg[28] =  16'sd0;
        in_real_reg[29] = -16'sd1024;   in_imag_reg[29] =  16'sd512;
        in_real_reg[30] =  16'sd768;    in_imag_reg[30] = -16'sd128;
        in_real_reg[31] =  16'sd512;    in_imag_reg[31] =  16'sd512;

        // Add 32 more to make 64 total
        in_real_reg[32] = -16'sd256;    in_imag_reg[32] =  16'sd512;
        in_real_reg[33] =  16'sd896;    in_imag_reg[33] = -16'sd896;
        in_real_reg[34] =  16'sd1792;   in_imag_reg[34] =  16'sd0;
        in_real_reg[35] = -16'sd768;    in_imag_reg[35] =  16'sd384;
        in_real_reg[36] =  16'sd1024;   in_imag_reg[36] = -16'sd512;
        in_real_reg[37] = -16'sd512;    in_imag_reg[37] =  16'sd128;
        in_real_reg[38] =  16'sd384;    in_imag_reg[38] = -16'sd256;
        in_real_reg[39] = -16'sd640;    in_imag_reg[39] = -16'sd640;
        in_real_reg[40] =  16'sd1792;   in_imag_reg[40] =  16'sd1024;
        in_real_reg[41] = -16'sd512;    in_imag_reg[41] =  16'sd896;
        in_real_reg[42] =  16'sd256;    in_imag_reg[42] = -16'sd384;
        in_real_reg[43] =  16'sd128;    in_imag_reg[43] =  16'sd256;
        in_real_reg[44] = -16'sd896;    in_imag_reg[44] = -16'sd128;
        in_real_reg[45] =  16'sd512;    in_imag_reg[45] =  16'sd640;
        in_real_reg[46] = -16'sd1280;   in_imag_reg[46] = -16'sd896;
        in_real_reg[47] =  16'sd2048;   in_imag_reg[47] =  16'sd512;
        in_real_reg[48] = -16'sd640;    in_imag_reg[48] = -16'sd512;
        in_real_reg[49] =  16'sd896;    in_imag_reg[49] = -16'sd640;
        in_real_reg[50] =  16'sd256;    in_imag_reg[50] =  16'sd256;
        in_real_reg[51] = -16'sd1024;   in_imag_reg[51] =  16'sd512;
        in_real_reg[52] =  16'sd768;    in_imag_reg[52] =  16'sd256;
        in_real_reg[53] = -16'sd512;    in_imag_reg[53] = -16'sd512;
        in_real_reg[54] =  16'sd384;    in_imag_reg[54] =  16'sd128;
        in_real_reg[55] = -16'sd640;    in_imag_reg[55] =  16'sd640;
        in_real_reg[56] =  16'sd1536;   in_imag_reg[56] =  16'sd896;
        in_real_reg[57] = -16'sd1792;   in_imag_reg[57] =  16'sd256;
        in_real_reg[58] =  16'sd640;    in_imag_reg[58] = -16'sd640;
        in_real_reg[59] = -16'sd384;    in_imag_reg[59] = -16'sd128;
        in_real_reg[60] =  16'sd512;    in_imag_reg[60] =  16'sd512;
        in_real_reg[61] = -16'sd896;    in_imag_reg[61] =  16'sd384;
        in_real_reg[62] =  16'sd256;    in_imag_reg[62] =  16'sd128;
        in_real_reg[63] =  16'sd1024;   in_imag_reg[63] =  16'sd0;
    end  

//=================== FEED 64 INPUTS ==================//    
    integer i;
    initial begin
        @(posedge rstn);
        @(posedge clk);
        
        #20;
        for (i = 0; i < 64; i = i + 1) begin
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

//=================== OUTPUT OBSERVATION ==============//               
    initial begin
        $monitor("t=%0t | rstn=%b in_valid=%b in_real=%d in_imag=%d | out_valid=%b out_last=%b | out_real=%d out_imag=%d",
                 $time, rstn, in_valid, in_real, in_imag, out_valid, out_last, out_real, out_imag);
    end

endmodule
