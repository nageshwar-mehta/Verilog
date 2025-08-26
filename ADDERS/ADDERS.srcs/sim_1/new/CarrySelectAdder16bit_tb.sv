`timescale 1ns/1ps

module CarrySelectAdder16bit_tb;

    // DUT ports
    logic [15:0] a, b;
    logic cin;
    logic [15:0] sum;
    logic carry;

    // Instantiate DUT
    CarrySelectAdder16bit dut (
        .sum(sum),
        .carry(carry),
        .a(a),
        .b(b),
        .cin(cin)
    );

    // Reference values
    logic [16:0] ref_result;

    // Task to apply stimulus
    task apply_and_check(input logic [15:0] ta,
                         input logic [15:0] tb,
                         input logic tcin);
        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            #10; // delay to let DUT compute

            ref_result = ta + tb + tcin;

            if ({carry,sum} !== ref_result) begin
                $display("<<Wrong>> time=%0t a=%d b=%d cin=%b | DUT Total sum = %d, REF=%d",
                          $time, ta, tb, tcin, {carry, sum}, ref_result);
            end 
            else begin
                $display("<<Correct>> time=%0t a=%d b=%d cin=%b | DUT Total sum = %d, REF=%d",
                          $time, ta, tb, tcin, {carry, sum}, ref_result);
            end
        end
    endtask

    // Test procedure
    initial begin

        // Random tests
        repeat (20) begin
            apply_and_check($urandom, $urandom, $urandom_range(0,1));
        end

        $display("---- Testbench Completed ----");
        $finish;
    end

endmodule
