`timescale 1ns / 1ps

module thresholding #(
    parameter WIDTH = 16
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     in_valid,
    input  wire                     in_last,
    input  wire signed [WIDTH-1:0] h_re,
    input  wire signed [WIDTH-1:0] h_im,
    input  wire        [WIDTH:0]   sigma,       // median(|Di|)/0.6743

    output reg signed [WIDTH-1:0]  hs1_re_out,
    output reg signed [WIDTH-1:0]  hs1_im_out,
    output reg                     out_valid,
    output reg                     out_last
);

    // absolute values
    wire [WIDTH-1:0] abs_re = h_re[WIDTH-1] ? (~h_re + 1'b1) : h_re;
    wire [WIDTH-1:0] abs_im = h_im[WIDTH-1] ? (~h_im + 1'b1) : h_im;
    wire [WIDTH:0] h_abs = abs_re + abs_im;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            hs1_re_out <= 0;
            hs1_im_out <= 0;
            out_valid  <= 0;
            out_last   <= 0;
        end
        else begin
            out_valid <= 0;
            out_last  <= 0;

            if(in_valid) begin
                // threshold check
                if(h_abs >= sigma) begin
                    hs1_re_out <= h_re;
                    hs1_im_out <= h_im;
                end
                else begin
                    hs1_re_out <= 0;
                    hs1_im_out <= 0;
                end

                out_valid <= 1;

                if(in_last)
                    out_last <= 1;
            end
        end
    end

endmodule
