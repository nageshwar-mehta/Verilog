`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar
// Date:      22 Oct 2025
// Design:    Signed Fixed-Point Divider Wrapper (Qm.n)
// Description:
//   Wraps qdiv_unsigned for signed fixed-point division.
//   Handles all four sign combinations and outputs one-cycle completion pulse.
////////////////////////////////////////////////////////////////////////////////

module q_div_wrapper_us #(
    parameter integer Q = 9,   // fractional bits
    parameter integer N = 16   // total bits
)(
    input  wire [N-1:0] i_dividend_s,  // signed dividend (two's complement)
    input  wire [N-1:0] i_divisor_s,   // signed divisor (two's complement)
    input  wire          i_start,
    input  wire          i_clk,
    input  wire          i_rstn,       // active-low asynchronous reset
    output reg  [N-1:0] o_quotient_out_s,
    output reg           o_complete,   // 1-clock done pulse
    output reg           o_overflow
);

    // ----------------------------------------------------------------
    // Step 1: Determine sign and absolute magnitudes
    // ----------------------------------------------------------------
    wire quotient_sign = i_dividend_s[N-1] ^ i_divisor_s[N-1];
    wire [N-1:0] i_dividend_us = i_dividend_s[N-1] ? (~i_dividend_s + 1'b1) : i_dividend_s;
    wire [N-1:0] i_divisor_us  = i_divisor_s[N-1]  ? (~i_divisor_s  + 1'b1) : i_divisor_s;

    // ----------------------------------------------------------------
    // Step 2: Instantiate unsigned divider core
    // ----------------------------------------------------------------
    wire [N-1:0] o_quotient_out;
    wire          o_complete_temp;
    wire          o_overflow_temp;

    qdiv_unsigned #(.Q(Q), .N(N)) u_div_unsigned (
        .i_dividend(i_dividend_us),
        .i_divisor(i_divisor_us),
        .i_start(i_start),
        .i_clk(i_clk),
        .rstn(i_rstn),
        .o_quotient_out(o_quotient_out),
        .o_complete(o_complete_temp),
        .o_overflow(o_overflow_temp)
    );

    // ----------------------------------------------------------------
    // Step 3: Edge detection for o_complete_temp (1-cycle pulse)
    // ----------------------------------------------------------------
    reg o_complete_d;
    wire complete_rise = o_complete_temp & ~o_complete_d;

    // ----------------------------------------------------------------
    // Step 4: Output registration on rising edge of completion
    // ----------------------------------------------------------------
    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            o_quotient_out_s <= 0;
            o_complete       <= 0;
            o_overflow       <= 0;
            o_complete_d     <= 0;
        end else begin
            // track previous complete state
            o_complete_d <= o_complete_temp;

            // latch outputs exactly when division finishes
            if (complete_rise) begin
                o_quotient_out_s <= quotient_sign ? (~o_quotient_out + 1'b1)
                                                  :  o_quotient_out;
                o_complete       <= 1'b1;      // pulse for 1 clock
                o_overflow       <= o_overflow_temp;
            end else begin
                o_complete       <= 1'b0;      // reset pulse
            end
        end
    end

endmodule
