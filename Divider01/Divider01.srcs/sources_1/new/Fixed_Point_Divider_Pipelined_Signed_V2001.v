`timescale 1ns / 1ps

module Fixed_Point_Divider_Pipelined_Signed_V2001 #(
    parameter N = 16,   // total bits
    parameter Q = 9     // fractional bits
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                i_valid,
    input  wire signed [N-1:0] i_dividend,
    input  wire signed [N-1:0] i_divisor,
    output reg  signed [N-1:0] o_quotient,
    output reg                 o_valid,
    output reg                 o_overflow
);

    // ----------------------------------------------------------------
    // Local constants and derived parameters
    // ----------------------------------------------------------------
    localparam STAGES = N + Q;
    localparam EXT_WIDTH = N + Q;
    
    // Precompute all divisor shifts at design time for true pipelining
    // This ensures each stage has fixed, pre-determined shift amount

    // ----------------------------------------------------------------
    // Pipeline registers - truly independent stages
    // ----------------------------------------------------------------
    reg [EXT_WIDTH-1:0] remainder [0:STAGES];
    reg [EXT_WIDTH-1:0] divisor_shifted [0:STAGES];
    reg [EXT_WIDTH-1:0] quotient_bits [0:STAGES];
    reg sign [0:STAGES];
    reg valid [0:STAGES];
    
    // Input staging for final output calculation
    reg signed [N-1:0] dividend_pipe [0:STAGES];
    reg signed [N-1:0] divisor_pipe [0:STAGES];

    // ----------------------------------------------------------------
    // Stage 0: Input Registration and Absolute Value Conversion
    // ----------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid[0] <= 1'b0;
            remainder[0] <= 0;
            divisor_shifted[0] <= 0;
            quotient_bits[0] <= 0;
            sign[0] <= 0;
            dividend_pipe[0] <= 0;
            divisor_pipe[0] <= 0;
        end else begin
            valid[0] <= i_valid;
            
            if (i_valid) begin
                // Convert to absolute values for unsigned division
                remainder[0] <= {(i_dividend[N-1] ? (-i_dividend) : i_dividend), {Q{1'b0}}};
                divisor_shifted[0] <= {(i_divisor[N-1] ? (-i_divisor) : i_divisor), {Q{1'b0}}};
                quotient_bits[0] <= 0;
                sign[0] <= i_dividend[N-1] ^ i_divisor[N-1];
                dividend_pipe[0] <= i_dividend;
                divisor_pipe[0] <= i_divisor;
            end else begin
                // Clear pipeline when no valid input
                remainder[0] <= 0;
                divisor_shifted[0] <= 0;
                quotient_bits[0] <= 0;
                sign[0] <= 0;
                dividend_pipe[0] <= 0;
                divisor_pipe[0] <= 0;
            end
        end
    end

    // ----------------------------------------------------------------
    // Pipeline Stages 1 to STAGES - True Single-Cycle Throughput
    // ----------------------------------------------------------------
    genvar stage;
    generate
        for (stage = 1; stage <= STAGES; stage = stage + 1) begin : division_stages
            // Pre-computed shift amount for this specific stage
            localparam SHIFT_AMOUNT = STAGES - stage;
            reg [EXT_WIDTH-1:0] divisor_at_stage;
            
            // Combinational logic for this stage's divisor value
            always @* begin
                divisor_at_stage = divisor_shifted[stage-1] >>> SHIFT_AMOUNT;
            end
            
            // Registered pipeline stage
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    remainder[stage] <= 0;
                    divisor_shifted[stage] <= 0;
                    quotient_bits[stage] <= 0;
                    sign[stage] <= 0;
                    valid[stage] <= 0;
                    dividend_pipe[stage] <= 0;
                    divisor_pipe[stage] <= 0;
                end else begin
                    // Pipeline propagation
                    valid[stage] <= valid[stage-1];
                    sign[stage] <= sign[stage-1];
                    divisor_shifted[stage] <= divisor_shifted[stage-1];
                    dividend_pipe[stage] <= dividend_pipe[stage-1];
                    divisor_pipe[stage] <= divisor_pipe[stage-1];
                    
                    // Division algorithm - fixed operation per stage
                    if (remainder[stage-1] >= divisor_at_stage) begin
                        remainder[stage] <= remainder[stage-1] - divisor_at_stage;
                        quotient_bits[stage] <= {quotient_bits[stage-1][EXT_WIDTH-2:0], 1'b1};
                    end else begin
                        remainder[stage] <= remainder[stage-1];
                        quotient_bits[stage] <= {quotient_bits[stage-1][EXT_WIDTH-2:0], 1'b0};
                    end
                end
            end
        end
    endgenerate

    // ----------------------------------------------------------------
    // Output Stage - Registered Outputs
    // ----------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_valid <= 0;
            o_overflow <= 0;
            o_quotient <= 0;
        end else begin
            o_valid <= valid[STAGES];
            
            if (valid[STAGES]) begin
                // Apply sign correction
                if (sign[STAGES]) begin
                    o_quotient <= -quotient_bits[STAGES][N-1:0];
                end else begin
                    o_quotient <= quotient_bits[STAGES][N-1:0];
                end
                
                // Overflow detection
                if (divisor_pipe[STAGES] == 0) begin
                    o_overflow <= 1'b1;  // Division by zero
                end else if (quotient_bits[STAGES][EXT_WIDTH-1:N] != 0) begin
                    o_overflow <= 1'b1;  // Result exceeds N bits
                end else begin
                    o_overflow <= 1'b0;
                end
            end else begin
                o_quotient <= 0;
                o_overflow <= 0;
            end
        end
    end

endmodule