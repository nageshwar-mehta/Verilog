`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nagesh
// 
// Fully Pipelined Signed Fixed-Point Divider (Verilog-2001 Compliant)
// Description:
//   - 1 output per clock after pipeline fill
//   - Signed 2's complement arithmetic
//   - Q fractional bits
//   - Overflow detection
//   - No SystemVerilog constructs (fully synthesizable Verilog-2001)
//
// Latency: N + Q cycles
// Throughput: 1 per cycle (after pipeline fill)
//
//////////////////////////////////////////////////////////////////////////////////

module Fixed_Point_Divider_Pipelined_Signed #(
    parameter N = 16,   // total bits
    parameter Q = 9     // fractional bits
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                i_valid,
    input  wire signed [N-1:0] i_dividend,
    input  wire signed [N-1:0] i_divisor,
    output wire signed [N-1:0] o_quotient,
    output wire                o_valid,
    output wire                o_overflow
);

    // ----------------------------------------------------------------
    // Local constants
    // ----------------------------------------------------------------
    localparam STAGES = N + Q;

    // ----------------------------------------------------------------
    // Stage 0 registers (input + initialization)
    // ----------------------------------------------------------------
    reg [N-2+Q:0] remainder_0;
    reg signed [N-1:0] divisor_0, dividend_0;
    reg [STAGES-1:0] quotient_bits_0;
    reg sign_0, valid_0;

    // ----------------------------------------------------------------
    // Stage pipeline arrays (flattened generate approach)
    // ----------------------------------------------------------------
    genvar i;
    generate
        // Each stage will have its own set of registers
        for (i = 0; i < STAGES; i = i + 1) begin : PIPE

            // Pipeline registers
            reg [N-2+Q:0] remainder_r;
            reg signed [N-1:0] divisor_r;
            reg [STAGES-1:0] quotient_bits_r;
            reg sign_r, valid_r;
            reg signed [N-1:0] dividend_r;

            // Stage combinational signal (shifted divisor)
            wire [N-2+Q:0] div_shifted = divisor_r << (STAGES - 1 - i);

            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    remainder_r      <= 0;
                    divisor_r        <= 0;
                    quotient_bits_r  <= 0;
                    dividend_r       <= 0;
                    sign_r           <= 0;
                    valid_r          <= 0;
                end 
                else if (i == 0) begin
                    // Stage 0 initialization
                    if (i_valid) begin
                        valid_r  <= 1;
                        dividend_r <= (i_dividend[N-1]) ? (~i_dividend + 1'b1) : i_dividend;
                        divisor_r  <= (i_divisor[N-1])  ? (~i_divisor + 1'b1)  : i_divisor;
                        sign_r     <= i_dividend[N-1] ^ i_divisor[N-1];
                        remainder_r <= {((i_dividend[N-1]) ? (~i_dividend + 1'b1) : i_dividend), {Q{1'b0}}};
                        quotient_bits_r <= 0;
                    end else begin
                        valid_r <= 0;
                    end
                end 
                else begin
                    // Pipeline propagation
                    valid_r <= PIPE[i-1].valid_r;
                    sign_r  <= PIPE[i-1].sign_r;
                    dividend_r <= PIPE[i-1].dividend_r;
                    divisor_r  <= PIPE[i-1].divisor_r;
                    quotient_bits_r <= PIPE[i-1].quotient_bits_r;
                    remainder_r <= PIPE[i-1].remainder_r;

                    // Division logic
                    if (PIPE[i-1].remainder_r >= div_shifted) begin
                        remainder_r <= PIPE[i-1].remainder_r - div_shifted;
                        quotient_bits_r <= {PIPE[i-1].quotient_bits_r[STAGES-2:0], 1'b1};
                    end else begin
                        quotient_bits_r <= {PIPE[i-1].quotient_bits_r[STAGES-2:0], 1'b0};
                    end
                end
            end
        end
    endgenerate

    // ----------------------------------------------------------------
    // Output logic - sign correction & overflow
    // ----------------------------------------------------------------
    wire signed [N-1:0] unsigned_result = PIPE[STAGES-1].quotient_bits_r[N-1:0];
    wire signed [N-1:0] signed_result   = (PIPE[STAGES-1].sign_r) ? (~unsigned_result + 1'b1) : unsigned_result;

    assign o_quotient = signed_result;
    assign o_valid    = PIPE[STAGES-1].valid_r;
    assign o_overflow = (|PIPE[STAGES-1].quotient_bits_r[STAGES-1:N]) ? 1'b1 : 1'b0;

endmodule
