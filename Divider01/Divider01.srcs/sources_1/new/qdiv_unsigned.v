`timescale 1ns / 1ps
module qdiv_unsigned #(
    parameter Q = 9,          // fractional bits
    parameter N = 16          // total bits
)(
    input  [N-1:0] i_dividend,
    input  [N-1:0] i_divisor,
    input           i_start,
    input           i_clk,
    output [N-1:0]  o_quotient_out,
    output          o_complete,
    output          o_overflow
);

    // Correct widths:
    // working_dividend needs N+Q bits (dividend << Q)
    reg [N+Q-1:0]    reg_working_dividend;

    // working_divisor and working_quotient need 2*N+Q-1 bits so we can left-align divisor
    reg [2*N+Q-2:0]  reg_working_divisor;
    reg [2*N+Q-2:0]  reg_working_quotient;

    reg [N-1:0]      reg_quotient;
    reg [N-1:0]      reg_count;
    reg              reg_done;
    reg              reg_overflow;

    // init
    initial begin
        reg_done = 1'b1;
        reg_overflow = 1'b0;
        reg_working_quotient = 0;
        reg_quotient = 0;
        reg_working_dividend = 0;
        reg_working_divisor = 0;
        reg_count = 0;
    end

    assign o_quotient_out = reg_quotient;
    assign o_complete = reg_done;
    assign o_overflow = reg_overflow;

    always @(posedge i_clk) begin
        if (reg_done && i_start) begin
            // initialize
            reg_done <= 1'b0;
            reg_count <= N + Q - 1;
            reg_working_quotient <= 0;
            reg_working_dividend <= 0;
            reg_working_divisor <= 0;
            reg_overflow <= 1'b0;

            // Left-align operands (use full N bits)
            // place dividend into bits [N+Q-1 : Q]  => width N
            reg_working_dividend[N+Q-1:Q] <= i_dividend;

            // place divisor into bits [2*N+Q-2 : N+Q-1] => width N
            reg_working_divisor[2*N+Q-2 : N+Q-1] <= i_divisor;
        end
        else if (!reg_done) begin
            // shift divisor right by 1 each cycle
            reg_working_divisor <= reg_working_divisor >> 1;
            // compare full registers; sizes are compatible
            if (reg_working_dividend >= reg_working_divisor) begin
                reg_working_quotient[reg_count] <= 1'b1;
                reg_working_dividend <= reg_working_dividend - reg_working_divisor;
            end

            if (reg_count == 0) begin
                reg_done <= 1'b1;
                // take the lower N bits as the result (Q format)
                reg_quotient <= reg_working_quotient[N-1:0];
                if (reg_working_quotient[2*N+Q-2 : N] != 0)
                    reg_overflow <= 1'b1;
            end
            else begin
                reg_count <= reg_count - 1;
            end
        end
    end

endmodule
