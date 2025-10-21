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

    localparam integer ITER = N + Q;

    reg busy;
    reg [$clog2(ITER+1)-1:0] cnt;

    wire sign_divisor  = divisor[N-1];
    wire sign_divident = divident[N-1];
    wire result_sign   = sign_divisor ^ sign_divident;

    wire [N-1:0] abs_divisor  = sign_divisor  ? (~divisor  + 1'b1) : divisor;
    wire [N-1:0] abs_divident = sign_divident ? (~divident + 1'b1) : divident;

    reg  [N+Q-1:0] dividend_ext;
    reg  [N+Q:0]   rem;
    reg  [N+Q-1:0] quotient_full;
    wire [N+Q:0]   divisor_ext;

    // Temporaries: we want combinational/instant values inside the clocked block
    reg  [N+Q:0] rem_shift;   // temp; computed with blocking so comparison uses current value
    reg  next_bit;            // temp; computed with blocking

    reg  [N-1:0] neg_out;

    assign divisor_ext = { {(Q+1){1'b0}}, abs_divisor };

    wire start_condition = (!busy) && (divisor != 0);

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
            out_valid <= 1'b0; // default low each cycle unless finished

            // Start division (capture inputs)
            if (start_condition) begin
                busy          <= 1'b1;
                cnt           <= ITER;
                dividend_ext  <= {abs_divident, {Q{1'b0}}};
                rem           <= 0;
                quotient_full <= 0;
                overflow      <= 0;
            end

            // Iterative division
            else if (busy) begin
                // IMPORTANT: blocking assignments for temps used *this cycle*
                // so comparison is using current values (no non-blocking delay).
                next_bit  = dividend_ext[cnt-1]; // blocking
                rem_shift = { rem[N+Q-1:0], next_bit }; // blocking shift-left and append

                // Use non-blocking to update registers that persist to next cycle
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

                    // Overflow detection: top N bits (integer+sign) exceed range
                    if ((quotient_full >> Q) >= (1 << (N-1))) begin
                        overflow <= 1'b1;
                    end else begin
                        overflow <= 1'b0;
                    end

                    // Sign correction (2's complement) for the N-bit output
                    if (result_sign) begin
                        neg_out  <= (~(quotient_full[N+Q-1 -: N])) + 1'b1;
                        quotient <= neg_out;
                    end else begin
                        quotient <= quotient_full[N+Q-1 -: N];
                    end

                    out_valid <= 1'b1;
                end else begin
                    cnt <= cnt - 1;
                end
            end

            // Divide-by-zero handling (explicit)
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
