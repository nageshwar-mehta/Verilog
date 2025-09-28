`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar - IIT Jammu <nagesh03mehta@gmail.com>
// 
// Design Name: 
// Module Name: FFT64pt_wrapper_tb
// Project Name: Cognitive Radio
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
module IFFT_verification();

    reg aclk;
    reg aresetn;
    reg signed [15:0] in_data_real;
    reg signed [15:0] in_data_imag;
    reg in_valid;
    reg in_last;
    wire in_ready;
    
    reg [7:0] config_data;
    reg config_valid;
    wire config_ready;
    
    wire signed [15:0] out_data_real;  // unpacked from 32-bit FFT output bus
    wire signed [15:0] out_data_imag;
    wire out_valid;
    wire out_last;
    reg  out_ready;
    
    reg [15:0] input_real[0:63];  // ROM for real input
    reg [15:0] input_imag[0:63];  // ROM for imag input
    
    integer f_real, f_imag;
    integer i;
    
    // DUT
    FFT64pt_wrapper tb_in(
        .aclk(aclk),
        .aresetn(aresetn),
        .in_data_real(in_data_real),
        .in_data_imag(in_data_imag),
        .in_valid(in_valid),
        .in_last(in_last),
        .in_ready(in_ready),
        
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready),
        
        .out_data_real(out_data_real),
        .out_data_imag(out_data_imag),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_ready(out_ready)
    );
    
    // Clock generation
    initial aclk = 0;
    always #5 aclk = ~aclk;  // 10 ns period
    
    // Reset
    initial begin
        in_valid = 0;
        in_last = 0;
        in_data_real = 0;
        in_data_imag = 0;
        config_data = 0; //reset
        config_valid = 0;
        out_ready = 1;  // always ready

        aresetn = 0;
        repeat (5) @(posedge aclk);
        aresetn = 1;
    end
    
// FFT(x) quantized in Q6.9 (16-bit signed)
initial begin
    input_real[0]  = -16'sd4864;   input_imag[0]  =   16'sd0;
    input_real[1]  =  16'sd15622;  input_imag[1]  =  -16'sd9154;
    input_real[2]  =  16'sd10575;  input_imag[2]  =   16'sd6944;
    input_real[3]  = -16'sd17578;  input_imag[3]  =  -16'sd9985;
    input_real[4]  = -16'sd1261;   input_imag[4]  =  -16'sd1273;
    input_real[5]  = -16'sd6332;   input_imag[5]  =   16'sd10290;
    input_real[6]  =    16'sd160;  input_imag[6]  =  -16'sd13480;
    input_real[7]  = -16'sd14144;  input_imag[7]  =  -16'sd33733;
    input_real[8]  =  16'sd23638;  input_imag[8]  =   16'sd31643;
    input_real[9]  = -16'sd5311;   input_imag[9]  =   16'sd15195;
    input_real[10] = -16'sd13974;  input_imag[10] =   16'sd9752;
    input_real[11] =  16'sd10749;  input_imag[11] =     16'sd185;
    input_real[12] = -16'sd18486;  input_imag[12] =  -16'sd7973;
    input_real[13] =   16'sd9173;  input_imag[13] =  -16'sd3732;
    input_real[14] = -16'sd18952;  input_imag[14] = -16'sd12189;
    input_real[15] = -16'sd10296;  input_imag[15] = -16'sd16519;
    input_real[16] = -16'sd19840;  input_imag[16] =   16'sd8064;
    input_real[17] = -16'sd12943;  input_imag[17] = -16'sd12360;
    input_real[18] = -16'sd4477;   input_imag[18] = -16'sd13552;
    input_real[19] =  16'sd10443;  input_imag[19] =   16'sd7831;
    input_real[20] = -16'sd15526;  input_imag[20] = -16'sd21945;
    input_real[21] =  -16'sd3904;  input_imag[21] =  -16'sd7882;
    input_real[22] = -16'sd14379;  input_imag[22] = -16'sd14609;
    input_real[23] =  16'sd12627;  input_imag[23] =  -16'sd3673;
    input_real[24] =  -16'sd6230;  input_imag[24] =   16'sd17051;
    input_real[25] =   16'sd2395;  input_imag[25] =   16'sd11850;
    input_real[26] =    16'sd907;  input_imag[26] =   16'sd7035;
    input_real[27] =   16'sd8147;  input_imag[27] = -16'sd15866;
    input_real[28] =  -16'sd4150;  input_imag[28] =  -16'sd1421;
    input_real[29] =  -16'sd1109;  input_imag[29] =     16'sd979;
    input_real[30] = -16'sd15156;  input_imag[30] =  -16'sd3815;
    input_real[31] =   16'sd8605;  input_imag[31] =  -16'sd2925;
    input_real[32] =  -16'sd1536;  input_imag[32] =        16'sd0;
    input_real[33] =   16'sd8605;  input_imag[33] =   16'sd2925;
    input_real[34] = -16'sd15156;  input_imag[34] =   16'sd3815;
    input_real[35] =  -16'sd1109;  input_imag[35] =   -16'sd979;
    input_real[36] =  -16'sd4150;  input_imag[36] =   16'sd1421;
    input_real[37] =   16'sd8147;  input_imag[37] =   16'sd15866;
    input_real[38] =    16'sd907;  input_imag[38] =  -16'sd7035;
    input_real[39] =   16'sd2395;  input_imag[39] = -16'sd11850;
    input_real[40] =  -16'sd6230;  input_imag[40] = -16'sd17051;
    input_real[41] =  16'sd12627;  input_imag[41] =   16'sd3673;
    input_real[42] = -16'sd14379;  input_imag[42] =   16'sd14609;
    input_real[43] =  -16'sd3904;  input_imag[43] =   16'sd7882;
    input_real[44] = -16'sd15526;  input_imag[44] =   16'sd21945;
    input_real[45] =  16'sd10443;  input_imag[45] =  -16'sd7831;
    input_real[46] =  -16'sd4477;  input_imag[46] =   16'sd13552;
    input_real[47] = -16'sd12943;  input_imag[47] =   16'sd12360;
    input_real[48] = -16'sd19840;  input_imag[48] =  -16'sd8064;
    input_real[49] = -16'sd10296;  input_imag[49] =  16'sd16519;
    input_real[50] = -16'sd18952;  input_imag[50] =  16'sd12189;
    input_real[51] =   16'sd9173;  input_imag[51] =   16'sd3732;
    input_real[52] = -16'sd18486;  input_imag[52] =   16'sd7973;
    input_real[53] =  16'sd10749;  input_imag[53] =    -16'sd185;
    input_real[54] = -16'sd13974;  input_imag[54] =   -16'sd9752;
    input_real[55] =  -16'sd5311;  input_imag[55] =  -16'sd15195;
    input_real[56] =  16'sd23638;  input_imag[56] =  -16'sd31643;
    input_real[57] = -16'sd14144;  input_imag[57] =   16'sd33733;
    input_real[58] =    16'sd160;  input_imag[58] =   16'sd13480;
    input_real[59] =  -16'sd6332;  input_imag[59] =  -16'sd10290;
    input_real[60] =  -16'sd1261;  input_imag[60] =   16'sd1273;
    input_real[61] = -16'sd17578;  input_imag[61] =   16'sd9985;
    input_real[62] =  16'sd10575;  input_imag[62] =  -16'sd6944;
    input_real[63] =  16'sd15622;  input_imag[63] =   16'sd9154;
end


    
    // Configuration block
    initial begin
        #20;
        config_data  = 8'd1;  // IFFT
        config_valid = 1'b1;
        @(posedge aclk);
        while (!config_ready) @(posedge aclk);
        config_valid = 1'b0;

    end
    
    // Open output files
    initial begin
        f_real = $fopen("fft_out_real.txt", "w");
        f_imag = $fopen("fft_out_imag.txt", "w");
        if (f_real == 0 || f_imag == 0) begin
            $display("Error opening output files");
            $finish;
        end
    end
    
    // Capture FFT outputs
    always @(posedge aclk) begin
        if (out_valid && out_ready) begin
            $fwrite(f_real, "%016b\n", out_data_real);
            $fwrite(f_imag, "%016b\n", out_data_imag);
        end
    end
    
    // Stop simulation when FFT done
    always @(posedge aclk) begin
        if (out_valid && out_last && out_ready) begin
            $fclose(f_real);
            $fclose(f_imag);
//            $finish;
        end
    end
    
    // Feed input data to FFT
    initial begin
        wait(aresetn == 1);
        #10;
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge aclk);
            while (!in_ready) @(posedge aclk);  // stall until core ready
            in_data_real <= input_real[i];
            in_data_imag <= input_imag[i];
            in_valid <= 1;
            in_last  <= (i == 63);
        end
        @(posedge aclk);
        in_valid <= 0;
        in_last  <= 0;

    end
    
    

endmodule

