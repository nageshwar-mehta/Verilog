`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:        Nageshwar Kumar
// Create Date:     22 Oct 2025
// Design Name:     qdiv_unsigned
// Module Name:     TestDiv_unsigned.v
// Project Name:    Fixed-point Divider (Unsigned)
// Description:     Multi-testbench for qdiv_unsigned.v (Q7.9 fixed-point)
//
// This testbench runs multiple divisions automatically.
// Example: (3.75 / 1.75), (2.50 / 0.75), (1.00 / 3.50), etc.
////////////////////////////////////////////////////////////////////////////////

module TestDiv_unsigned;

    // Parameters for fixed-point format
    localparam integer Q = 9;
    localparam integer N = 16;
    localparam real SCALE = 2.0**Q;

    // Inputs
    reg [N-1:0] i_dividend;
    reg [N-1:0] i_divisor;
    reg         i_start;
    reg         i_clk;
    reg         i_rst;

    // Outputs
    wire [N-1:0] o_quotient_out;
    wire         o_complete;
    wire         o_overflow;

    // Instantiate DUT
    qdiv_unsigned #(.Q(Q), .N(N)) uut (
        .i_dividend(i_dividend),
        .i_divisor(i_divisor),
        .i_start(i_start),
        .i_clk(i_clk),
        .rstn(i_rst),             // active-low reset
        .o_quotient_out(o_quotient_out),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk; // 250 MHz clock
    end

    // === Helper Tasks ===
    // Converts real value to Q-format
    function [N-1:0] toQ;
        input real value;
        toQ = $rtoi(value * SCALE);
    endfunction

    // Converts Q-format to real
    function real fromQ;
        input [N-1:0] qvalue;
        fromQ = qvalue / SCALE;
    endfunction

    // === Multi-test procedure ===
    integer i;
    real dividend_real [0:4];
    real divisor_real  [0:4];

    initial begin
        // Initialize reset
        i_rst = 0;
        i_start = 0;
        #10 i_rst = 1; // release reset

        // === Define test cases ===
        dividend_real[0] = 3.75; divisor_real[0] = 1.75;
        dividend_real[1] = 2.50; divisor_real[1] = 0.75;
        dividend_real[2] = 1.00; divisor_real[2] = 3.50;
        dividend_real[3] = 4.25; divisor_real[3] = 2.00;
        dividend_real[4] = 5.00; divisor_real[4] = 0.00; // divide-by-zero test

        // === Run all tests ===
        $display("\n=== Fixed-Point Division Tests (Q7.%0d) ===", Q);
        for (i = 0; i < 5; i = i + 1) begin
            i_dividend = toQ(dividend_real[i]);
            i_divisor  = toQ(divisor_real[i]);

            $display("\nTest #%0d:", i);
            $display("Dividend = %f, Divisor = %f", dividend_real[i], divisor_real[i]);

            // Start division
            @(posedge i_clk);
            i_start = 1;
            @(posedge i_clk);
            i_start = 0;

            // Wait for completion
            wait (o_complete);

            // Display result
            $display("--------------------------------------------------");
            $display("Binary Quotient  : %b", o_quotient_out);
            $display("Decimal Quotient : %f", fromQ(o_quotient_out));
            $display("Overflow Flag    : %b", o_overflow);
            if (divisor_real[i] != 0.0)
                $display("Expected Result  : %f / %f = %f", dividend_real[i],
                         divisor_real[i], dividend_real[i] / divisor_real[i]);
            else
                $display("Expected Result  : Divide by zero (overflow expected)");
            $display("--------------------------------------------------");

            // Small gap before next test
            repeat (10) @(posedge i_clk);
        end

        $display("\n=== All tests completed ===\n");
        #100 $finish;
    end

endmodule
