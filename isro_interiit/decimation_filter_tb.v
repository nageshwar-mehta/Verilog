`timescale 1ns/1ps

module tb_decimation_filter_top;

    // Parameters
    parameter CLK_PERIOD = 977;  // ~1.024 MHz (977ns period)
    
    // Signals
    reg clk;
    reg rst_n;
    reg signed [3:0] modulator_in;
    reg modulator_valid;
    
    wire signed [23:0] audio_out;
    wire audio_valid;
   
    
    // Counters
    integer input_count;
    integer cic_count;
    integer fir1_count;
    integer output_count;
    
    // DUT instantiation
    decimation_filter_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .modulator_in(modulator_in),
        .modulator_valid(modulator_valid),
        .audio_out(audio_out),
        .audio_valid(audio_valid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Simulation
    initial begin
        // Initialize
        rst_n = 0;
        modulator_in = 0;
        modulator_valid = 0;
        input_count = 0;
        cic_count = 0;
        fir1_count = 0;
        output_count = 0;
        
        // Reset
        #(CLK_PERIOD*20);
        rst_n = 1;
        #(CLK_PERIOD*10);
        
        $display("========================================");
        $display("Decimation Filter Chain Testbench");
        $display("Input Rate:  1.024 MHz");
        $display("Output Rate: 4 kHz");
        $display("Total Decimation: 256x");
        $display("========================================\n");
        
        // Generate test stimulus
        modulator_valid = 1;
        
        // Simulate 10ms worth of data (10,240 samples at 1.024 MHz)
        repeat(10240) begin
            // Simple test pattern: sine-like
            if ((input_count % 512) < 256)
                modulator_in = 4'sd7;
            else
                modulator_in = -4'sd8;
            
            input_count = input_count + 1;
            
            @(posedge clk);
            
           
            
            
            
            if (audio_valid) begin
                output_count = output_count + 1;
                $display("[FINAL Out %0d] Value = %0d", output_count, audio_out);
            end
        end
        
        // Summary
        #(CLK_PERIOD*100);
        $display("\n========================================");
        $display("Simulation Complete");
        $display("========================================");
        $display("Input samples:  %0d", input_count);
        $display("CIC outputs:    %0d (expected %0d)", cic_count, input_count/64);
        $display("FIR1 outputs:   %0d (expected %0d)", fir1_count, input_count/128);
        $display("Final outputs:  %0d (expected %0d)", output_count, input_count/256);
        $display("========================================\n");
        
        $finish;
    end
   
endmodule