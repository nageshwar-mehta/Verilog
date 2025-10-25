`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar
// Date:      25 Oct 2025
// Design:    Complete Testbench for Complex Divider (Q7.9)
// Description:
//   Runs multiple tests for (A + jB) / (C + jD).
//   Covers positive, negative, zero, and mixed sign cases.
//   ASCII-safe and syntax clean for Vivado / ModelSim.
////////////////////////////////////////////////////////////////////////////////

module tb_complex_divider_s;

    // Parameters
    parameter Q = 9;
    parameter N = 16;
    localparam SCALE = 1 << Q;

    // DUT signals
    reg  signed [N-1:0] a_re, a_im;   // numerator: A + jB
    reg  signed [N-1:0] b_re, b_im;   // denominator: C + jD
    reg  i_start, i_clk, i_rstn;
    wire signed [N-1:0] o_re, o_im;
    wire o_valid, o_busy;

    // Instantiate DUT
    complex_divider_s #(.Q(Q), .N(N)) uut (
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_start(i_start),
        .a_re(a_re),
        .a_im(a_im),
        .b_re(b_re),
        .b_im(b_im),
        .o_re(o_re),
        .o_im(o_im),
        .o_valid(o_valid),
        .o_busy(o_busy)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk;  // 250 MHz clock
    end

    // Conversion helper functions
    function [N-1:0] toQ(input real val);
        toQ = $rtoi(val * SCALE);
    endfunction

    function real fromQ(input [N-1:0] val);
        fromQ = $itor($signed(val)) / SCALE;
    endfunction

    // ---------------------------------------------------------------
    // Test setup
    // ---------------------------------------------------------------
    integer i;
    real A_re_list [0:9];
    real A_im_list [0:9];
    real B_re_list [0:9];
    real B_im_list [0:9];
    integer num_tests;

    initial begin
        // Reset
        i_rstn = 0;
        i_start = 0;
        #10 i_rstn = 1;
        #5;

        $display("\n================ COMPLEX DIVIDER TEST (Q7.%0d) ================\n", Q);

        // Define test cases (10 examples)
        num_tests = 10;

        // Basic positive and negative combinations
        A_re_list[0]=3.0;  A_im_list[0]=2.0;  B_re_list[0]=1.0;  B_im_list[0]=1.0;
        A_re_list[1]=-3.0; A_im_list[1]=2.0;  B_re_list[1]=1.0;  B_im_list[1]=1.0;
        A_re_list[2]=3.0;  A_im_list[2]=-2.0; B_re_list[2]=1.0;  B_im_list[2]=1.0;
        A_re_list[3]=-3.0; A_im_list[3]=-2.0; B_re_list[3]=1.0;  B_im_list[3]=1.0;

        // Negative denominators
        A_re_list[4]=3.0;  A_im_list[4]=2.0;  B_re_list[4]=-1.0; B_im_list[4]=1.0;
        A_re_list[5]=3.0;  A_im_list[5]=2.0;  B_re_list[5]=1.0;  B_im_list[5]=-1.0;

        // Pure real / pure imaginary
        A_re_list[6]=3.0;  A_im_list[6]=0.0;  B_re_list[6]=1.0;  B_im_list[6]=1.0;
        A_re_list[7]=0.0;  A_im_list[7]=3.0;  B_re_list[7]=1.0;  B_im_list[7]=1.0;

        // Divide-by-zero and mixed
        A_re_list[8]=3.0;  A_im_list[8]=2.0;  B_re_list[8]=0.0;  B_im_list[8]=0.0;
        A_re_list[9]=4.0;  A_im_list[9]=1.0;  B_re_list[9]=2.0;  B_im_list[9]=3.0;

        // Run all test cases
        for (i = 0; i < num_tests; i = i + 1) begin
            run_case(i, A_re_list[i], A_im_list[i], B_re_list[i], B_im_list[i]);
        end

        $display("\n================ ALL TESTS DONE =================\n");
        #50 $finish;
    end

    // ---------------------------------------------------------------
    // Simple task to perform one division
    // ---------------------------------------------------------------
    task run_case(
        input integer idx,
        input real a_re_r,
        input real a_im_r,
        input real b_re_r,
        input real b_im_r
    );
        real re_out, im_out;
    begin
        $display("--------------------------------------------------");
        $display("Test #%0d: (%f + j%f) / (%f + j%f)", idx, a_re_r, a_im_r, b_re_r, b_im_r);

        // Convert to fixed-point
        a_re = toQ(a_re_r);
        a_im = toQ(a_im_r);
        b_re = toQ(b_re_r);
        b_im = toQ(b_im_r);

        // Trigger start pulse
        @(posedge i_clk);
        i_start = 1;
        @(posedge i_clk);
        i_start = 0;

        // Wait until result is ready
        wait(o_valid);
        re_out = fromQ(o_re);
        im_out = fromQ(o_im);

        // Print outputs
        $display("Output: Re = %f, Im = %f", re_out, im_out);
        $display("--------------------------------------------------\n");
        #10;
    end
    endtask

endmodule
