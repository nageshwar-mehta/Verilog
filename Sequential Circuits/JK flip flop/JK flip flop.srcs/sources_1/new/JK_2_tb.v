`timescale 1ns / 1ps

module JK_2_tb();
    reg clk, j, k;
    wire Q;
    reg prev_Q; // ? Declare prev_Q at module level using reg

    JK2 uut(
        .clk(clk),
        .j(j),
        .k(k),
        .Q(Q)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test stimulus and self-check
    initial begin
        $display("=== Starting JK2 Self-Checking Testbench ===");
        j = 0; k = 0;
        #10; // allow initial condition to settle

        // Test 1: Reset
        j = 0; k = 1;
        @(posedge clk);
        #1; // small delay for output update
        if (Q !== 0) $display("Test 1 FAILED: Expected Q=0, Got Q=%b", Q);
        else $display("Test 1 PASSED");

        // Test 2: Set
        j = 1; k = 0;
        @(posedge clk);
        #1;
        if (Q !== 1) $display("Test 2 FAILED: Expected Q=1, Got Q=%b", Q);
        else $display("Test 2 PASSED");

        // Test 3: Toggle
        j = 1; k = 1;
        prev_Q = Q; // ? capture initial Q value before toggling
        repeat(4) begin
            @(posedge clk);
            #1;
            if (Q !== ~prev_Q)
                $display("Test 3 FAILED: Expected Q=%b, Got Q=%b", ~prev_Q, Q);
            else
                $display("Test 3 PASSED (Toggled Correctly)");
            prev_Q = Q; // ? update prev_Q for next toggle comparison
        end

        $display("=== JK2 Self-Checking Testbench Completed ===");
        $finish;
    end

endmodule
