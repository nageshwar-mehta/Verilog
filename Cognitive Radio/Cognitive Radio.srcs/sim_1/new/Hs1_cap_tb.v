`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Hs1_cap
// Engineer: Nageshwar <<nagesh03mehta@gmail.com>>
//////////////////////////////////////////////////////////////////////////////////

module Hs1_cap_tb;

    // Clock & reset
    reg aclk;
    reg aresetn;

    // Time-domain inputs
    reg  signed [15:0] s_re, s_im;
    reg  signed [15:0] h_re, h_im;
    reg  signed [15:0] w_re, w_im;
    reg         in_valid, in_last;
    wire        in_ready;

    // Config
    reg  [7:0]  config_data;
    reg         config_valid;
    wire        config_ready;

    // Outputs
    wire signed [15:0] Hs1_re, Hs1_im;
    wire        Hs1_valid, Hs1_last;

    // Memories for input samples
    reg [15:0] s_real_mem [0:63];
    reg [15:0] s_imag_mem [0:63];
    reg [15:0] h_real_mem [0:63];
    reg [15:0] h_imag_mem [0:63];
    reg [15:0] w_real_mem [0:63];
    reg [15:0] w_imag_mem [0:63];

    integer i;
    integer f_re, f_im;

    // DUT
    Hs1_cap dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_re(s_re), .s_im(s_im),
        .h_re(h_re), .h_im(h_im),
        .w_re(w_re), .w_im(w_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(in_ready),
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready),
        .Hs1_re(Hs1_re), .Hs1_im(Hs1_im),
        .Hs1_valid(Hs1_valid), .Hs1_last(Hs1_last)
    );

    // Clock generation: 100 MHz
    initial aclk = 0;
    always #5 aclk = ~aclk;

    // Reset sequence
    initial begin
        aresetn      = 0;
        in_valid     = 0;
        in_last      = 0;
        s_re = 0; s_im = 0;
        h_re = 0; h_im = 0;
        w_re = 0; w_im = 0;
        config_data  = 0;
        config_valid = 0;
        #100;  // hold reset
        aresetn = 1;
    end

    // Configure FFTs
    initial begin
        wait(aresetn == 1);
        @(posedge aclk);
        config_data  = 8'd1;   // FFT mode
        config_valid = 1'b1;
        wait(config_ready == 1'b1);
        @(posedge aclk);
        config_valid = 1'b0;
    end

    // Load input files
    initial begin
        $readmemb("s_real.txt", s_real_mem);
        $readmemb("s_imag.txt", s_imag_mem);
        $readmemb("h_real.txt", h_real_mem);
        $readmemb("h_imag.txt", h_imag_mem);
        $readmemb("w_real.txt", w_real_mem);
        $readmemb("w_imag.txt", w_imag_mem);
    end

    // Drive inputs to DUT
    initial begin
        wait(aresetn == 1);
        wait(config_ready == 1);
        #20;
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge aclk);
            while (!in_ready) @(posedge aclk); // stall until DUT ready
            in_valid <= 1;
            in_last  <= (i == 63);
            s_re <= s_real_mem[i];
            s_im <= s_imag_mem[i];
            h_re <= h_real_mem[i];
            h_im <= h_imag_mem[i];
            w_re <= w_real_mem[i];
            w_im <= w_imag_mem[i];
        end
        @(posedge aclk);
        in_valid <= 0;
        in_last  <= 0;
    end

    // Open output files
    initial begin
        f_re = $fopen("Hs1_real.txt", "w");
        f_im = $fopen("Hs1_imag.txt", "w");
        if (f_re == 0 || f_im == 0) begin
            $display("Error opening output files");
            $finish;
        end
    end

    // Capture outputs
    always @(posedge aclk) begin
        if (Hs1_valid) begin
            $fwrite(f_re, "%016b\n", Hs1_re);
            $fwrite(f_im, "%016b\n", Hs1_im);
        end
        if (Hs1_valid && Hs1_last) begin
            $fclose(f_re);
            $fclose(f_im);
            $stop;
        end
    end

endmodule
