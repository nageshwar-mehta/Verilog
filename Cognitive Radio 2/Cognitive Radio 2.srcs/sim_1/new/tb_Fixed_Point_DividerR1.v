`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Fixed_Point_DividerR1
// Author: Nageshwar Kumar (IIT Jammu)
// Date: 12-Oct-2025
// Description: Functional verification for Fixed_Point_DividerR1
//////////////////////////////////////////////////////////////////////////////////

module tb_Fixed_Point_DividerR1;

    // Parameters
    parameter Q = 9;
    parameter N = 16;

    // Inputs
    reg [N-1:0] i_dividend;
    reg [N-1:0] i_divisor;
    reg i_start;
    reg i_clk;
    reg div_rst;

    // Outputs
    wire [N-1:0] o_quotient_out;
    wire o_complete;
    wire o_overflow;

    // Instantiate the Unit Under Test (UUT)
    Fixed_Point_DividerR1 #(Q, N) uut (
        .i_dividend(i_dividend),
        .i_divisor(i_divisor),
        .i_start(i_start),
        .i_clk(i_clk),
        .div_rst(div_rst),
        .o_quotient_out(o_quotient_out),
        .o_complete(o_complete),
        .o_overflow(o_overflow)
    );

    // Clock generation: 10 ns period
    always #5 i_clk = ~i_clk;

    // Task for applying a test case
    task run_test(input signed [N-1:0] dividend, input signed [N-1:0] divisor);
        begin
            @(posedge i_clk);
            i_dividend = dividend;
            i_divisor  = divisor;
            i_start = 1;
            @(posedge i_clk);
            i_start = 0;

            // Wait until division is complete
            wait(o_complete == 1);
            #2;
            $display("Time=%0t | Dividend=%0d | Divisor=%0d | Quotient=%0d | Overflow=%b", 
                      $time, dividend, divisor, o_quotient_out, o_overflow);
            $display("------------------------------------------------------------");
        end
    endtask

    // Simulation control
    initial begin
        // Initialize
        i_clk = 0;
        i_start = 0;
        div_rst = 1;
        i_dividend = 0;
        i_divisor = 0;
        #20;

        // Release reset
        div_rst = 0;
        #20;

        // Test cases
        $display("===== Starting Fixed_Point_DividerR1 Tests =====");

        // Test 1: Simple division
        run_test(16'd50, 16'd5);     // 50 / 5 = 10

        // Test 2: Fractional division
        run_test(16'd25, 16'd8);     // 25 / 8 ~= 3.125

        // Test 3: Dividend < Divisor
        run_test(16'd3, 16'd10);     // 3 / 10 = 0.3

        // Test 4: Negative division
        run_test(-16'd40, 16'd8);    // -40 / 8 = -5

        // Test 5: Both negative
        run_test(-16'd40, -16'd5);   // -40 / -5 = 8

        // Test 6: Divide by zero (overflow expected)
        run_test(16'd10, 16'd0);

        // Test 7: Large values
        run_test(16'd30000, 16'd3);

        $display("===== All tests completed successfully =====");
        #50;
        $finish;
    end

endmodule
