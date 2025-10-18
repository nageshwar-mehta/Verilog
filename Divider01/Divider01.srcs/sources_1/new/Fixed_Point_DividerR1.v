`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nageshwar Kumar (IIT Jammu)
// Module : Fixed_Point_DividerR1
// Type   : Iterative Restoring Divider (Signed, Fixed-point)
// Description : Sequential (N+Q)-cycle divider for Qn.m format
//////////////////////////////////////////////////////////////////////////////////

module Fixed_Point_DividerR1 #(
    parameter integer Q = 9,       // fractional bits
    parameter integer N = 16       // total bits (including sign)
)(
    input  wire clk,
    input  wire rstn,
    input  wire [N-1:0] divisor,
    input  wire [N-1:0] divident,
    output reg  [N-1:0] quotient,
    output reg  overflow,
    output reg  out_valid
);

    // Internal parameters
    localparam integer ITER = N + Q; // Total iterations

    // Internal signals
    reg busy;
    reg [$clog2(ITER+1)-1:0] cnt;

    // Sign detection
    wire sign_divisor  = divisor[N-1];
    wire sign_divident = divident[N-1];
    wire result_sign   = sign_divisor ^ sign_divident;

    // Absolute values
    wire [N-1:0] abs_divisor  = sign_divisor  ? (~divisor  + 1'b1) : divisor;
    wire [N-1:0] abs_divident = sign_divident ? (~divident + 1'b1) : divident;

    // Extended operands
    reg  [N+Q-1:0] dividend_ext;     // dividend shifted by Q bits
    reg  [N+Q:0]   rem;              // remainder register
    reg  [N+Q-1:0] quotient_full;    // full precision quotient (N+Q bits)
    wire [N+Q:0]   divisor_ext;      // extended divisor

    // Temporary working regs (must be declared outside procedural block)
    reg  [N+Q:0] rem_shift;
    reg  next_bit;
    reg  [N-1:0] neg_out;

    assign divisor_ext = { {(Q+1){1'b0}}, abs_divisor };

    // Start condition (auto start if not busy and divisor ? 0)
    wire start_condition = (!busy) && (divisor != 0);

    // Sequential logic
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            busy          <= 1'b0;
            cnt           <= 0;
            dividend_ext  <= 0;
            rem           <= 0;
            quotient_full <= 0;
            quotient      <= 0;
            overflow      <= 0;
            out_valid     <= 0;
        end else begin
            out_valid <= 1'b0; // Default

            // Start division
            if (start_condition) begin
                busy          <= 1'b1;
                cnt           <= ITER;
                dividend_ext  <= {abs_divident, {Q{1'b0}}}; // shift left by Q bits
                rem           <= 0;
                quotient_full <= 0;
                overflow      <= 0;
            end

            // Iterative division
            else if (busy) begin
                next_bit  <= dividend_ext[cnt-1];
                rem_shift <= {rem[N+Q-1:0], next_bit};

                if (rem_shift >= divisor_ext) begin
                    rem           <= rem_shift - divisor_ext;
                    quotient_full <= (quotient_full << 1) | 1'b1;
                end else begin
                    rem           <= rem_shift;
                    quotient_full <= (quotient_full << 1);
                end

                // Decrement counter
                if (cnt == 1) begin
                    busy <= 1'b0;
                    cnt  <= 0;

                    // Overflow detection
                    if ((quotient_full >> Q) >= (1 << (N-1))) begin
                        overflow <= 1'b1;
                    end else begin
                        overflow <= 1'b0;
                    end

                    // Sign correction
                    if (result_sign) begin
                        neg_out  <= (~(quotient_full[N+Q-1 -: N])) + 1'b1;
                        quotient <= neg_out;
                    end else begin
                        quotient <= quotient_full[N+Q-1 -: N];
                    end

                    out_valid <= 1'b1; // Output ready
                end else begin
                    cnt <= cnt - 1;
                end
            end

            // Divide-by-zero handling
            if (divisor == 0) begin
                busy      <= 1'b0;
                cnt       <= 0;
                quotient  <= 0;
                overflow  <= 1'b1;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
