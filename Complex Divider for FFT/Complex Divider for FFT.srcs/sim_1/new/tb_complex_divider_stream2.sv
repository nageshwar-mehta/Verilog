`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_complex_divider_stream.v
// Precision-check testbench for complex_divider_stream
// Compares hardware fixed-point outputs with floating-point (double) results
//////////////////////////////////////////////////////////////////////////////////
module tb_complex_divider_stream2;

    // === Parameters (must match DUT) ===
    parameter IN_W       = 16;
    parameter FRAC       = 12;
    parameter RECIP_W    = 32;
    parameter RECIP_FRAC = 28;

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

    // === Software model arrays ===
    real SW_Are [0:1023];
    real SW_Aim [0:1023];
    real SW_Bre [0:1023];
    real SW_Bim [0:1023];
    real SW_outR [0:1023];
    real SW_outI [0:1023];
    integer sample_count = 0;
    integer i;

    // === Common real variables ===
    real denom;
    real hwR, hwI, errR, errI;
    real maxErrR, maxErrI;

    // === Stimulus ===
    initial begin
        clk = 0; rstn = 0; in_valid = 0; in_last = 0;
        a_real = 0; a_imag = 0; b_real = 0; b_imag = 0;
        maxErrR = 0; maxErrI = 0;

        #40; rstn = 1;
        $display("\n===== Starting Precision-Check Simulation =====");

        // Feed 64 test samples
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            in_valid <= 1;
            in_last  <= (i==63);

            // Random but bounded complex numbers (avoid zero divisor)
            a_real <= $signed($random % 1000);
            a_imag <= $signed($random % 1000);
            b_real <= ($random % 900) + 50;
            b_imag <= ($random % 900) + 50;

            // Convert to real for SW reference
            SW_Are[i] = a_real / (1.0 * (1 << FRAC));
            SW_Aim[i] = a_imag / (1.0 * (1 << FRAC));
            SW_Bre[i] = b_real / (1.0 * (1 << FRAC));
            SW_Bim[i] = b_imag / (1.0 * (1 << FRAC));

            // Floating-point division
            denom = (SW_Bre[i]*SW_Bre[i]) + (SW_Bim[i]*SW_Bim[i]);
            if (denom == 0.0) denom = 1e-9; // avoid divide-by-zero in simulation
            SW_outR[i] = (SW_Are[i]*SW_Bre[i] + SW_Aim[i]*SW_Bim[i]) / denom;
            SW_outI[i] = (SW_Aim[i]*SW_Bre[i] - SW_Are[i]*SW_Bim[i]) / denom;

            sample_count = i+1;
        end

        @(posedge clk);
        in_valid <= 0;
        in_last  <= 0;

        // Wait for pipeline flush
        repeat(RECIP_FRAC + 50) @(posedge clk);

        $display("===== Simulation Complete =====\n");
        $display("===== FINAL PRECISION REPORT =====");
        $display("Max |ErrR| = %8.4e", maxErrR);
        $display("Max |ErrI| = %8.4e", maxErrI);
        $finish;
    end

    // === Output Monitor + Error Calculation ===
    integer hw_index = 0;

    always @(posedge clk) begin
        if (out_valid) begin
            hwR = out_real / (1.0 * (1 << FRAC));
            hwI = out_imag / (1.0 * (1 << FRAC));

            if (hw_index < sample_count) begin
                errR = hwR - SW_outR[hw_index];
                errI = hwI - SW_outI[hw_index];

                // Track maximum errors
                if (errR < 0) errR = -errR;
                if (errI < 0) errI = -errI;
                if (errR > maxErrR) maxErrR = errR;
                if (errI > maxErrI) maxErrI = errI;

                // Display both results
                $display("t=%0t | Sample=%0d | HW=(%8.4f,%8.4f) | SW=(%8.4f,%8.4f) | ErrR=%8.4e | ErrI=%8.4e%s",
                         $time, hw_index, hwR, hwI,
                         SW_outR[hw_index], SW_outI[hw_index],
                         hwR - SW_outR[hw_index], hwI - SW_outI[hw_index],
                         out_last ? " <-- LAST" : "");
            end
            hw_index = hw_index + 1;
        end
    end

endmodule
