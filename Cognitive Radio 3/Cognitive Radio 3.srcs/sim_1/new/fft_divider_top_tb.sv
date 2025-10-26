`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar
// Date:      26 Oct 2025
// Design:    Self-checking Testbench for fft_divider_top
// Description:
//   Automatically verifies hardware outputs against software model results.
//   Compares each (a+j*b) / (c+j*d) result and reports pass/fail per sample.
////////////////////////////////////////////////////////////////////////////////

module fft_divider_top_tb;

    // ---------------- Parameters ----------------
    parameter WIDTH = 16;
    parameter Q = 9;
    localparam SCALE = 1 << Q;

    // ---------------- Signals -------------------
    reg clk, rstn, start, in_valid;
    reg signed [WIDTH-1:0] in_a_real, in_a_imag;
    reg signed [WIDTH-1:0] in_b_real, in_b_imag;

    wire signed [WIDTH-1:0] div_out_real, div_out_imag;
    wire div_out_valid, out_last;

    // ---------------- DUT Instance ----------------
    fft_divider_top #(.N(WIDTH), .Q(Q)) dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .in_a_real(in_a_real),
        .in_a_imag(in_a_imag),
        .in_b_real(in_b_real),
        .in_b_imag(in_b_imag),
        .in_valid(in_valid),
        .div_out_real(div_out_real),
        .div_out_imag(div_out_imag),
        .div_out_valid(div_out_valid),
        .out_last(out_last)
    );

    // ---------------- Clock Generation ----------------
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz clock

    // ---------------- Reset Logic ----------------
    initial begin
        rstn = 0;
        start = 0;
        in_valid = 0;
        in_a_real = 0; in_a_imag = 0;
        in_b_real = 0; in_b_imag = 0;
        repeat(3) @(posedge clk);
        rstn = 1;
    end

    // ---------------- Input Generation ----------------
    integer i;
    real A_re[0:63], A_im[0:63];
    real B_re[0:63], B_im[0:63];
    real REF_re[0:63], REF_im[0:63];

    // Function: Convert Q to real
    function real fromQ;
        input signed [WIDTH-1:0] val;
        begin
            fromQ = $itor(val) / SCALE;
        end
    endfunction

    // Function: Convert real to Q
    function signed [WIDTH-1:0] toQ;
        input real val;
        begin
            toQ = $rtoi(val * SCALE);
        end
    endfunction

    // ---------------- Initialize test data ----------------
    initial begin
        // Simple test patterns (could be FFT outputs)
        for (i = 0; i < 64; i = i + 1) begin
            A_re[i] = 2.0 + 0.05*i;
            A_im[i] = 1.0 - 0.03*i;
            B_re[i] = 1.0 + 0.02*i;
            B_im[i] = 0.5 + 0.01*i;
        end
    end

    // ---------------- Feed data to DUT ----------------
    initial begin
        @(posedge rstn);
        @(posedge clk);

        start = 1;
        @(posedge clk);
        start = 0;

        in_valid = 1'b1;
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            in_a_real = toQ(A_re[i]);
            in_a_imag = toQ(A_im[i]);
            in_b_real = toQ(B_re[i]);
            in_b_imag = toQ(B_im[i]);
        end

        @(posedge clk);
        in_valid = 0;
        in_a_real = 0;
        in_a_imag = 0;
        in_b_real = 0;
        in_b_imag = 0;
    end

    // ---------------- Software Reference Model ----------------
    integer j;
    initial begin
        for (j = 0; j < 64; j = j + 1) begin : ref_calc
            automatic real a_r = A_re[j];
            automatic real a_i = A_im[j];
            automatic real b_r = B_re[j];
            automatic real b_i = B_im[j];
            automatic real denom = (b_r*b_r + b_i*b_i);

            if (denom != 0) begin
                REF_re[j] = (a_r*b_r + a_i*b_i) / denom;
                REF_im[j] = (a_i*b_r - a_r*b_i) / denom;
            end else begin
                REF_re[j] = 0;
                REF_im[j] = 0;
            end
        end
    end

    // ---------------- Self-Checking Logic ----------------
    integer k, pass_count, fail_count;
    real hw_re, hw_im, err_re, err_im;

    initial begin
        pass_count = 0;
        fail_count = 0;

        wait(div_out_valid); // Wait for first output

        forever begin
            @(posedge clk);
            if (div_out_valid) begin
                hw_re = fromQ(div_out_real);
                hw_im = fromQ(div_out_imag);
                err_re = hw_re - REF_re[k];
                err_im = hw_im - REF_im[k];

                if ((err_re < 0.02 && err_re > -0.02) && (err_im < 0.02 && err_im > -0.02)) begin
                    pass_count = pass_count + 1;
                    $display("PASS[%0d]: Re=%f Im=%f | Ref: Re=%f Im=%f", 
                              k, hw_re, hw_im, REF_re[k], REF_im[k]);
                end else begin
                    fail_count = fail_count + 1;
                    $display("FAIL[%0d]: Re=%f Im=%f | Ref: Re=%f Im=%f", 
                              k, hw_re, hw_im, REF_re[k], REF_im[k]);
                end
                k = k + 1;
            end

            if (out_last) begin
                $display("==================================================");
                $display("Simulation Complete: PASS=%0d, FAIL=%0d", pass_count, fail_count);
                $display("==================================================");
                #50 $finish;
            end
        end
    end

endmodule
