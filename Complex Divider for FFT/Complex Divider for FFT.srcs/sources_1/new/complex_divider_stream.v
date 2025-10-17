`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// complex_divider_stream.v
// Fully synthesizable complex divider for FFT streaming outputs
// Computes (A + jB) / (C + jD)
// Fixed version - properly handles fixed-point arithmetic
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
                denom_s1    <= (denom_comb == 0) ? {{(W2-1){1'b0}}, 1'b1} : denom_comb; // avoid /0
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
            // stage 0
            num_real_pipe[0] <= num_real_s1;
            num_imag_pipe[0] <= num_imag_s1;
            valid_pipe[0]    <= v_s1;
            last_pipe[0]     <= last_s1;
            // shift
            for (i=1;i<RECIP_LAT;i=i+1) begin
                num_real_pipe[i] <= num_real_pipe[i-1];
                num_imag_pipe[i] <= num_imag_pipe[i-1];
                valid_pipe[i]    <= valid_pipe[i-1];
                last_pipe[i]     <= last_pipe[i-1];
            end
        end
    end

    // === Stage 2: Multiply Numerators × Reciprocal ===
    // Convert reciprocal to signed
    wire signed [RECIP_W-1:0] recip_signed = $signed(recip_out);

    localparam integer PROD_W = (W2+1) + RECIP_W;
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

    // === Stage 3: Scale and truncate back to IN_W ===
    // Fixed-point analysis:
    // Inputs: Q(FRAC)
    // Numerators: Q(2*FRAC) [after multiplication]
    // Reciprocal: Q(RECIP_FRAC) [reciprocal of Q(2*FRAC)]
    // Product: Q(2*FRAC + RECIP_FRAC)
    // Output: Q(FRAC) [so we need to shift right by (FRAC + RECIP_FRAC)]
    
    localparam integer TOTAL_FRAC_BITS = 2*FRAC + RECIP_FRAC;
    localparam integer SHIFT_AMOUNT = TOTAL_FRAC_BITS - FRAC; // = FRAC + RECIP_FRAC
    
    // Simple right shift (remove complex rounding that was causing zeros)
    wire signed [PROD_W-1:0] scaled_real = prod_real >>> SHIFT_AMOUNT;
    wire signed [PROD_W-1:0] scaled_imag = prod_imag >>> SHIFT_AMOUNT;

    // Simple saturation function
    function signed [IN_W-1:0] saturate;
        input signed [PROD_W-1:0] value;
        reg signed [IN_W:0] max_positive;
        reg signed [IN_W:0] max_negative;
        begin
            max_positive = (1 << (IN_W-1)) - 1;  // 2^(IN_W-1)-1
            max_negative = -(1 << (IN_W-1));     // -2^(IN_W-1)
            
            if (value > max_positive)
                saturate = max_positive[IN_W-1:0];
            else if (value < max_negative)
                saturate = max_negative[IN_W-1:0];
            else
                saturate = value[IN_W-1:0];
        end
    endfunction

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
            bypass_active <= 1'b0; // Simple version - no bypass
            
            if (prod_valid) begin
                out_real <= saturate(scaled_real);
                out_imag <= saturate(scaled_imag);
                
                // Simple overflow detection
                real_overflow <= (scaled_real > ((1 << (IN_W-1)) - 1)) || (scaled_real < -(1 << (IN_W-1)));
                imag_overflow <= (scaled_imag > ((1 << (IN_W-1)) - 1)) || (scaled_imag < -(1 << (IN_W-1)));
            end else begin
                real_overflow <= 1'b0;
                imag_overflow <= 1'b0;
            end
        end
    end

endmodule