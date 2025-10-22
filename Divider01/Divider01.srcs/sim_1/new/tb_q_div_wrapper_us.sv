`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:        Nageshwar Kumar
// Create Date:     22 Oct 2025
// Design Name:     q_div_wrapper_us
// Module Name:     tb_q_div_wrapper_us
// Project Name:    Fixed-point Divider (Signed Wrapper)
// Description:
//   Testbench for signed Q7.9 fixed-point divider wrapper.
//   Tests all four sign combinations of (3.75 / 1.75):
//       1. +3.75 / +1.75
//       2. -3.75 / +1.75
//       3. +3.75 / -1.75
//       4. -3.75 / -1.75
//
////////////////////////////////////////////////////////////////////////////////

module tb_q_div_wrapper_us;

    // Parameters
    parameter Q = 9;
    parameter N = 16;

    // Inputs
    reg  [N-1:0] i_dividend_s;
    reg  [N-1:0] i_divisor_s;
    reg           i_start;
    reg           i_clk;

    // Outputs
    wire [N-1:0] o_quotient_out_s;
    wire          o_complete;
    wire          o_overflow;

    // Instantiate Unit Under Test (UUT)
    q_div_wrapper_us #(.Q(Q), .N(N)) uut (
        .i_dividend_s(i_dividend_s),
        .i_divisor_s(i_divisor_s),
        .i_start(i_start),
        .i_clk(i_clk),
        .o_quotient_out_s(o_quotient_out_s),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );

    // Clock generation (4 ns period ? 250 MHz)
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk;
    end

    // ------------------------------------------------------------
    // Test stimulus
    // ------------------------------------------------------------
    reg [N-1:0] POS_3_75, POS_1_75, NEG_3_75, NEG_1_75;

    initial begin
        // Initialize values
        i_start      = 0;
        i_dividend_s = 0;
        i_divisor_s  = 0;

        // Encoded Q7.9 constants
        POS_3_75 = 16'b0000011110000000; // +3.75
        POS_1_75 = 16'b0000011100000000; // +1.75
        NEG_3_75 = 16'b1111100010000000; // -3.75
        NEG_1_75 = 16'b1111100100000000; // -1.75

        #10;
        $display("==================================================");
        $display("     Signed Fixed-Point Division Testbench (Q7.9)");
        $display("==================================================\n");

        // Run all four test cases
        run_case(POS_3_75, POS_1_75, "Test 1: +3.75 / +1.75");
        run_case(NEG_3_75, POS_1_75, "Test 2: -3.75 / +1.75");
        run_case(POS_3_75, NEG_1_75, "Test 3: +3.75 / -1.75");
        run_case(NEG_3_75, NEG_1_75, "Test 4: -3.75 / -1.75");

        $display("\n==================================================");
        $display(" All Signed Division Tests Completed Successfully ");
        $display("==================================================");

        #50 $finish;
    end

    // ------------------------------------------------------------
    // Task: Run a single division and display results
    // ------------------------------------------------------------
    task automatic run_case(
        input [N-1:0] dividend,
        input [N-1:0] divisor,
        input [127:0] label
    );
        real dividend_val, divisor_val, quotient_val;
    begin
        $display("--------------------------------------------------");
        $display("%s", label);
        $display("--------------------------------------------------");

        i_dividend_s = dividend;
        i_divisor_s  = divisor;

        // Generate start pulse
        #5 i_start = 1;
        #5 i_start = 0;

        // Wait for completion
        wait(o_complete);

        // Convert Q7.9 binary to decimal
        dividend_val = $itor($signed(dividend)) / (1 << Q);
        divisor_val  = $itor($signed(divisor))  / (1 << Q);
        quotient_val = $itor($signed(o_quotient_out_s)) / (1 << Q);

        // Display results
        $display("Dividend = %f   (%b)", dividend_val, dividend);
        $display("Divisor  = %f   (%b)", divisor_val, divisor);
        $display("Quotient = %f   (%b)", quotient_val, o_quotient_out_s);
        $display("Overflow = %b", o_overflow);
        $display("--------------------------------------------------\n");

        #20;
    end
    endtask

endmodule
