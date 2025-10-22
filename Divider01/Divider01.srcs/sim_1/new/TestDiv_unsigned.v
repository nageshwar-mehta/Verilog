`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:        Nageshwar Kumar
// Create Date:     22 Oct 2025
// Design Name:     qdiv_unsigned
// Module Name:     TestDiv_unsigned.v
// Project Name:    Fixed-point Divider (Unsigned)
// Description:     Testbench for qdiv_unsigned.v (Q7.9 format)
// 
// This testbench divides two positive Q7.9 numbers (e.g., 3.75 / 1.75)
// and displays the result in binary and decimal.
// 
////////////////////////////////////////////////////////////////////////////////

module TestDiv_unsigned;

    // Inputs
    reg [15:0] i_dividend;
    reg [15:0] i_divisor;
    reg        i_start;
    reg        i_clk;

    // Outputs
    wire [15:0] o_quotient_out;
    wire        o_complete;
    wire        o_overflow;

    // Instantiate the Unit Under Test (UUT)
    qdiv_unsigned #(.Q(9), .N(16)) uut (
        .i_dividend(i_dividend),
        .i_divisor(i_divisor),
        .i_start(i_start),
        .i_clk(i_clk),
        .o_quotient_out(o_quotient_out),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );

    reg [10:0] count;

    // Clock generation
    initial begin
        i_clk = 0;
        forever #2 i_clk = ~i_clk;  // 250 MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        i_start   = 0;
        count     = 0;

        // Example: Q7.9 encoded inputs
        // 3.75 ? 3.75 * 512 = 1920 ? 0000011110000000
        // 1.75 ? 1.75 * 512 = 896  ? 0000011100000000
        i_dividend = 16'b0000011110000000;  // 3.75
        i_divisor  = 16'b0000001110000000;  // 1.75

        #10; // wait for reset
        $display("=== Starting Fixed-Point Division (Q7.9) ===");
        $display("Dividend = %f, Divisor = %f", 
            $itor(i_dividend)/512.0, $itor(i_divisor)/512.0);

        // Start division
        i_start = 1;
        #4 i_start = 0;

        // Wait for division to complete
        wait(o_complete);

        // Display results
        $display("--------------------------------------------------");
        $display("Binary Quotient  : %b", o_quotient_out);
        $display("Decimal Quotient : %f", $itor(o_quotient_out)/512.0);
        $display("Overflow Flag    : %b", o_overflow);
        $display("--------------------------------------------------");
        $display("Expected Result  : 3.75 / 1.75 = 2.142857...");
        $display("--------------------------------------------------");

        #100000 $finish;
    end

endmodule
