// ============================================================================
// Module 2: Butterfly Unit
// ============================================================================
module butterfly_unit (
    input signed [15:0] ar, ai,      // Input A (real, imag)
    input signed [15:0] br, bi,      // Input B (real, imag)
    input signed [15:0] wr, wi,      // Twiddle factor (real, imag)
    output reg signed [15:0] cr, ci, // Output C (real, imag)
    output reg signed [15:0] dr, di  // Output D (real, imag)
);
    wire signed [31:0] prod_r, prod_i;
    reg signed [16:0] sum_r, sum_i, diff_r, diff_i;
    
    // Complex multiplication B * W
    complex_mult mult_inst (
        .ar(br), .ai(bi),
        .br(wr), .bi(wi),
        .pr(prod_r), .pi(prod_i)
    );
    
    // Butterfly operations with scaling
    always @(*) begin
        // Scale down the product
        sum_r = ar + (prod_r >>> 15);
        sum_i = ai + (prod_i >>> 15);
        diff_r = ar - (prod_r >>> 15);
        diff_i = ai - (prod_i >>> 15);
        
        // Saturate outputs
        cr = (sum_r > 32767) ? 16'd32767 : (sum_r < -32768) ? -16'd32768 : sum_r[15:0];
        ci = (sum_i > 32767) ? 16'd32767 : (sum_i < -32768) ? -16'd32768 : sum_i[15:0];
        dr = (diff_r > 32767) ? 16'd32767 : (diff_r < -32768) ? -16'd32768 : diff_r[15:0];
        di = (diff_i > 32767) ? 16'd32767 : (diff_i < -32768) ? -16'd32768 : diff_i[15:0];
    end
endmodule
