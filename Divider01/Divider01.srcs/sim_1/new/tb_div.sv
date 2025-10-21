`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Fixed_Point_DividerR1
// Engineer: Nageshwar Kumar (IIT Jammu)
// Date: 18-Oct-2025 (fixed)
// Description: Verification of iterative fixed-point divider (improved TB)
//////////////////////////////////////////////////////////////////////////////////

module tb_Fixed_Point_DividerR1;

    parameter Q = 9;
    parameter N = 16;
    localparam CLK_PERIOD = 10; // ns

    reg clk;
    reg rstn;
    reg [N-1:0] divisor;
    reg [N-1:0] divident;
    wire [N-1:0] quotient;
    wire overflow;
    wire out_valid;

    // DUT instantiation
    Fixed_Point_DividerR1 #(.Q(Q), .N(N)) dut (
        .clk(clk), .rstn(rstn),
        .divisor(divisor), .divident(divident),
        .quotient(quotient), .overflow(overflow), .out_valid(out_valid)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    // Sampled outputs to avoid races
    reg [N-1:0] q_sample;
    reg        overflow_sample;
    reg        out_valid_sample;

    // Task to run one division vector and wait for completion
    task run_division(
        input signed [N-1:0] divident_in,
        input signed [N-1:0] divisor_in
    );
        real dec_result;
        begin
            @(negedge clk);
            divident = divident_in;
            divisor  = divisor_in;
            @(posedge clk);

            // wait for out_valid (with a timeout to avoid infinite wait in case of bug)
            integer timeout;
            timeout = 0;
            wait (out_valid == 1'b1) begin
                timeout = timeout + 1;
                if (timeout > 2000) begin
                    $display("ERROR: timeout waiting for out_valid for dividend=%0d divisor=%0d", $signed(divident_in), $signed(divisor_in));
                    disable run_division;
                end
            end

            // sample outputs on next posedge to be safe
            @(posedge clk);
            q_sample = quotient;
            overflow_sample = overflow;
            out_valid_sample = out_valid;

            // human readable fixed-point decimal:
            dec_result = $itor($signed(q_sample)) / (2.0 ** Q);

            $display("[%0t ns] Dividend=%0d, Divisor=%0d, Quotient(raw)=%0d, Fixed-format=%0d.%0d (%f), Overflow=%b",
                      $time, $signed(divident_in), $signed(divisor_in),
                      $signed(q_sample), N-Q, Q, dec_result, overflow_sample);
        end
    endtask

    // user-defined list
    reg signed [N-1:0] dividend_list [0:9];
    reg signed [N-1:0] divisor_list  [0:9];
    integer i, num_tests;

    initial begin
        clk = 0;
        rstn = 0;
        divident = 0;
        divisor = 0;

        // tests (customize as needed)
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

        #(5*CLK_PERIOD);
        rstn = 1;
        $display("\n=== Starting Fixed-Point Divider Verification ===\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            run_division(dividend_list[i], divisor_list[i]);
            #(2*CLK_PERIOD);
        end

        $display("\n=== All test cases completed ===\n");
        $finish;
    end

endmodule
