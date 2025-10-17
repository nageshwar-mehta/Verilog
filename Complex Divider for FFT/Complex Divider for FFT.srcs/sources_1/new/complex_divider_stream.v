`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// complex_divider_stream.v
// Fully synthesizable complex divider for FFT streaming outputs
// Computes (A + jB) / (C + jD)
// Enhanced version with bypass mode, overflow detection, and pipeline balancing
// Author: Nageshwar Kumar
// Date: 17-Oct-2025
//////////////////////////////////////////////////////////////////////////////////

module complex_divider_stream #(
    parameter integer IN_W       = 16,   // Input width (signed)
    parameter integer FRAC       = 12,   // Fractional bits of inputs (Q format)
    parameter integer RECIP_W    = 32,   // Width of reciprocal output
    parameter integer RECIP_FRAC = 28    // Fractional bits of reciprocal
)(
    input  wire                    clk,
    input  wire                    rstn,      // active low reset

    // streaming inputs (numerator = FFT1, divisor = FFT2)
    input  wire                    in_valid,
    input  wire                    in_last,
    input  wire signed [IN_W-1:0]  a_real,
    input  wire signed [IN_W-1:0]  a_imag,
    input  wire signed [IN_W-1:0]  b_real,
    input  wire signed [IN_W-1:0]  b_imag,

    // streaming outputs
    output reg                     out_valid,
    output reg                     out_last,
    output reg signed [IN_W-1:0]   out_real,
    output reg signed [IN_W-1:0]   out_imag,
    
    // Debug outputs
    output reg                     real_overflow,
    output reg                     imag_overflow,
    output reg                     bypass_active
);

    localparam integer W2 = 2*IN_W;
    localparam integer RECIP_LAT = RECIP_FRAC; // latency = OUT_FRAC stages of reciprocal pipeline

    // === Bypass detection ===
    wire denominator_is_one = (b_real == (1 << FRAC)) && (b_imag == 0); // Check if denominator is 1.0 in Q format
    wire use_bypass = denominator_is_one && in_valid;

    // === Stage 0: Numerators & Denominator ===
    // Use registered multipliers to avoid timing issues
    reg signed [W2-1:0] ac, bd, bc, ad;
    reg signed [W2-1:0] c_sq, d_sq;
    
    always @(posedge clk) begin
        if (in_valid) begin
            ac <= a_real * b_real;
            bd <= a_imag * b_imag;
            bc <= a_imag * b_real;
            ad <= a_real * b_imag;
            c_sq <= b_real * b_real;
            d_sq <= b_imag * b_imag;
        end
    end

    // Add pipeline stage for multiplication results
    reg signed [W2:0] num_real_comb, num_imag_comb, denom_comb;
    reg v_d1, last_d1;
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            num_real_comb <= 0;
            num_imag_comb <= 0;
            denom_comb <= 0;
            v_d1 <= 0;
            last_d1 <= 0;
        end else begin
            v_d1 <= in_valid;
            last_d1 <= in_last;
            if (in_valid) begin
                num_real_comb <= ac + bd;  // A*C + B*D
                num_imag_comb <= bc - ad;  // B*C - A*D  
                denom_comb <= c_sq + d_sq; // C² + D²
            end
        end
    end

    // Bypass values (direct output when dividing by 1)
    wire signed [IN_W-1:0] bypass_real = a_real; // When dividing by 1+0j, output = input
    wire signed [IN_W-1:0] bypass_imag = a_imag;

    // Pipeline registers (Stage 0 ? Stage 1)
    reg signed [W2:0] num_real_s1, num_imag_s1, denom_s1;
    reg v_s1, last_s1, bypass_s1;
    reg signed [IN_W-1:0] bypass_real_s1, bypass_imag_s1;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            num_real_s1 <= 0; num_imag_s1 <= 0; denom_s1 <= 0;
            v_s1 <= 0; last_s1 <= 0; bypass_s1 <= 0;
            bypass_real_s1 <= 0; bypass_imag_s1 <= 0;
        end else begin
            v_s1 <= v_d1;
            last_s1 <= last_d1;
            bypass_s1 <= use_bypass && v_d1; // Only set bypass when valid
            if (v_d1) begin
                num_real_s1 <= num_real_comb;
                num_imag_s1 <= num_imag_comb;
                denom_s1    <= (denom_comb == 0) ? {{(W2){1'b0}}, 1'b1} : denom_comb; // avoid /0, ensure proper width
                bypass_real_s1 <= bypass_real;
                bypass_imag_s1 <= bypass_imag;
            end
        end
    end

    // === Stage 1: Pipelined Reciprocal ===
    wire [RECIP_W-1:0] recip_out;
    wire recip_valid;

    pipelined_reciprocal #(
        .IN_W(W2+1),
        .OUT_W(RECIP_W),
        .OUT_FRAC(RECIP_FRAC)
    ) recip_inst (
        .clk(clk),
        .rstn(rstn),
        .denom_in(denom_s1),
        .denom_valid(v_s1 && !bypass_s1), // Don't compute reciprocal in bypass mode
        .recip_out(recip_out),
        .recip_valid(recip_valid)
    );

    // === Pipeline balancing - align all signals with reciprocal latency ===
    reg signed [W2:0] num_real_pipe [0:RECIP_LAT];
    reg signed [W2:0] num_imag_pipe [0:RECIP_LAT];
    reg valid_pipe [0:RECIP_LAT];
    reg last_pipe  [0:RECIP_LAT];
    reg bypass_pipe [0:RECIP_LAT];
    reg signed [IN_W-1:0] bypass_real_pipe [0:RECIP_LAT];
    reg signed [IN_W-1:0] bypass_imag_pipe [0:RECIP_LAT];

    integer i;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<=RECIP_LAT;i=i+1) begin
                num_real_pipe[i] <= 0;
                num_imag_pipe[i] <= 0;
                valid_pipe[i]    <= 0;
                last_pipe[i]     <= 0;
                bypass_pipe[i]   <= 0;
                bypass_real_pipe[i] <= 0;
                bypass_imag_pipe[i] <= 0;
            end
        end else begin
            // stage 0
            num_real_pipe[0] <= num_real_s1;
            num_imag_pipe[0] <= num_imag_s1;
            valid_pipe[0]    <= v_s1;
            last_pipe[0]     <= last_s1;
            bypass_pipe[0]   <= bypass_s1;
            bypass_real_pipe[0] <= bypass_real_s1;
            bypass_imag_pipe[0] <= bypass_imag_s1;
            
            // shift
            for (i=1;i<=RECIP_LAT;i=i+1) begin
                num_real_pipe[i] <= num_real_pipe[i-1];
                num_imag_pipe[i] <= num_imag_pipe[i-1];
                valid_pipe[i]    <= valid_pipe[i-1];
                last_pipe[i]     <= last_pipe[i-1];
                bypass_pipe[i]   <= bypass_pipe[i-1];
                bypass_real_pipe[i] <= bypass_real_pipe[i-1];
                bypass_imag_pipe[i] <= bypass_imag_pipe[i-1];
            end
        end
    end

    // === Stage 2: Multiply Numerators × Reciprocal ===
    // Convert reciprocal to signed
    wire signed [RECIP_W-1:0] recip_signed = $signed(recip_out);
    
    localparam integer PROD_W = (W2+1) + RECIP_W;
    reg signed [PROD_W-1:0] prod_real, prod_imag;
    reg prod_valid, prod_last, prod_bypass;
    reg signed [IN_W-1:0] prod_bypass_real, prod_bypass_imag;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prod_real <= 0; prod_imag <= 0; 
            prod_valid <= 0; prod_last <= 0; prod_bypass <= 0;
            prod_bypass_real <= 0; prod_bypass_imag <= 0;
        end else begin
            prod_valid <= (recip_valid && !bypass_pipe[RECIP_LAT]) || (valid_pipe[RECIP_LAT] && bypass_pipe[RECIP_LAT]);
            prod_last  <= last_pipe[RECIP_LAT];
            prod_bypass <= bypass_pipe[RECIP_LAT];
            prod_bypass_real <= bypass_real_pipe[RECIP_LAT];
            prod_bypass_imag <= bypass_imag_pipe[RECIP_LAT];
            
            if (recip_valid && !bypass_pipe[RECIP_LAT]) begin
                // Normal division path
                prod_real <= $signed(num_real_pipe[RECIP_LAT]) * recip_signed;
                prod_imag <= $signed(num_imag_pipe[RECIP_LAT]) * recip_signed;
            end else if (valid_pipe[RECIP_LAT] && bypass_pipe[RECIP_LAT]) begin
                // Bypass path - set products to appropriate values for scaling
                prod_real <= $signed(bypass_real_pipe[RECIP_LAT]) * (1 << (RECIP_FRAC + FRAC));
                prod_imag <= $signed(bypass_imag_pipe[RECIP_LAT]) * (1 << (RECIP_FRAC + FRAC));
            end
        end
    end

    // === Stage 3: Scale, round, and saturate back to IN_W ===
    // Fixed-point analysis:
    // Inputs: Q(FRAC)
    // Numerators: Q(2*FRAC) [after multiplication]
    // Reciprocal: Q(RECIP_FRAC) [reciprocal of Q(2*FRAC)]
    // Product: Q(2*FRAC + RECIP_FRAC)
    // Output: Q(FRAC) [so we need to shift right by (FRAC + RECIP_FRAC)]
    
    localparam integer TOTAL_FRAC_BITS = 2*FRAC + RECIP_FRAC;
    localparam integer SHIFT_AMOUNT = TOTAL_FRAC_BITS - FRAC; // = FRAC + RECIP_FRAC
    
    // For bypass case, we need different scaling since we multiplied by 2^(RECIP_FRAC+FRAC)
    localparam integer BYPASS_SHIFT = RECIP_FRAC + FRAC;
    
    // Choose appropriate scaling based on path
    wire signed [PROD_W-1:0] scaled_real = prod_bypass ? 
                                          (prod_real >>> BYPASS_SHIFT) : 
                                          (prod_real >>> SHIFT_AMOUNT);
    wire signed [PROD_W-1:0] scaled_imag = prod_bypass ? 
                                          (prod_imag >>> BYPASS_SHIFT) : 
                                          (prod_imag >>> SHIFT_AMOUNT);

    // Improved saturation function with overflow detection
    function automatic [IN_W:0] saturate_with_overflow; // Returns {overflow, value}
        input signed [PROD_W-1:0] value;
        reg signed [IN_W:0] max_positive;
        reg signed [IN_W:0] max_negative;
        reg overflow;
        reg signed [IN_W-1:0] saturated_value;
        begin
            max_positive = (1 << (IN_W-1)) - 1;  // 2^(IN_W-1)-1
            max_negative = -(1 << (IN_W-1));     // -2^(IN_W-1)
            
            overflow = 1'b0;
            if (value > max_positive) begin
                saturated_value = max_positive[IN_W-1:0];
                overflow = 1'b1;
            end else if (value < max_negative) begin
                saturated_value = max_negative[IN_W-1:0];
                overflow = 1'b1;
            end else begin
                saturated_value = value[IN_W-1:0];
            end
            
            saturate_with_overflow = {overflow, saturated_value};
        end
    endfunction

    // Apply saturation
    wire [IN_W:0] saturated_real = saturate_with_overflow(scaled_real);
    wire [IN_W:0] saturated_imag = saturate_with_overflow(scaled_imag);

    // Output registers
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_real <= 0; 
            out_imag <= 0; 
            out_valid <= 0; 
            out_last <= 0;
            real_overflow <= 0;
            imag_overflow <= 0;
            bypass_active <= 0;
        end else begin
            out_valid <= prod_valid;
            out_last  <= prod_last;
            bypass_active <= prod_bypass;
            
            if (prod_valid) begin
                out_real <= saturated_real[IN_W-1:0];
                out_imag <= saturated_imag[IN_W-1:0];
                real_overflow <= saturated_real[IN_W];
                imag_overflow <= saturated_imag[IN_W];
            end else begin
                real_overflow <= 1'b0;
                imag_overflow <= 1'b0;
            end
        end
    end

endmodule