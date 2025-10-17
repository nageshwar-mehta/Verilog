`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2025 09:19:59
// Design Name: IFFT 64-point
// Module Name: IFFT64pt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Implements 64-point IFFT using FFT64pt core.
//               - Conjugates input imaginary part
//               - Uses FFT64pt module internally
//               - Conjugates output imaginary part
//               - Divides result by 64 (>>6)
// 
// Dependencies: FFT64pt module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IFFT64pt #(
    parameter integer WIDTH    = 16,
    parameter integer QF       = 9,    // fractional bits (Qm.QF)
    parameter integer TW_WIDTH = 16    // twiddle constant width
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     in_valid,
    input  signed [WIDTH-1:0]       in_real,
    input  signed [WIDTH-1:0]       in_imag,
    output reg                      out_valid,
    output reg                      out_last,
    output reg signed [WIDTH-1:0]   out_real,
    output reg signed [WIDTH-1:0]   out_imag
);

    // Internal signals
    wire                      out_valid_temp;
    wire                      out_last_temp;
    wire signed [WIDTH-1:0]   out_real_temp;
    wire signed [WIDTH-1:0]   out_imag_temp;

    // Instantiate FFT64pt core
    FFT64pt FFT_module1 (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .in_real(in_real),
        .in_imag(~in_imag + 1'b1),  // conjugate input imag
        .out_valid(out_valid_temp),
        .out_last(out_last_temp),
        .out_real(out_real_temp),
        .out_imag(out_imag_temp)
    );

    // Post-processing (conjugate + scale by N=64)
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_valid <= 0;
            out_last  <= 0;
            out_real  <= 0;
            out_imag  <= 0;
        end else begin
            out_valid <= out_valid_temp;
            out_last  <= out_last_temp;
            out_real  <= out_real_temp >>> 6;         // divide by 64
            out_imag  <= (~(out_imag_temp>>>6) + 1'b1) ; // conjugate output imag
        end
    end

endmodule
