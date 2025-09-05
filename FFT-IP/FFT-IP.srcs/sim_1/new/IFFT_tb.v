`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module IFFT_tb();

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
    
    integer f_real, f_imag;
    integer i;

    reg [31:0] fft_data_real[0:63];
    reg [31:0] fft_data_imag[0:63];
    
    // DUT
    IFFT dut (
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
        out_ready    = 1'b1; // always ready
        
        aresetn = 1'b0;
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
    end

    // Read FFT outputs from file
    initial begin
        $readmemb("fft_out_real.txt", fft_data_real);
        $readmemb("fft_out_imag.txt", fft_data_imag);
    end
    
    // Config block
    initial begin
        #20;
        config_data  = 8'd1;
        config_valid = 1'b1;
        wait (config_ready == 1'b1);
        @(posedge aclk);
        config_valid = 1'b0;
    end

    // Open output files for IFFT results
    initial begin
        f_real = $fopen("ifft_out_real.txt", "w");
        f_imag = $fopen("ifft_out_imag.txt", "w");
        if (f_real == 0 || f_imag == 0) begin
            $display("Error: Could not open output files.");
            $finish;
        end
    end

    // Capture IFFT outputs
    always @(posedge aclk) begin
        if (out_valid && out_ready) begin
            $fwrite(f_real, "%032b\n", out_data_real);
            $fwrite(f_imag, "%032b\n", out_data_imag);
        end
    end

    // Stop simulation once IFFT finishes
    always @(posedge aclk) begin
        if (out_valid && out_last && out_ready) begin
            $fclose(f_real);
            $fclose(f_imag);
            $finish;
        end
    end

    // Input driver: feed FFT outputs to IFFT
    initial begin
        wait(aresetn == 1'b1);
        #20;

        for (i = 0; i < 64; i = i + 1) begin
            @(posedge aclk);
            in_data_real <= fft_data_real[i];
            in_data_imag <= fft_data_imag[i];
            in_valid     <= 1'b1;
            in_last      <= (i == 63);
            wait (in_ready == 1'b1);
            @(posedge aclk);
        end
        
        @(posedge aclk);
        in_valid <= 1'b0;
        in_last  <= 1'b0;
    end

endmodule
