`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar
// Date:      22 Oct 2025
// Design:    Signed Fixed-Point Divider Wrapper Testbench (Q7.9)
// Description:
//   Tests multiple signed divisions in a loop.
//   Automatically converts real test values to Q-format and runs each test.
////////////////////////////////////////////////////////////////////////////////

module tb_q_div_wrapper_us;

    // Parameters
    parameter Q = 9;
    parameter N = 16;
    localparam SCALE = 1 << Q;

    // Inputs
    reg  [N-1:0] i_dividend_s;
    reg  [N-1:0] i_divisor_s;
    reg          i_start;
    reg          i_clk;
    reg          i_rst;

    // Outputs
    wire [N-1:0] o_quotient_out_s;
    wire         o_complete;
    wire         o_overflow;

    // Instantiate DUT
    q_div_wrapper_us #(.Q(Q), .N(N)) uut (
        .i_dividend_s(i_dividend_s),
        .i_divisor_s(i_divisor_s),
        .i_start(i_start),
        .i_clk(i_clk),
        .i_rstn(i_rst),
        .o_quotient_out_s(o_quotient_out_s),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk;  // 250 MHz
    end

    // ---------------------------------------------------------------------
    // Helper functions
    // ---------------------------------------------------------------------

    // Convert real ? Q-format (signed)
    function [N-1:0] toQ;
        input real value;
        begin
            toQ = $rtoi(value * SCALE);
        end
    endfunction

    // Convert Q-format ? real
    function real fromQ;
        input [N-1:0] qval;
        begin
            fromQ = $itor($signed(qval)) / SCALE;
        end
    endfunction

    // ---------------------------------------------------------------------
    // Test array setup
    // ---------------------------------------------------------------------
    integer i;
    real dividend_list [0:7];
    real divisor_list  [0:7];
    integer num_tests;

    initial begin
        // === Reset ===
        i_rst   = 0;
        i_start = 0;
        #10 i_rst = 1;  // active-high reset

        // === Define test list ===
        num_tests = 8;
        dividend_list[0] =  3.75; divisor_list[0] =  1.75;
        dividend_list[1] = -3.75; divisor_list[1] =  1.75;
        dividend_list[2] =  3.75; divisor_list[2] = -1.75;
        dividend_list[3] = -3.75; divisor_list[3] = -1.75;
        dividend_list[4] =  4.25; divisor_list[4] =  2.00;
        dividend_list[5] = -4.25; divisor_list[5] =  2.00;
        dividend_list[6] =  1.50; divisor_list[6] =  3.00;
        dividend_list[7] =  5.00; divisor_list[7] =  0.00; // divide-by-zero case

        // === Run tests ===
        $display("\n==================================================");
        $display("   Signed Fixed-Point Division Multi-Test (Q7.%0d)", Q);
        $display("==================================================\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            run_case(toQ(dividend_list[i]), toQ(divisor_list[i]),
                     dividend_list[i], divisor_list[i], i);
        end

        $display("\n==================================================");
        $display("        All %0d Signed Division Tests Complete", num_tests);
        $display("==================================================\n");
        #100 $finish;
    end

    // ---------------------------------------------------------------------
    // Task: Run a single division and display results
    // ---------------------------------------------------------------------
    task automatic run_case(
        input [N-1:0] dividend_q,
        input [N-1:0] divisor_q,
        input real dividend_real,
        input real divisor_real,
        input integer idx
    );
        real quotient_real;
    begin
        $display("--------------------------------------------------");
        $display("Test #%0d: %f / %f", idx, dividend_real, divisor_real);
        $display("--------------------------------------------------");

        i_dividend_s = dividend_q;
        i_divisor_s  = divisor_q;

        // Start pulse
        @(posedge i_clk);
        i_start = 1;
        @(posedge i_clk);
        i_start = 0;

        // Wait for completion
        wait(o_complete);

        quotient_real = fromQ(o_quotient_out_s);

        // Display results
        $display("Dividend = %f   (%b)", dividend_real, i_dividend_s);
        $display("Divisor  = %f   (%b)", divisor_real,  i_divisor_s);
        $display("Quotient = %f   (%b)", quotient_real, o_quotient_out_s);
        $display("Overflow = %b", o_overflow);
        if (divisor_real != 0.0)
            $display("Expected ? %f", dividend_real / divisor_real);
        else
            $display("Expected : Divide-by-zero");
        $display("--------------------------------------------------\n");

        // Wait a few clocks before next test
        repeat (5) @(posedge i_clk);
    end
    endtask

endmodule
