`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: fft_divider_top_tb (Fixed-Point Scaled)
// Engineer:  Nageshwar Kumar
// Description:
//   - Generates 64 deterministic complex samples (A[k], B[k]) as real numbers.
//   - Converts them to Q9 fixed-point integers (val * 2^Q).
//   - Feeds into fft_divider_top one per clock cycle.
//   - Logs output results for MATLAB comparison.
//
// MATLAB equivalent vector generation included below for bit-accurate testing.
//////////////////////////////////////////////////////////////////////////////////

module fft_divider_top_tb;

    // ---- Parameters ----
    parameter N = 16;               // Bit width
    parameter Q = 9;                // Fractional bits
    parameter CLK_PERIOD = 10;      // Clock period (ns)

    // ---- DUT I/O ----
    reg clk, rstn;
    reg signed [N-1:0] in_a_re_fft, in_a_im_fft, in_b_re_fft, in_b_im_fft;
    reg in_valid_a, in_valid_b;
    wire signed [N-1:0] div_out_real, div_out_imag;
    wire div_out_valid, out_last;

    // ---- DUT ----
    fft_divider_top #(.N(N), .Q(Q)) uut (
        .clk(clk), .rstn(rstn),
        .in_a_re_fft(in_a_re_fft), .in_a_im_fft(in_a_im_fft),
        .in_b_re_fft(in_b_re_fft), .in_b_im_fft(in_b_im_fft),
        .in_valid_a(in_valid_a), .in_valid_b(in_valid_b),
        .div_out_real(div_out_real), .div_out_imag(div_out_imag),
        .div_out_valid(div_out_valid), .out_last(out_last)
    );

    // ---- Clock Generation ----
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---- Test Data ----
    reg signed [N-1:0] a_re [0:63];
    reg signed [N-1:0] a_im [0:63];
    reg signed [N-1:0] b_re [0:63];
    reg signed [N-1:0] b_im [0:63];

    integer i;
    real temp_a_re, temp_a_im, temp_b_re, temp_b_im;

    initial begin
        // ---- Reset ----
        rstn = 0;
        in_valid_a = 0;
        in_valid_b = 0;
        in_a_re_fft = 0; in_a_im_fft = 0;
        in_b_re_fft = 0; in_b_im_fft = 0;

        // ---- Generate 64 deterministic samples ----
        // You can replace these formulae with your own from MATLAB.
        // Just ensure you multiply by (1<<Q) and use $rtoi() for quantization.
        for (i = 0; i < 64; i = i + 1) begin
            temp_a_re = 0.05 * ((i * 8) - 256);   // Range: -12.8 .. +12.4
            temp_a_im = 0.04 * ((i * 4) - 128);   // Range: -5.12 .. +4.96
            temp_b_re = 0.1  * (i * 2);           // Range: 0.0 .. +12.6
            temp_b_im = 2.0;                      // Constant small imag

            a_re[i] = $rtoi(temp_a_re * (1 << Q)); // Fixed-point scaled
            a_im[i] = $rtoi(temp_a_im * (1 << Q));
            b_re[i] = $rtoi(temp_b_re * (1 << Q));
            b_im[i] = $rtoi(temp_b_im * (1 << Q));
        end

        #(5*CLK_PERIOD);
        rstn = 1;
        #(5*CLK_PERIOD);

        $display("[TB] Feeding 64 fixed-point complex samples to divider...");

        // ---- Feed the 64 samples ----
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            in_a_re_fft <= a_re[i];
            in_a_im_fft <= a_im[i];
            in_b_re_fft <= b_re[i];
            in_b_im_fft <= b_im[i];
            in_valid_a  <= 1;
            in_valid_b  <= 1;
        end

        @(posedge clk);
        in_valid_a <= 0;
        in_valid_b <= 0;
        $display("[TB] All 64 inputs fed. Waiting for divider outputs...");
    end

    // ---- Output Logging ----
    integer idx = 0;
    integer outfile;
    initial outfile = $fopen("rtl_outputs.txt", "w");

    always @(posedge clk) begin
        if (div_out_valid) begin
            $display("OUT[%0d]: Re=%0d  Im=%0d", idx, div_out_real, div_out_imag);
            $fwrite(outfile, "%0d %0d\n", div_out_real, div_out_imag);
            idx = idx + 1;
        end

        if (out_last) begin
            $display("[TB] All outputs received at t=%0t ns", $time);
            $fclose(outfile);
            #(10*CLK_PERIOD);
            $finish;
        end
    end

    // ---- Timeout Protection ----
    initial begin
        #(1_000_000);
        $display("[TB] Timeout! Divider did not finish in time.");
        $finish;
    end

endmodule
