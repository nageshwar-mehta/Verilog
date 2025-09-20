`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2025 10:37:17
// Design Name: 
// Module Name: complex_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//Hs1_cap = Y(f)/S(f) [ Q1.15 ]
//Y = y_re + y_im [ Q1.15 ]
//S = s_re + s_im [ Q1.15 ]
module complex_divider(
    input  signed [15:0] y_re, y_im,  // numerator Y(f)
    input  signed [15:0] s_re, s_im,  // denominator S(f)
    output signed [15:0] h_re, h_im   // result H(f)
);

    // Products [ Q2.30 ]
    wire signed [31:0] yre_sre = y_re * s_re;
    wire signed [31:0] yim_sim = y_im * s_im;
    wire signed [31:0] yim_sre = y_im * s_re;
    wire signed [31:0] yre_sim = y_re * s_im;

    // Numerators (sign-extend one bit before sum to avoid overflow) [ Q3.30 ] 
    wire signed [32:0] num_re = {yre_sre[31], yre_sre} + {yim_sim[31], yim_sim};
    wire signed [32:0] num_im = {yim_sre[31], yim_sre} - {yre_sim[31], yre_sim};
                                     

    // Denominator (always >=0, but keep signed for consistency)
    wire signed [31:0] sre_sre = s_re * s_re;//[ Q2.30 ] 
    wire signed [31:0] sim_sim = s_im * s_im;//[ Q2.30 ] 
    wire signed [32:0] denom   = {sre_sre[31] , sre_sre} + {sim_sim[31] , sim_sim};//[ Q3.30 ] 

    // Avoid div-by-zero [ Q3.30 ] 
    wire signed [32:0] denom_safe = (denom == 0) ? 1 : denom;
    
//     Reciprocal calculation  
//-----------------------DOUBT---------------------------------------// [ what should be the bit width of the result after division ]
    // Division (Using operator directly) [ Q3.30 ]---->???
    wire signed [32:0] div_re = num_re / denom_safe;
    wire signed [32:0] div_im = num_im / denom_safe;

    // Scale back to Q1.15 (truncate)
    assign h_re = div_re[30: 15];
    assign h_im = div_im[30: 15];

endmodule
