// complex_divide_cordic.v
// Top-level complex divide using CORDIC vectoring + iterative restoring divider
// Signed fixed-point Q format: WL total bits, FL fractional bits
// validIn / validOut handshake, dbz output (divide-by-zero flag)

`timescale 1ns/1ps
module complex_divide_cordic #(
    parameter integer WL = 32,          // total width (signed)
    parameter integer FL = 16,          // fractional bits
    parameter integer CORDIC_ITERS = 31 // number of CORDIC iterations (<= WL-1)
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     validIn,
    input  wire signed [WL-1:0]     num_re,
    input  wire signed [WL-1:0]     num_im,
    input  wire signed [WL-1:0]     den_re,
    input  wire signed [WL-1:0]     den_im,
    output reg  signed [WL-1:0]     out_re,
    output reg  signed [WL-1:0]     out_im,
    output reg                      dbz,      // divide-by-zero indicator
    output reg                      validOut
);

    // Stage 1: CORDIC vectoring: rotate denom to real axis and rotate numerator with same rotation.
    // Inputs: den_re/den_im, num_re/num_im
    // Outputs: den_real_rot (magnitude scaled by cordic K), num_re_rot, num_im_rot, valid1
    wire signed [WL-1:0] den_real_rot;
    wire signed [WL-1:0] num_re_rot;
    wire signed [WL-1:0] num_im_rot;
    wire                 cordic_valid;

    cordic_vectoring #(.WL(WL), .FL(FL), .ITERS(CORDIC_ITERS)) cordic_i (
        .clk(clk), .rstn(rstn), .validIn(validIn),
        .x_in(den_re), .y_in(den_im),
        .x_num_in(num_re), .y_num_in(num_im),
        .x_out(den_real_rot), .unused_y_out(), // denom imag goes to 0 ; we only need real
        .x_num_out(num_re_rot), .y_num_out(num_im_rot),
        .validOut(cordic_valid)
    );

    // Stage 2: Divide num_rot* / den_real_rot (both signed fixed point)
    // We compute real result = num_rot_re / den_real_rot and imag result = num_rot_im / den_real_rot.
    // Use two parallel restoring_divider instances (one for real, one for imag).
    wire signed [WL-1:0] quot_re;
    wire signed [WL-1:0] quot_im;
    wire                 div_valid;

    // divide-by-zero detect (denominator close to zero)
    // We pick absolute threshold for dbz: if denom == 0 exactly -> dbz
    wire den_is_zero = (den_real_rot == 0);

    restoring_divider #(.WL(WL), .FL(FL)) div_re (
        .clk(clk), .rstn(rstn), .start(cordic_valid && !den_is_zero),
        .a(num_re_rot), .b(den_real_rot),
        .quotient(quot_re), .done(div_valid)
    );

    restoring_divider #(.WL(WL), .FL(FL)) div_im (
        .clk(clk), .rstn(rstn), .start(cordic_valid && !den_is_zero),
        .a(num_im_rot), .b(den_real_rot),
        .quotient(quot_im), .done() // tie done to same div_valid via common start
    );

    // Combine outputs and handshake
    // simple pipeline: when divider done, output values
    reg div_valid_d;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_re <= 0; out_im <= 0; dbz <= 0; validOut <= 0; div_valid_d <= 0;
        end else begin
            div_valid_d <= div_valid;
            if (div_valid) begin
                out_re <= quot_re;
                out_im <= quot_im;
                dbz <= den_is_zero; // if zero, quotient undefined, we still output 0s
                validOut <= 1'b1;
            end else begin
                validOut <= 1'b0;
            end
        end
    end

endmodule
