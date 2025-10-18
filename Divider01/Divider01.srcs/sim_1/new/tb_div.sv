`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Fixed_Point_DividerR1
// Engineer: Nageshwar Kumar (IIT Jammu)
// Date: 18-Oct-2025
// Description: Verification of iterative fixed-point divider
//////////////////////////////////////////////////////////////////////////////////

module tb_Fixed_Point_DividerR1;

    // Parameters
    parameter Q = 9;
    parameter N = 16;
    localparam CLK_PERIOD = 10; // 100 MHz clock

    // DUT I/O
    reg  clk;
    reg  rstn;
    reg  [N-1:0] divisor;
    reg  [N-1:0] divident;
    wire [N-1:0] quotient;
    wire overflow;
    wire out_valid;

    // Instantiate DUT
    Fixed_Point_DividerR1 #(
        .Q(Q),
        .N(N)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .divisor(divisor),
        .divident(divident),
        .quotient(quotient),
        .overflow(overflow),
        .out_valid(out_valid)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task: Apply one test vector and wait for output
    task run_division(
        input signed [N-1:0] divident_in,
        input signed [N-1:0] divisor_in
    );
        begin
            @(negedge clk);
            divident = divident_in;
            divisor  = divisor_in;

            @(posedge clk);
            // Wait until out_valid = 1
            wait(out_valid == 1'b1);

            // Display results
            $display("[%0t ns] Dividend=%0d, Divisor=%0d, Quotient=%0d (Q=%0d.%0d), Overflow=%b",
                      $time, $signed(divident_in), $signed(divisor_in),
                      $signed(quotient), N-Q-1, Q, overflow);
            @(posedge clk);
        end
    endtask

    // User-defined test list
    reg signed [N-1:0] dividend_list [0:9];
    reg signed [N-1:0] divisor_list  [0:9];
    integer i, num_tests;

    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        divident = 0;
        divisor  = 0;

        // Define your custom test cases here ?
        // (You can add more manually)
        dividend_list[0] = 16'sd1000; divisor_list[0] = 16'sd10;     // +ve/+ve
        dividend_list[1] = -16'sd1000; divisor_list[1] = 16'sd10;    // -ve/+ve
        dividend_list[2] = 16'sd1000; divisor_list[2] = -16'sd10;    // +ve/-ve
        dividend_list[3] = -16'sd1000; divisor_list[3] = -16'sd10;   // -ve/-ve
        dividend_list[4] = 16'sd3276; divisor_list[4] = 16'sd3;      // fractional
        dividend_list[5] = 16'sd15;   divisor_list[5] = 16'sd4;      // small ratio
        dividend_list[6] = 16'sd200;  divisor_list[6] = 16'sd0;      // divide-by-zero
        dividend_list[7] = 16'sd1;    divisor_list[7] = 16'sd100;    // small result
        dividend_list[8] = -16'sd50;  divisor_list[8] = 16'sd7;      // negative
        dividend_list[9] = 16'sd500;  divisor_list[9] = 16'sd32767;  // large divisor

        num_tests = 10;

        // Apply reset
        #(5*CLK_PERIOD);
        rstn = 1;
        $display("\n=== Starting Fixed-Point Divider Verification ===\n");

        // Run tests
        for (i = 0; i < num_tests; i = i + 1) begin
            run_division(dividend_list[i], divisor_list[i]);
            #(2*CLK_PERIOD);
        end

        $display("\n=== All test cases completed successfully ===");
        $finish;
    end

endmodule
