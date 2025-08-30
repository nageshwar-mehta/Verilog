`timescale 1ns / 1ps

module FFT_IFFT_64pt_tb;
    reg clk, rst, start, ifft_mode; // 0: FFT, 1: IFFT
    reg signed [1023:0] data_in_real;  // 64 * 16 bits = 1024 bits
    reg signed [1023:0] data_in_imag; // 64 * 16 bits = 1024 bits
    wire signed [1023:0] data_out_real; // 64 * 16 bits = 1024 bits
    wire signed [1023:0] data_out_imag; // 64 * 16 bits = 1024 bits
    wire done, busy;
    
    integer i;
    
    // Instantiate DUT
    FFT_IFFT_64pt_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .ifft_mode(ifft_mode),
        .data_in_real(data_in_real),
        .data_in_imag(data_in_imag),
        .data_out_real(data_out_real),
        .data_out_imag(data_out_imag),
        .done(done),
        .busy(busy)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        ifft_mode = 0;
        data_in_real = 0;
        data_in_imag = 0;
        
        #20 rst = 0;
        
        // Test 1: FFT of impulse
        $display("Test 1: FFT of impulse");
        data_in_real[15:0] = 16'd1000;  // Assign to first 16-bit segment
        for (i = 1; i < 64; i = i + 1) begin
            data_in_real[i*16 +: 16] = 0;  // Zero out other segments
            data_in_imag[i*16 +: 16] = 0;
        end
        
        #10 start = 1;
        #10 start = 0;
        
        wait(done);
        $display("FFT Complete");
        for (i = 0; i < 8; i = i + 1) begin
            $display("Output[%d] = %d + j%d", i, 
                     $signed(data_out_real[i*16 +: 16]), 
                     $signed(data_out_imag[i*16 +: 16]));
        end
        
        #100;
        
        // Test 2: IFFT of constant
        $display("\nTest 2: IFFT of constant");
        ifft_mode = 1;
        for (i = 0; i < 64; i = i + 1) begin
            data_in_real[i*16 +: 16] = 16'd100;
            data_in_imag[i*16 +: 16] = 0;
        end
        
        #10 start = 1;
        #10 start = 0;
        
        wait(done);
        $display("IFFT Complete");
        for (i = 0; i < 8; i = i + 1) begin
            $display("Output[%d] = %d + j%d", i, 
                     $signed(data_out_real[i*16 +: 16]), 
                     $signed(data_out_imag[i*16 +: 16]));
        end
        
        #100;
        
        // Test 3: FFT of sine wave
        $display("\nTest 3: FFT of sine wave");
        ifft_mode = 0;
        for (i = 0; i < 64; i = i + 1) begin
            // Generate 4 cycles of sine wave
            data_in_real[i*16 +: 16] = $rtoi(16384 * $sin(2 * 3.14159 * 4 * i / 64));
            data_in_imag[i*16 +: 16] = 0;
        end
        
        #10 start = 1;
        #10 start = 0;
        
        wait(done);
        $display("FFT of Sine Wave Complete");
        for (i = 0; i < 16; i = i + 1) begin
            $display("Output[%d] = %d + j%d", i, 
                     $signed(data_out_real[i*16 +: 16]), 
                     $signed(data_out_imag[i*16 +: 16]));
        end
        
        #100;
        $display("All tests completed");
        $finish;
    end
endmodule