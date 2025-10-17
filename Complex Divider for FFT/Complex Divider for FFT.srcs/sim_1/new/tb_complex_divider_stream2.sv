`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_complex_divider_fft64.v
// 64-point FFT validation testbench for complex_divider_stream
// User-defined test sequences without functions
//////////////////////////////////////////////////////////////////////////////////
module tb_complex_divider_stream2;

    // === Parameters (must match DUT) ===
    parameter IN_W       = 16;
    parameter FRAC       = 12;
    parameter RECIP_W    = 32;
    parameter RECIP_FRAC = 28;
    parameter FFT_SIZE   = 64;

    // === Signals ===
    reg clk, rstn;
    reg in_valid, in_last;
    reg signed [IN_W-1:0] a_real, a_imag, b_real, b_imag;
    wire signed [IN_W-1:0] out_real, out_imag;
    wire out_valid, out_last;

    // === DUT ===
    complex_divider_stream #(
        .IN_W(IN_W),
        .FRAC(FRAC),
        .RECIP_W(RECIP_W),
        .RECIP_FRAC(RECIP_FRAC)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .in_last(in_last),
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_real(out_real),
        .out_imag(out_imag)
    );

    // === Clock generation ===
    always #5 clk = ~clk;

    // === User-Defined 64-Point FFT Test Sequences ===
    reg signed [IN_W-1:0] fft1_real [0:63];
    reg signed [IN_W-1:0] fft1_imag [0:63];
    reg signed [IN_W-1:0] fft2_real [0:63];
    reg signed [IN_W-1:0] fft2_imag [0:63];

    // === Software reference results ===
    real SW_outR [0:63];
    real SW_outI [0:63];

    // === Test Results ===
    real maxErrR, maxErrI;
    real rms_errR, rms_errI;
    integer error_count;
    integer hw_index;

    // === Initialize User-Defined Test Sequences ===
    initial begin
        // Test Sequence 1: Simple frequency components
        fft1_real[0] =  4096; fft1_imag[0] =     0; fft2_real[0] =  4096; fft2_imag[0] =     0;  // DC component
        fft1_real[1] =  2048; fft1_imag[1] =  2048; fft2_real[1] =  2048; fft2_imag[1] =  2048;  // 45 degrees
        fft1_real[2] =     0; fft1_imag[2] =  4096; fft2_real[2] =     0; fft2_imag[2] =  4096;  // 90 degrees
        fft1_real[3] = -2048; fft1_imag[3] =  2048; fft2_real[3] = -2048; fft2_imag[3] =  2048;  // 135 degrees
        fft1_real[4] = -4096; fft1_imag[4] =     0; fft2_real[4] = -4096; fft2_imag[4] =     0;  // 180 degrees
        fft1_real[5] = -2048; fft1_imag[5] = -2048; fft2_real[5] = -2048; fft2_imag[5] = -2048;  // 225 degrees
        fft1_real[6] =     0; fft1_imag[6] = -4096; fft2_real[6] =     0; fft2_imag[6] = -4096;  // 270 degrees
        fft1_real[7] =  2048; fft1_imag[7] = -2048; fft2_real[7] =  2048; fft2_imag[7] = -2048;  // 315 degrees

        // Test Sequence 2: Various magnitudes
        fft1_real[8] =  8192; fft1_imag[8] =     0; fft2_real[8] =  4096; fft2_imag[8] =     0;  // 2x magnitude
        fft1_real[9] =  2048; fft1_imag[9] =     0; fft2_real[9] =  8192; fft2_imag[9] =     0;  // 0.5x magnitude
        fft1_real[10] = 1024; fft1_imag[10] =  512; fft2_real[10] =  512; fft2_imag[10] =  256; // small values
        fft1_real[11] = 16384; fft1_imag[11] = 8192; fft2_real[11] = 8192; fft2_imag[11] = 4096; // large values

        // Test Sequence 3: Real-world FFT patterns (bins 12-31)
        fft1_real[12] =  5678; fft1_imag[12] =  1234; fft2_real[12] =  3456; fft2_imag[12] =  2345;
        fft1_real[13] = -1234; fft1_imag[13] =  5678; fft2_real[13] =  2345; fft2_imag[13] = -3456;
        fft1_real[14] =  4321; fft1_imag[14] = -9876; fft2_real[14] = -1234; fft2_imag[14] =  5678;
        fft1_real[15] = -8765; fft1_imag[15] =  4321; fft2_real[15] =  6789; fft2_imag[15] = -1234;
        fft1_real[16] =  2468; fft1_imag[16] =  1357; fft2_real[16] =  1234; fft2_imag[16] =  5678;
        fft1_real[17] = -1357; fft1_imag[17] =  2468; fft2_real[17] =  5678; fft2_imag[17] = -1234;
        fft1_real[18] =  3579; fft1_imag[18] = -2468; fft2_real[18] = -1357; fft2_imag[18] =  2468;
        fft1_real[19] = -4680; fft1_imag[19] =  3579; fft2_real[19] =  2468; fft2_imag[19] = -1357;
        fft1_real[20] =  1234; fft1_imag[20] =  5678; fft2_real[20] =  2345; fft2_imag[20] =  3456;
        fft1_real[21] = -5678; fft1_imag[21] =  1234; fft2_real[21] =  3456; fft2_imag[21] = -2345;
        fft1_real[22] =  9876; fft1_imag[22] = -4321; fft2_real[22] = -5678; fft2_imag[22] =  1234;
        fft1_real[23] = -4321; fft1_imag[23] =  9876; fft2_real[23] =  1234; fft2_imag[23] = -5678;
        fft1_real[24] =  1357; fft1_imag[24] =  2468; fft2_real[24] =  5678; fft2_imag[24] =  1234;
        fft1_real[25] = -2468; fft1_imag[25] =  1357; fft2_real[25] =  1234; fft2_imag[25] = -5678;
        fft1_real[26] =  3579; fft1_imag[26] = -1357; fft2_real[26] = -2468; fft2_imag[26] =  1357;
        fft1_real[27] = -4680; fft1_imag[27] =  3579; fft2_real[27] =  1357; fft2_imag[27] = -2468;
        fft1_real[28] =  2345; fft1_imag[28] =  6789; fft2_real[28] =  3456; fft2_imag[28] =  4567;
        fft1_real[29] = -6789; fft1_imag[29] =  2345; fft2_real[29] =  4567; fft2_imag[29] = -3456;
        fft1_real[30] =  9876; fft1_imag[30] = -5432; fft2_real[30] = -6789; fft2_imag[30] =  2345;
        fft1_real[31] = -5432; fft1_imag[31] =  9876; fft2_real[31] =  2345; fft2_imag[31] = -6789;

        // Test Sequence 4: Edge cases and stress tests (bins 32-47)
        fft1_real[32] =  1; fft1_imag[32] =  1; fft2_real[32] =  4096; fft2_imag[32] =  4096;  // very small numerator
        fft1_real[33] =  16383; fft1_imag[33] =  16383; fft2_real[33] =  1; fft2_imag[33] =  1;  // very small denominator
        fft1_real[34] = -16384; fft1_imag[34] = -16384; fft2_real[34] =  8192; fft2_imag[34] =  8192;  // max negative
        fft1_real[35] =  16383; fft1_imag[35] =  16383; fft2_real[35] =  16383; fft2_imag[35] =  16383;  // max positive
        fft1_real[36] =  100; fft1_imag[36] =  200; fft2_real[36] =  300; fft2_imag[36] =  400;
        fft1_real[37] = -100; fft1_imag[37] = -200; fft2_real[37] = -300; fft2_imag[37] = -400;
        fft1_real[38] =  500; fft1_imag[38] = -600; fft2_real[38] = -700; fft2_imag[38] =  800;
        fft1_real[39] = -500; fft1_imag[39] =  600; fft2_real[39] =  700; fft2_imag[39] = -800;
        fft1_real[40] =  1111; fft1_imag[40] =  2222; fft2_real[40] =  3333; fft2_imag[40] =  4444;
        fft1_real[41] = -1111; fft1_imag[41] = -2222; fft2_real[41] = -3333; fft2_imag[41] = -4444;
        fft1_real[42] =  5555; fft1_imag[42] = -6666; fft2_real[42] = -7777; fft2_imag[42] =  8888;
        fft1_real[43] = -5555; fft1_imag[43] =  6666; fft2_real[43] =  7777; fft2_imag[43] = -8888;
        fft1_real[44] =  999; fft1_imag[44] =  888; fft2_real[44] =  777; fft2_imag[44] =  666;
        fft1_real[45] = -999; fft1_imag[45] = -888; fft2_real[45] = -777; fft2_imag[45] = -666;
        fft1_real[46] =  444; fft1_imag[46] = -333; fft2_real[46] = -222; fft2_imag[46] =  111;
        fft1_real[47] = -444; fft1_imag[47] =  333; fft2_real[47] =  222; fft2_imag[47] = -111;

        // Test Sequence 5: Fill remaining points with varied patterns (bins 48-63)
        fft1_real[48] =  2500; fft1_imag[48] =  1500; fft2_real[48] =  3500; fft2_imag[48] =  2500;
        fft1_real[49] = -2500; fft1_imag[49] =  1500; fft2_real[49] =  3500; fft2_imag[49] = -2500;
        fft1_real[50] =  1500; fft1_imag[50] = -2500; fft2_real[50] = -3500; fft2_imag[50] =  2500;
        fft1_real[51] = -1500; fft1_imag[51] = -2500; fft2_real[51] = -3500; fft2_imag[51] = -2500;
        fft1_real[52] =  3000; fft1_imag[52] =  2000; fft2_real[52] =  1000; fft2_imag[52] =  4000;
        fft1_real[53] = -3000; fft1_imag[53] =  2000; fft2_real[53] =  1000; fft2_imag[53] = -4000;
        fft1_real[54] =  2000; fft1_imag[54] = -3000; fft2_real[54] = -1000; fft2_imag[54] =  4000;
        fft1_real[55] = -2000; fft1_imag[55] = -3000; fft2_real[55] = -1000; fft2_imag[55] = -4000;
        fft1_real[56] =  4000; fft1_imag[56] =  1000; fft2_real[56] =  2000; fft2_imag[56] =  3000;
        fft1_real[57] = -4000; fft1_imag[57] =  1000; fft2_real[57] =  2000; fft2_imag[57] = -3000;
        fft1_real[58] =  1000; fft1_imag[58] = -4000; fft2_real[58] = -2000; fft2_imag[58] =  3000;
        fft1_real[59] = -1000; fft1_imag[59] = -4000; fft2_real[59] = -2000; fft2_imag[59] = -3000;
        fft1_real[60] =  3500; fft1_imag[60] =  500; fft2_real[60] =  4500; fft2_imag[60] =  1500;
        fft1_real[61] = -3500; fft1_imag[61] =  500; fft2_real[61] =  4500; fft2_imag[61] = -1500;
        fft1_real[62] =  500; fft1_imag[62] = -3500; fft2_real[62] = -4500; fft2_imag[62] =  1500;
        fft1_real[63] = -500; fft1_imag[63] = -3500; fft2_real[63] = -4500; fft2_imag[63] = -1500;

        // Compute software reference results
        for (integer i = 0; i < 64; i = i + 1) begin
            real ar, ai, br, bi, denom;
            ar = $itor(fft1_real[i]) / (1 << FRAC);
            ai = $itor(fft1_imag[i]) / (1 << FRAC);
            br = $itor(fft2_real[i]) / (1 << FRAC);
            bi = $itor(fft2_imag[i]) / (1 << FRAC);
            
            denom = br * br + bi * bi;
            if (denom == 0.0) denom = 0.0001;
            
            SW_outR[i] = (ar * br + ai * bi) / denom;
            SW_outI[i] = (ai * br - ar * bi) / denom;
        end

        $display("User-defined 64-point FFT test sequences initialized");
    end

    // === Stimulus ===
    initial begin
        clk = 0; rstn = 0; in_valid = 0; in_last = 0;
        a_real = 0; a_imag = 0; b_real = 0; b_imag = 0;
        maxErrR = 0; maxErrI = 0;
        rms_errR = 0; rms_errI = 0;
        error_count = 0;
        hw_index = 0;

        #100; rstn = 1;
        $display("\n===== Starting 64-Point FFT Complex Divider Validation =====");
        $display("FFT Size: %0d points", FFT_SIZE);
        $display("Data Format: Q%0d (%0d-bit signed)", FRAC, IN_W);

        repeat(10) @(posedge clk);

        // Stream 64 FFT points
        $display("\nStreaming 64 FFT points through complex divider...");
        for (integer n = 0; n < 64; n = n + 1) begin
            @(posedge clk);
            in_valid <= 1;
            in_last  <= (n == 63);

            a_real <= fft1_real[n];
            a_imag <= fft1_imag[n];
            b_real <= fft2_real[n];
            b_imag <= fft2_imag[n];

            if (n < 5) begin
                $display("Point %0d: A=(%6d,%6d) B=(%6d,%6d)", 
                         n, fft1_real[n], fft1_imag[n], fft2_real[n], fft2_imag[n]);
            end
        end

        @(posedge clk);
        in_valid <= 0;
        in_last  <= 0;

        $display("... (streaming continues) ...");
        $display("Waiting for pipeline to flush...");

        repeat(RECIP_FRAC + 50) @(posedge clk);

        $display("===== FFT Validation Complete =====\n");
    end

    // === Output Monitor + Error Calculation ===
    always @(posedge clk) begin
        if (out_valid) begin
            real hwR, hwI, errR, errI, abs_errR, abs_errI;
            
            hwR = $itor(out_real) / (1.0 * (1 << FRAC));
            hwI = $itor(out_imag) / (1.0 * (1 << FRAC));

            if (hw_index < 64) begin
                errR = hwR - SW_outR[hw_index];
                errI = hwI - SW_outI[hw_index];
                
                abs_errR = (errR < 0) ? -errR : errR;
                abs_errI = (errI < 0) ? -errI : errI;

                if (abs_errR > maxErrR) maxErrR = abs_errR;
                if (abs_errI > maxErrI) maxErrI = abs_errI;

                rms_errR = rms_errR + errR * errR;
                rms_errI = rms_errI + errI * errI;
                error_count = error_count + 1;

                if (hw_index < 8 || hw_index >= 56) begin
                    $display("FFT[%2d] HW=(%8.4f,%8.4f) SW=(%8.4f,%8.4f) ErrR=%8.4e ErrI=%8.4e",
                             hw_index, hwR, hwI, SW_outR[hw_index], SW_outI[hw_index], errR, errI);
                end
            end
            hw_index = hw_index + 1;

            if (out_last) begin
                rms_errR = $sqrt(rms_errR / error_count);
                rms_errI = $sqrt(rms_errI / error_count);

                $display("\n" + "="*60);
                $display("64-POINT FFT DIVIDER VALIDATION REPORT");
                $display("="*60);
                $display("Maximum Absolute Errors:");
                $display("  Real: %10.4e", maxErrR);
                $display("  Imag: %10.4e", maxErrI);
                $display("");
                $display("RMS Errors:");
                $display("  Real: %10.4e", rms_errR);
                $display("  Imag: %10.4e", rms_errI);
                $display("");
                $display("Test Points: %0d", error_count);
                $display("="*60);
                
                #100;
                $finish;
            end
        end
    end

endmodule