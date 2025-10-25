`timescale 1ns / 1ps
module qdiv_unsigned #(
    parameter integer Q = 9,   // fractional bits
    parameter integer N = 16   // total bits
)(
    input  wire [N-1:0] i_dividend,
    input  wire [N-1:0] i_divisor,
    input  wire         i_start,
    input  wire         i_clk,
    input  wire         rstn,               // active-low asynchronous reset
    output wire [N-1:0] o_quotient_out,
    output wire         o_complete,
    output wire         o_overflow
);

    // =========================================================
    // Internal widths
    // =========================================================
    localparam integer W_REM      = N + Q;        // dividend shifted (<< Q)
    localparam integer W_WIDE     = 2*N + Q - 1;  // width for working registers
    localparam integer CNT_WIDTH  = $clog2(W_WIDE + 1);

    // =========================================================
    // Internal registers
    // =========================================================
    reg [W_REM-1:0]      reg_working_dividend;
    reg [W_WIDE-1:0]     reg_working_divisor;
    reg [W_WIDE-1:0]     reg_working_quotient;

    reg [N-1:0]          reg_quotient;
    reg [CNT_WIDTH-1:0]  reg_count;
    reg                  reg_done;
    reg                  reg_overflow;

    // Output assignments
    assign o_quotient_out = reg_quotient;
    assign o_complete     = reg_done;
    assign o_overflow     = reg_overflow;

    // =========================================================
    // Main logic
    // =========================================================
    always @(posedge i_clk or negedge rstn) begin
        if (!rstn) begin
            // Active-low reset asserted
            reg_working_dividend <= {W_REM{1'b0}};
            reg_working_divisor  <= {W_WIDE{1'b0}};
            reg_working_quotient <= {W_WIDE{1'b0}};
            reg_quotient         <= {N{1'b0}};
            reg_count            <= {CNT_WIDTH{1'b0}};
            reg_done             <= 1'b1;   // ready to accept i_start
            reg_overflow         <= 1'b0;
        end 
        else begin
            // ===============================
            // IDLE ? START transition
            // ===============================
            if (reg_done && i_start) begin
                if (i_divisor == {N{1'b0}}) begin
                    // Divide-by-zero
                    reg_done             <= 1'b1;
                    reg_overflow         <= 1'b1;
                    reg_quotient         <= {N{1'b0}};
                    reg_working_dividend <= {W_REM{1'b0}};
                    reg_working_divisor  <= {W_WIDE{1'b0}};
                    reg_working_quotient <= {W_WIDE{1'b0}};
                    reg_count            <= {CNT_WIDTH{1'b0}};
                end 
                else begin
                    // Initialize new division
                    reg_done             <= 1'b0;
                    reg_overflow         <= 1'b0;
                    reg_working_quotient <= {W_WIDE{1'b0}};
                    reg_working_dividend <= {W_REM{1'b0}};
                    reg_working_divisor  <= {W_WIDE{1'b0}};
                    reg_working_dividend[N+Q-1 : Q]       <= i_dividend;
                    reg_working_divisor[W_WIDE-1 : N+Q-1] <= i_divisor;
                    reg_count <= N + Q - 1;
                end
            end 
            // ===============================
            // RUNNING division iterations
            // ===============================
            else if (!reg_done) begin
                reg_working_divisor <= reg_working_divisor >> 1;

                if (reg_working_dividend >= reg_working_divisor) begin
                    reg_working_quotient[reg_count] <= 1'b1;
                    reg_working_dividend <= reg_working_dividend - reg_working_divisor;
                end

                if (reg_count == 0) begin
                    // Done
                    reg_done     <= 1'b1;
                    reg_quotient <= reg_working_quotient[N-1:0];
                    if (|reg_working_quotient[W_WIDE-1:N])
                        reg_overflow <= 1'b1;
                end 
                else begin
                    reg_count <= reg_count - 1;
                end
            end
            // If reg_done = 1 and i_start = 0 ? stay idle
        end
    end

endmodule
