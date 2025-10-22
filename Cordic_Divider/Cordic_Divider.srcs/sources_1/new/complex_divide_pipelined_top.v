// complex_divide_pipelined_top.v
`timescale 1ns/1ps
module complex_divide_pipelined_top #(
    parameter WL = 32,
    parameter FL = 16,
    parameter ITERS = 31
)(
    input  wire                 clk,
    input  wire                 rstn,
    input  wire                 validIn,
    input  wire signed [WL-1:0] num_re,
    input  wire signed [WL-1:0] num_im,
    input  wire signed [WL-1:0] den_re,
    input  wire signed [WL-1:0] den_im,
    output wire signed [WL-1:0] out_re,
    output wire signed [WL-1:0] out_im,
    output wire                 dbz,
    output wire                 validOut
);

    wire signed [WL-1:0] den_re_rot, den_im_rot, num_re_rot, num_im_rot;
    wire cordic_valid;

    cordic_pipeline_pair #(.WL(WL), .FL(FL), .ITERS(ITERS)) cord_pair (
        .clk(clk), .rstn(rstn), .validIn(validIn),
        .x_in(den_re), .y_in(den_im),
        .xn_in(num_re), .yn_in(num_im),
        .x_out(den_re_rot), .y_out(den_im_rot),
        .xn_out(num_re_rot), .yn_out(num_im_rot),
        .validOut(cordic_valid)
    );

    // divide-by-zero: check denominator magnitude approx equal to zero
    // since den_re_rot should be positive magnitude (y?0), dbz when den_re_rot==0
    wire den_zero = (den_re_rot == 0);

    // instantiate two restoring dividers in parallel (real and imag)
    wire signed [WL-1:0] quot_re;
    wire signed [WL-1:0] quot_im;
    wire div_done_re, div_done_im;

    // Start divider after cordic_valid and not dbz
    wire start_div = cordic_valid && !den_zero;

    restoring_divider #(.WL(WL), .FL(FL)) div_re (
        .clk(clk), .rstn(rstn), .start(start_div), .a(num_re_rot), .b(den_re_rot),
        .quotient(quot_re), .done(div_done_re)
    );

    restoring_divider #(.WL(WL), .FL(FL)) div_im (
        .clk(clk), .rstn(rstn), .start(start_div), .a(num_im_rot), .b(den_re_rot),
        .quotient(quot_im), .done(div_done_im)
    );

    // combine done and produce outputs
    // simple handshake: when div_done_re asserted, we output
    reg out_valid;
    reg signed [WL-1:0] out_re_r, out_im_r;
    reg dbz_r;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_valid <= 1'b0; out_re_r <= 0; out_im_r <= 0; dbz_r <= 1'b0;
        end else begin
            out_valid <= 1'b0;
            if (div_done_re) begin
                out_re_r <= quot_re;
                out_im_r <= quot_im;
                dbz_r <= den_zero;
                out_valid <= 1'b1;
            end else if (cordic_valid && den_zero) begin
                // if denom zero then produce dbz output (one cycle later propagate)
                out_re_r <= 0; out_im_r <= 0; dbz_r <= 1'b1; out_valid <= 1'b1;
            end
        end
    end

    assign out_re = out_re_r;
    assign out_im = out_im_r;
    assign dbz = dbz_r;
    assign validOut = out_valid;

endmodule
