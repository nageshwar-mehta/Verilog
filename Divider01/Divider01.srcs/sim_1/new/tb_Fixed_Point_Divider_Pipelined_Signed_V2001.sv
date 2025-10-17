`timescale 1ns / 1ps

module tb_Fixed_Point_Divider_Pipelined_Signed_V2001;

    // Parameters
    parameter N = 16;
    parameter Q = 9;
    localparam STAGES = N + Q;
    localparam CLK_PERIOD = 10;

    // DUT I/O
    reg                     clk;
    reg                     rst;
    reg                     i_valid;
    reg signed [N-1:0]      i_dividend;
    reg signed [N-1:0]      i_divisor;
    wire signed [N-1:0]     o_quotient;
    wire                    o_valid;
    wire                    o_overflow;

    // Instantiate DUT
    Fixed_Point_Divider_Pipelined_Signed_V2001 #(
        .N(N),
        .Q(Q)
    ) dut (
        .clk(clk),
        .rst(rst),
        .i_valid(i_valid),
        .i_dividend(i_dividend),
        .i_divisor(i_divisor),
        .o_quotient(o_quotient),
        .o_valid(o_valid),
        .o_overflow(o_overflow)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // ================================================================
    // USER-DEFINED TEST CASES
    // ================================================================
    
    // Define your test cases here - easy to modify
    localparam NUM_TESTS = 15;
    
    // Test case structure: {dividend, divisor, expected_real_result}
    typedef struct {
        real dividend_real;
        real divisor_real;
        real expected_real;
        string description;
    } test_case_t;
    
    // User-defined test cases - MODIFY THIS LIST AS NEEDED
    test_case_t test_cases [NUM_TESTS] = '{
        '{10.0,   2.0,   5.0,    "10 / 2 = 5.0"},
        '{25.0,   5.0,   5.0,    "25 / 5 = 5.0"},
        '{-12.0,  3.0,   -4.0,   "-12 / 3 = -4.0"},
        '{7.0,    -2.0,  -3.5,   "7 / -2 = -3.5"},
        '{-16.0,  -4.0,  4.0,    "-16 / -4 = 4.0"},
        '{5.0,    0.25,  20.0,   "5 / 0.25 = 20.0"},
        '{1.0,    3.0,   0.3333, "1 / 3 = 0.3333"},
        '{0.0,    7.0,   0.0,    "0 / 7 = 0.0"},
        '{7.0,    0.0,   0.0,    "7 / 0 = overflow"},
        '{3.125,  1.25,  2.5,    "3.125 / 1.25 = 2.5"},
        '{-8.75,  2.5,   -3.5,   "-8.75 / 2.5 = -3.5"},
        '{15.5,   0.5,   31.0,   "15.5 / 0.5 = 31.0"},
        '{1.5,    4.0,   0.375,  "1.5 / 4 = 0.375"},
        '{-10.0,  0.0,   0.0,    "-10 / 0 = overflow"},
        '{100.0,  33.0,  3.0303, "100 / 33 ? 3.0303"}
    };

    // Convert real to fixed-point
    function signed [N-1:0] real_to_fixed;
        input real value;
        begin
            real_to_fixed = $signed(value * (1 << Q));
        end
    endfunction

    // Convert fixed-point to real
    function real fixed_to_real;
        input signed [N-1:0] fixed_val;
        begin
            fixed_to_real = $itor(fixed_val) / (1 << Q);
        end
    endfunction

    // Test sequence storage
    reg signed [N-1:0] test_dividends [0:NUM_TESTS-1];
    reg signed [N-1:0] test_divisors [0:NUM_TESTS-1];
    real expected_results [0:NUM_TESTS-1];
    string test_descriptions [0:NUM_TESTS-1];
    
    integer test_count;
    integer current_test = 0;
    integer output_count = 0;
    integer error_count = 0;

    // Initialize test cases
    initial begin
        for (test_count = 0; test_count < NUM_TESTS; test_count = test_count + 1) begin
            test_dividends[test_count] = real_to_fixed(test_cases[test_count].dividend_real);
            test_divisors[test_count] = real_to_fixed(test_cases[test_count].divisor_real);
            expected_results[test_count] = test_cases[test_count].expected_real;
            test_descriptions[test_count] = test_cases[test_count].description;
        end
    end

    // ================================================================
    // MAIN TEST SEQUENCE
    // ================================================================
    initial begin
        clk = 0;
        rst = 1;
        i_valid = 0;
        i_dividend = 0;
        i_divisor = 0;

        // Initialize simulation
        $display("====================================================================");
        $display("  PIPELINED SIGNED FIXED-POINT DIVIDER TEST (N=%0d, Q=%0d)", N, Q);
        $display("  STAGES: %0d, LATENCY: %0d cycles", STAGES, STAGES);
        $display("====================================================================");
        $display("Throughput: 1 result per clock cycle after %0d cycle latency", STAGES);
        $display("====================================================================");

        // Reset sequence
        repeat(5) @(posedge clk);
        rst = 0;
        repeat(2) @(posedge clk);

        $display("\nAPPLYING TEST CASES:");
        $display("Time\tInput#\tDescription");
        $display("----------------------------------------------------");

        // Apply test cases with SINGLE-CYCLE THROUGHPUT (back-to-back)
        for (current_test = 0; current_test < NUM_TESTS; current_test = current_test + 1) begin
            @(posedge clk);
            i_valid <= 1'b1;
            i_dividend <= test_dividends[current_test];
            i_divisor <= test_divisors[current_test];
            
            $display("%0t\t%0d\t%s", $time, current_test, test_descriptions[current_test]);
            
            // For true throughput testing, we apply inputs every cycle
            if (current_test == NUM_TESTS - 1) begin
                @(posedge clk);
                i_valid <= 1'b0;  // Stop after last test
            end
        end

        // Wait for pipeline to flush
        $display("\nWAITING FOR PIPELINE OUTPUTS...");
        #(CLK_PERIOD * (STAGES + 5));
        
        $display("\n====================================================================");
        $display("SIMULATION SUMMARY:");
        $display("  Total Tests Applied: %0d", NUM_TESTS);
        $display("  Total Outputs Received: %0d", output_count);
        $display("  Errors: %0d", error_count);
        $display("  Throughput: %0.2f outputs/cycle", real'(output_count) / real'($time/CLK_PERIOD));
        $display("====================================================================");
        
        if (error_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** %0d TESTS FAILED ***", error_count);
        end
        
        $finish;
    end

    // ================================================================
    // OUTPUT MONITORING AND VERIFICATION
    // ================================================================
    always @(posedge clk) begin
        if (o_valid) begin
            real actual_result, expected_result;
            real input_dividend, input_divisor;
            real absolute_error, relative_error;
            string status;
            
            // Get the actual result
            actual_result = fixed_to_real(o_quotient);
            
            // Get expected result for this output
            // Due to pipeline latency, we need to track which input produced this output
            expected_result = expected_results[output_count];
            input_dividend = test_cases[output_count].dividend_real;
            input_divisor = test_cases[output_count].divisor_real;
            
            // Calculate errors
            absolute_error = actual_result - expected_result;
            if (expected_result != 0) begin
                relative_error = (absolute_error / expected_result) * 100;
            end else begin
                relative_error = (actual_result != 0) ? 100 : 0;
            end
            
            // Check for overflow conditions first
            if (o_overflow) begin
                if (input_divisor == 0) begin
                    status = "OVERFLOW (div by zero) - EXPECTED";
                    error_count = error_count; // No error count increment
                end else if (expected_result > ((1 << (N-Q-1)) - 1) || 
                           expected_result < -(1 << (N-Q-1))) {
                    status = "OVERFLOW (range) - EXPECTED";
                    error_count = error_count; // No error count increment
                end else begin
                    status = "UNEXPECTED OVERFLOW - ERROR";
                    error_count = error_count + 1;
                end
            end else begin
                // Check result accuracy (allow for fixed-point precision limits)
                if (absolute_error > (2.0 / (1 << Q)) && relative_error > 1.0) begin
                    status = "RESULT MISMATCH - ERROR";
                    error_count = error_count + 1;
                end else begin
                    status = "PASS";
                end
            end
            
            $display("%0t\tOUT%0d\t%0.4f = %0.4f / %0.4f (exp: %0.4f) err: %0.4f %s",
                     $time, output_count, actual_result, input_dividend, 
                     input_divisor, expected_result, absolute_error, status);
            
            output_count = output_count + 1;
        end
    end

    // ================================================================
    // THROUGHPUT MONITORING
    // ================================================================
    reg [31:0] total_cycles = 0;
    reg [31:0] valid_outputs = 0;
    
    always @(posedge clk) begin
        if (!rst) begin
            total_cycles <= total_cycles + 1;
            if (o_valid) begin
                valid_outputs <= valid_outputs + 1;
            end
        end
    end
    
    // Final throughput report
    final begin
        real throughput;
        throughput = real'(valid_outputs) / real'(total_cycles);
        $display("\nFINAL THROUGHPUT ANALYSIS:");
        $display("  Total clock cycles: %0d", total_cycles);
        $display("  Valid outputs: %0d", valid_outputs);
        $display("  Measured throughput: %0.4f outputs/cycle", throughput);
        
        if (throughput > 0.95) begin
            $display("  *** EXCELLENT THROUGHPUT ACHIEVED ***");
        end else if (throughput > 0.8) begin
            $display("  *** GOOD THROUGHPUT ACHIEVED ***");
        end else begin
            $display("  *** SUBOPTIMAL THROUGHPUT ***");
        end
    end

endmodule