`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Fixed_Point_DividerR1 (Throughput Test)
// Author: Nageshwar Kumar (IIT Jammu)
// Date: 17-Oct-2025
// Description: Verifies if Divider can accept new inputs every clock cycle
//////////////////////////////////////////////////////////////////////////////////

module tb_Fixed_Point_DividerR12;

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

    // Input stimulus (new input every clock)
    initial begin
        // Initialize
        i_clk = 0;
        div_rst = 1;
        i_start = 0;
        i_dividend = 0;
        i_divisor = 0;
        #20;
        div_rst = 0;
        #10;

        $display("===== Starting Throughput Test (New input per clock) =====");

        // Feed continuous inputs
        repeat (20) begin
            @(posedge i_clk);
            i_dividend <= $random % 5000;   // Random test values
            i_divisor  <= ($random % 30) + 1; // Avoid divide-by-zero
            i_start <= 1'b1;                // Assert start every clock
            $display("Time=%0t | Input -> Dividend=%0d, Divisor=%0d", $time, i_dividend, i_divisor);
        end

        // Stop asserting start after feeding enough samples
        @(posedge i_clk);
        i_start <= 1'b0;

        // Let pipeline finish for few cycles
        repeat (50) @(posedge i_clk);

        $display("===== Throughput Test Completed =====");
        $finish;
    end

    // Monitor output activity
    always @(posedge i_clk) begin
        if (o_complete)
            $display("Time=%0t | Output Ready -> Quotient=%0d | Overflow=%b",
                      $time, o_quotient_out, o_overflow);
    end

endmodule
