`timescale 1ns / 1ps

module nagesh_divider
  #( parameter QF = 9,
     parameter IN_W = 16)
  ( input  [IN_W-1:0] a_re, a_im, b_re, b_im,
    input              rstn, in_valid,
    output reg [IN_W-1:0] out_re, out_im,
    output reg          overflow );

    //===========Factorization===========//
    wire [2*IN_W-1:0] real_numr = a_re * b_re + a_im * b_im;
    wire [2*IN_W-1:0] imag_numr = a_re * b_im - a_im * b_re;
    wire [2*IN_W-1:0] denr      = b_re * b_re + b_im * b_im;

    reg [2*IN_W-1:0] temp_real_out, temp_imag_out;

    always @(*) begin
        if (!rstn) begin
            overflow = 1'b0;
            out_re = 0;
            out_im = 0;
        end else begin
            overflow = 1'b0;  // default state each evaluation

            if(in_valid)begin// Real part
            temp_real_out = real_numr / denr;
            if (|temp_real_out[2*IN_W-1:IN_W+QF] && 
               ~&temp_real_out[2*IN_W-1:IN_W+QF]) begin
                overflow = 1'b1;
                out_re = 0;
            end else begin
                out_re = temp_real_out[IN_W+QF-1:QF];
            end

            // Imaginary part
            temp_imag_out = imag_numr / denr;
            if (|temp_imag_out[2*IN_W-1:IN_W+QF] && 
               ~&temp_imag_out[2*IN_W-1:IN_W+QF]) begin
                overflow = 1'b1;
                out_im = 0;
            end else begin
                out_im = temp_imag_out[IN_W+QF-1:QF];
            end
        end
        end
        else begin
        overflow = 1'b0;
            out_re = 0;
            out_im = 0;
        end
    end
endmodule
