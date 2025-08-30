// ============================================================================
// Module 1: Complex Multiplier
// ============================================================================
module complex_mult (
    input signed [15:0] ar, ai,  // First complex number (real, imag)
    input signed [15:0] br, bi,  // Second complex number (real, imag)
    output signed [31:0] pr, pi   // Product (real, imag)
);
    wire signed [31:0] mult1, mult2, mult3, mult4;
    
    assign mult1 = ar * br;
    assign mult2 = ai * bi;
    assign mult3 = ar * bi;
    assign mult4 = ai * br;
    
    assign pr = mult1 - mult2;
    assign pi = mult3 + mult4;
endmodule