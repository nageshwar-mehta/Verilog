`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_complex_divider_stream.v
//////////////////////////////////////////////////////////////////////////////////
module tb_complex_divider_stream;

    parameter IN_W = 16;
    parameter FRAC = 12;
    parameter RECIP_W = 32;
    parameter RECIP_FRAC = 28;

    reg clk, rstn;
    reg in_valid, in_last;
    reg signed [IN_W-1:0] a_real, a_imag, b_real, b_imag;

    wire out_valid, out_last;
    wire signed [IN_W-1:0] out_real, out_imag;

    // DUT
    complex_divider_stream #(
        .IN_W(IN_W),
        .FRAC(FRAC),
        .RECIP_W(RECIP_W),
        .RECIP_FRAC(RECIP_FRAC)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .in_last(in_last),
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_real(out_real),
        .out_imag(out_imag)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    integer i;
    initial begin
        clk = 0; rstn = 0; in_valid = 0; in_last = 0;
        a_real = 0; a_imag = 0; b_real = 0; b_imag = 0;
        #40; rstn = 1;

        // Feed 64 pseudo FFT points (streamed one per clk)
        for (i=0; i<64; i=i+1) begin
            @(posedge clk);
            in_valid <= 1;
            in_last  <= (i==63);
            a_real <= $signed($random % 2000);
            a_imag <= $signed($random % 2000);
            // avoid zero divisor
            b_real <= ($random % 2000) + 20;
            b_imag <= ($random % 2000) + 10;
        end

        @(posedge clk);
        in_valid <= 0;
        in_last  <= 0;

        // Let pipeline flush
        repeat(RECIP_FRAC+20) @(posedge clk);

        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        if (out_valid) begin
            $display("t=%0t | OutR=%d, OutI=%d, last=%b", $time, out_real, out_imag, out_last);
        end
    end

endmodule
