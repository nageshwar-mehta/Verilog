`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for: Fixed_Point_Divider_Pipelined_Signed_V2001
// Engineer: Nagesh
// Description:
//   Verifies the pipelined signed fixed-point divider (Verilog-2001 compliant).
//   Displays results as both integer and floating-point equivalents.
//////////////////////////////////////////////////////////////////////////////////

module tb_Fixed_Point_Divider_Pipelined_Signed_V2001;

    // Parameters
    parameter N = 16;
    parameter Q = 9;
    localparam STAGES = N + Q;
    localparam CLK_PERIOD = 10; // 100 MHz

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

    // Task: apply single test input
    task apply_input;
        input signed [N-1:0] dividend;
        input signed [N-1:0] divisor;
        begin
            @(posedge clk);
            i_valid <= 1'b1;
            i_dividend <= dividend;
            i_divisor  <= divisor;
            @(posedge clk);
            i_valid <= 1'b0;
        end
    endtask

    // Main test sequence
    initial begin
        clk = 0;
        rst = 1;
        i_valid = 0;
        i_dividend = 0;
        i_divisor = 0;

        // Reset
        repeat(3) @(posedge clk);
        rst = 0;

        $display("==============================================================");
        $display("  PIPELINED SIGNED FIXED-POINT DIVIDER TEST (N=%0d, Q=%0d)  ", N, Q);
        $display("==============================================================");
        $display("Time\tValid\tDividend\tDivisor\tQuotient\tOverflow\tResult (Real)");
        $display("--------------------------------------------------------------");

        // Test cases (scaled by Q)
        apply_input( (10 <<< Q),  (2 <<< Q));     // 10 / 2 = 5.0
        apply_input( (25 <<< Q),  (5 <<< Q));     // 25 / 5 = 5.0
        apply_input( (-12 <<< Q), (3 <<< Q));     // -12 / 3 = -4.0
        apply_input( (7 <<< Q),   (-2 <<< Q));    // 7 / -2 = -3.5
        apply_input( (-16 <<< Q), (-4 <<< Q));    // -16 / -4 = +4.0
        apply_input( (5 <<< Q),   (1 <<< (Q-2))); // 5 / 0.25 = 20.0 (overflow expected)
        apply_input( (1 <<< Q),   (3 <<< Q));     // 1 / 3 = 0.333
        apply_input( (0 <<< Q),   (7 <<< Q));     // 0 / 7 = 0
        apply_input( (7 <<< Q),   (0 <<< Q));     // divide-by-zero (overflow expected)

        // Let pipeline flush
        #(CLK_PERIOD * (STAGES + 10));
        $display("--------------------------------------------------------------");
        $display("Simulation completed.");
        $finish;
    end

    // Output monitoring and display
    always @(posedge clk) begin
        if (o_valid) begin
            real r_dividend, r_divisor, r_quotient;
            r_dividend = $itor($signed(i_dividend)) / (1<<Q);
            r_divisor  = $itor($signed(i_divisor))  / (1<<Q);
            r_quotient = $itor($signed(o_quotient)) / (1<<Q);

            $display("%0t\t%b\t%d\t%d\t%d\t%b\t%0.4f = %0.4f / %0.4f",
                     $time, o_valid, i_dividend, i_divisor,
                     o_quotient, o_overflow,
                     r_quotient, r_dividend, r_divisor);
        end
    end

endmodule
