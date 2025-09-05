`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module tb_FFT();

    reg aclk;
    reg aresetn;
    reg [31:0] in_data_real;
    reg [31:0] in_data_imag;
    reg in_valid;
    reg in_last;
    wire in_ready;
    
    reg [7:0] config_data;
    reg config_valid;
    wire config_ready;
    
    wire [31:0] out_data_real;
    wire [31:0] out_data_imag;
    wire out_valid;
    wire out_last;
    reg  out_ready;
    
    reg [31:0] input_data[0:63]; // ROM for input data
    
    integer f_real, f_imag;
    integer i;
    
    // DUT
    top_wrapper tb_in(
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
        
    // Clock: 10 ns period
    initial aclk = 0;
    always #5 aclk = ~aclk;
    
    // Reset + default signals
    initial begin
        in_valid     = 1'b0;
        in_last      = 1'b0;
        in_data_real = 32'd0;
        in_data_imag = 32'd0;
        config_data  = 8'd0;
        config_valid = 1'b0;
        out_ready    = 1'b1; // keep ready high
        
        aresetn = 1'b0;
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
    end
    
    
    
    // ROM initialization (you can also $readmemh instead)
    initial begin
        // small pause to ensure reset applied
        #1;
        // manual initialization shown; you can replace with $readmemh("input_data_real_hex.txt", input_data);
        input_data[0] = 32'b00000000000000000000000000000000;
        input_data[1] = 32'b00111101110010001011110100110110;  
        input_data[2] = 32'b00111110010001111100010111000010;  
        input_data[3] = 32'b00111110100101001010000000110001;
        input_data[4] = 32'b00111110110000111110111100010101;
        input_data[5] = 32'b00111110111100010101101011101010;
        input_data[6] = 32'b00111111000011100011100111011010;
        input_data[7] = 32'b00111111001000100110011110011001;
        input_data[8] = 32'b00111111001101010000010011110011;
        input_data[9] = 32'b00111111010001011110010000000011;
        input_data[10] = 32'b00111111010101001101101100110001;
        input_data[11] = 32'b00111111011000011100010110011000;
        input_data[12] = 32'b00111111011011001000001101011110;
        input_data[13] = 32'b00111111011101001111101000001011;
        input_data[14] = 32'b00111111011110110001010010111110;
        input_data[15] = 32'b00111111011111101100010001101101;
        input_data[16] = 32'b00111111100000000000000000000000;
        input_data[17] = 32'b00111111011111101100010001101101;
        input_data[18] = 32'b00111111011110110001010010111110;
        input_data[19] = 32'b00111111011101001111101000001011;
        input_data[20] = 32'b00111111011011001000001101011110;
        input_data[21] = 32'b00111111011000011100010110011000;
        input_data[22] = 32'b00111111010101001101101100110001;
        input_data[23] = 32'b00111111010001011110010000000011;
        input_data[24] = 32'b00111111001101010000010011110011;
        input_data[25] = 32'b00111111001000100110011110011001;
        input_data[26] = 32'b00111111000011100011100111011010;
        input_data[27] = 32'b00111110111100010101101011101010;
        input_data[28] = 32'b00111110110000111110111100010101;
        input_data[29] = 32'b00111110100101001010000000110001;
        input_data[30] = 32'b00111110010001111100010111000010;
        input_data[31] = 32'b00111101110010001011110100110110;
        input_data[32] = 32'b10100101101110010110011101100111;
        input_data[33] = 32'b10111101110010001011110100110110;
        input_data[34] = 32'b10111110010001111100010111000010;
        input_data[35] = 32'b10111110100101001010000000110001;
        input_data[36] = 32'b10111110110000111110111100010101;
        input_data[37] = 32'b10111110111100010101101011101010;
        input_data[38] = 32'b10111111000011100011100111011010;
        input_data[39] = 32'b10111111001000100110011110011001;
        input_data[40] = 32'b10111111001101010000010011110011;
        input_data[41] = 32'b10111111010001011110010000000011;
        input_data[42] = 32'b10111111010101001101101100110001;
        input_data[43] = 32'b10111111011000011100010110011000;
        input_data[44] = 32'b10111111011011001000001101011110;
        input_data[45] = 32'b10111111011101001111101000001011;
        input_data[46] = 32'b10111111011110110001010010111110;
        input_data[47] = 32'b10111111011111101100010001101101;
        input_data[48] = 32'b10111111100000000000000000000000;
        input_data[49] = 32'b10111111011111101100010001101101;
        input_data[50] = 32'b10111111011110110001010010111110;
        input_data[51] = 32'b10111111011101001111101000001011;
        input_data[52] = 32'b10111111011011001000001101011110;
        input_data[53] = 32'b10111111011000011100010110011000;
        input_data[54] = 32'b10111111010101001101101100110001;
        input_data[55] = 32'b10111111010001011110010000000011;
        input_data[56] = 32'b10111111001101010000010011110011;
        input_data[57] = 32'b10111111001000100110011110011001;
        input_data[58] = 32'b10111111000011100011100111011010;
        input_data[59] = 32'b10111110111100010101101011101010;
        input_data[60] = 32'b10111110110000111110111100010101;
        input_data[61] = 32'b10111110100101001010000000110001;
        input_data[62] = 32'b10111110010001111100010111000010;
        input_data[63] = 32'b10111101110010001011110100110110;
    end

    // Config block
    initial begin
        #130;
        config_data  = 8'd1;
        config_valid = 1'b1;
        wait (config_ready == 1'b1);
        @(posedge aclk);
        config_valid = 1'b0;
    end
    
    // Open output files
    initial begin
        f_real = $fopen("fft_out_real.txt", "w");
        f_imag = $fopen("fft_out_imag.txt", "w");
        if (f_real == 0 || f_imag == 0) begin
            $display("Error: Could not open output files.");
            $finish;
        end
    end
    
    // Capture FFT outputs
    always @(posedge aclk) begin
        if (out_valid && out_ready) begin
            $fwrite(f_real, "%032b\n", out_data_real);
            $fwrite(f_imag, "%032b\n", out_data_imag);
        end
    end

    // Stop simulation once FFT finishes
    always @(posedge aclk) begin
        if (out_valid && out_last && out_ready) begin
            $fclose(f_real);
            $fclose(f_imag);
            $finish;
        end
    end
    
    // Input driver
    initial begin
        wait (aresetn == 1'b1);
        #20;
        in_data_imag = 32'd0;
        
        for (i = 63; i >= 0; i = i - 1) begin
            @(posedge aclk);
            in_data_real <= input_data[i];
            in_valid <= 1'b1;
            in_last  <= (i == 0);
            wait (in_ready == 1'b1);
            @(posedge aclk);
        end
        
        @(posedge aclk);
        in_valid <= 1'b0;
        in_last  <= 1'b0;
    end
    
endmodule