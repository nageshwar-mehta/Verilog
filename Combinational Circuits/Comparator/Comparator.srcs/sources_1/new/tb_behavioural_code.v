`timescale 1ns / 1ps

module tb_behavioural_code;

// Testbench signals
reg [1:0] a, b;
wire greater, lesser, equal;

// Instantiate your DUT
behavioural_code uut (
    .a(a),
    .b(b),
    .greater(greater),
    .lesser(lesser),
    .equal(equal)
);

// Stimulus generation
initial begin
    // Display header for simulation console
    $display("Time\t a b | greater lesser equal");
    $monitor("%0dns\t %b %b |    %b       %b      %b", $time, a, b, greater, lesser, equal);

    // Apply test vectors
    a = 2'b00; b = 2'b00; #10;
    a = 2'b00; b = 2'b01; #10;
    a = 2'b01; b = 2'b00; #10;
    a = 2'b01; b = 2'b01; #10;
    a = 2'b10; b = 2'b01; #10;
    a = 2'b01; b = 2'b10; #10;
    a = 2'b11; b = 2'b01; #10;
    a = 2'b01; b = 2'b11; #10;
    a = 2'b11; b = 2'b11; #10;

    $finish;
end

endmodule
