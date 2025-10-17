`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// complex_divider_stream.v
// Fully synthesizable complex divider for FFT streaming outputs
// Computes (A + jB) / (C + jD)
// CORRECTED scaling version
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
    localparam integer RECIP_LAT = RECIP_FRAC;

    // === Stage 0: Direct combinatorial multipliers ===
    wire signed [W2-1:0] ac = a_real * b_real;
    wire signed [W2-1:0] bd = a_imag * b_imag;
    wire signed [W2-1:0] bc = a_imag * b_real;
    wire signed [W2-1:0] ad = a_real * b_imag;
    wire signed [W2-1:0] c_sq = b_real * b_real;
    wire signed [W2-1:0] d_sq = b_imag * b_imag;

    wire signed [W2:0] num_real_comb = ac + bd;  // A*C + B*D
    wire signed [W2:0] num_imag_comb = bc - ad;  // B*C - A*D
    wire signed [W2:0] denom_comb    = c_sq + d_sq; // C² + D²

    // Pipeline registers (Stage 0 ? Stage 1)
    reg signed [W2:0] num_real_s1, num_imag_s1, denom_s1;
    reg v_s1, last_s1;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            num_real_s1 <= 0; num_imag_s1 <= 0; denom_s1 <= 0;
            v_s1 <= 0; last_s1 <= 0;
        end else begin
            v_s1 <= in_valid;
            last_s1 <= in_last;
            if (in_valid) begin
                num_real_s1 <= num_real_comb;
                num_imag_s1 <= num_imag_comb;
                denom_s1    <= (denom_comb == 0) ? {{(W2-1){1'b0}}, 1'b1} : denom_comb;
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
        .denom_valid(v_s1),
        .recip_out(recip_out),
        .recip_valid(recip_valid)
    );

    // === Align numerators with reciprocal latency ===
    reg signed [W2:0] num_real_pipe [0:RECIP_LAT-1];
    reg signed [W2:0] num_imag_pipe [0:RECIP_LAT-1];
    reg valid_pipe [0:RECIP_LAT-1];
    reg last_pipe  [0:RECIP_LAT-1];

    integer i;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<RECIP_LAT;i=i+1) begin
                num_real_pipe[i] <= 0;
                num_imag_pipe[i] <= 0;
                valid_pipe[i]    <= 0;
                last_pipe[i]     <= 0;
            end
        end else begin
            num_real_pipe[0] <= num_real_s1;
            num_imag_pipe[0] <= num_imag_s1;
            valid_pipe[0]    <= v_s1;
            last_pipe[0]     <= last_s1;
            
            for (i=1;i<RECIP_LAT;i=i+1) begin
                num_real_pipe[i] <= num_real_pipe[i-1];
                num_imag_pipe[i] <= num_imag_pipe[i-1];
                valid_pipe[i]    <= valid_pipe[i-1];
                last_pipe[i]     <= last_pipe[i-1];
            end
        end
    end

    // === Stage 2: Multiply Numerators × Reciprocal ===
    localparam integer PROD_W = (W2+1) + RECIP_W;
    
    // Convert reciprocal to signed
    wire signed [RECIP_W-1:0] recip_signed = $signed(recip_out);
    
    reg signed [PROD_W-1:0] prod_real, prod_imag;
    reg prod_valid, prod_last;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prod_real <= 0; prod_imag <= 0; prod_valid <= 0; prod_last <= 0;
        end else begin
            prod_valid <= recip_valid;
            prod_last  <= last_pipe[RECIP_LAT-1];
            if (recip_valid) begin
                prod_real <= num_real_pipe[RECIP_LAT-1] * recip_signed;
                prod_imag <= num_imag_pipe[RECIP_LAT-1] * recip_signed;
            end
        end
    end

    // === Stage 3: CORRECTED Scaling and truncation ===
    // FIXED SCALING ANALYSIS:
    // Inputs: Q12
    // Numerators: Q24 (after multiplication of two Q12 numbers)
    // Denominator: Q24 (after multiplication)
    // Reciprocal: Q28 (reciprocal of Q24 number)
    // Product: Q24 * Q28 = Q52
    // But we need output in Q12 format
    // So we shift right by: 52 - 12 = 40 bits? NO - this is wrong!
    
    // CORRECT ANALYSIS:
    // We're computing: (A/B) where A and B are Q12
    // Reciprocal gives us: 1/B in Q28 format (reciprocal of Q24 denominator)
    // When we multiply A (Q12) × (1/B) (Q28), we get result in Q40 format
    // To convert Q40 to Q12 output, we shift right by 28 bits
    
    localparam integer CORRECT_SHIFT = RECIP_FRAC; // 28 bits, not 40!
    
    // Apply scaling with rounding
    wire signed [PROD_W-1:0] scaled_real = (prod_real + (1 << (CORRECT_SHIFT-1))) >>> CORRECT_SHIFT;
    wire signed [PROD_W-1:0] scaled_imag = (prod_imag + (1 << (CORRECT_SHIFT-1))) >>> CORRECT_SHIFT;

    // Simple saturation logic
    always @(*) begin
        out_real = scaled_real[IN_W-1:0];
        out_imag = scaled_imag[IN_W-1:0];
        
        // Basic overflow detection
        real_overflow = (scaled_real > ((1 << (IN_W-1)) - 1)) || (scaled_real < -(1 << (IN_W-1)));
        imag_overflow = (scaled_imag > ((1 << (IN_W-1)) - 1)) || (scaled_imag < -(1 << (IN_W-1)));
        
        // Handle overflow by saturation
        if (real_overflow) begin
            if (scaled_real > 0)
                out_real = (1 << (IN_W-1)) - 1;
            else
                out_real = -(1 << (IN_W-1));
        end
        
        if (imag_overflow) begin
            if (scaled_imag > 0)
                out_imag = (1 << (IN_W-1)) - 1;
            else
                out_imag = -(1 << (IN_W-1));
        end
    end

    // Output registers
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            out_valid <= 0; 
            out_last <= 0;
            bypass_active <= 0;
        end else begin
            out_valid <= prod_valid;
            out_last <= prod_last;
            bypass_active <= 1'b0;
        end
    end

endmodule