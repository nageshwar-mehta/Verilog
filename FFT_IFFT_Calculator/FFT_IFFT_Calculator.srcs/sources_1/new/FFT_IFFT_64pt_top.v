
// ============================================================================
// Module 7: Top Module - 64-point FFT/IFFT (with flattened ports)
// ============================================================================
module FFT_IFFT_64pt_top (
    input clk,
    input rst,
    input start,
    input ifft_mode,  // 0: FFT, 1: IFFT
    input [1023:0] data_in_real,  // 64 * 16 bits = 1024 bits
    input [1023:0] data_in_imag,  // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_real, // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_imag, // 64 * 16 bits = 1024 bits
    output reg done,
    output reg busy
);
    // State machine states
    localparam IDLE = 4'd0;
    localparam BIT_REV = 4'd1;
    localparam STAGE0 = 4'd2;
    localparam STAGE1 = 4'd3;
    localparam STAGE2 = 4'd4;
    localparam STAGE3 = 4'd5;
    localparam STAGE4 = 4'd6;
    localparam STAGE5 = 4'd7;
    localparam SCALING = 4'd8;
    localparam DONE = 4'd9;
    
    reg [3:0] state, next_state;
    
    // Internal data buses
    wire [1023:0] bit_rev_out_real;
    wire [1023:0] bit_rev_out_imag;
    wire [1023:0] stage0_out_real;
    wire [1023:0] stage0_out_imag;
    wire [1023:0] stage1_out_real;
    wire [1023:0] stage1_out_imag;
    wire [1023:0] stage2_out_real;
    wire [1023:0] stage2_out_imag;
    wire [1023:0] stage3_out_real;
    wire [1023:0] stage3_out_imag;
    wire [1023:0] stage4_out_real;
    wire [1023:0] stage4_out_imag;
    wire [1023:0] stage5_out_real;
    wire [1023:0] stage5_out_imag;
    wire [1023:0] scaled_out_real;
    wire [1023:0] scaled_out_imag;
    
    // Control signals
    reg bit_rev_en, stage0_en, stage1_en, stage2_en;
    reg stage3_en, stage4_en, stage5_en, scaler_en;
    wire bit_rev_done, stage0_done, stage1_done, stage2_done;
    wire stage3_done, stage4_done, stage5_done, scaler_done;
    
    // Instantiate bit reversal
    bit_reversal bit_rev_inst (
        .clk(clk), .rst(rst),
        .enable(bit_rev_en),
        .data_in_real(data_in_real),
        .data_in_imag(data_in_imag),
        .data_out_real(bit_rev_out_real),
        .data_out_imag(bit_rev_out_imag),
        .done(bit_rev_done)
    );
    
    // Instantiate FFT stages
    fft_stage #(.STAGE_NUM(0)) stage0_inst (
        .clk(clk), .rst(rst),
        .enable(stage0_en),
        .ifft_mode(ifft_mode),
        .data_in_real(bit_rev_out_real),
        .data_in_imag(bit_rev_out_imag),
        .data_out_real(stage0_out_real),
        .data_out_imag(stage0_out_imag),
        .done(stage0_done)
    );
    
    fft_stage #(.STAGE_NUM(1)) stage1_inst (
        .clk(clk), .rst(rst),
        .enable(stage1_en),
        .ifft_mode(ifft_mode),
        .data_in_real(stage0_out_real),
        .data_in_imag(stage0_out_imag),
        .data_out_real(stage1_out_real),
        .data_out_imag(stage1_out_imag),
        .done(stage1_done)
    );
    
    fft_stage #(.STAGE_NUM(2)) stage2_inst (
        .clk(clk), .rst(rst),
        .enable(stage2_en),
        .ifft_mode(ifft_mode),
        .data_in_real(stage1_out_real),
        .data_in_imag(stage1_out_imag),
        .data_out_real(stage2_out_real),
        .data_out_imag(stage2_out_imag),
        .done(stage2_done)
    );
    
    fft_stage #(.STAGE_NUM(3)) stage3_inst (
        .clk(clk), .rst(rst),
        .enable(stage3_en),
        .ifft_mode(ifft_mode),
        .data_in_real(stage2_out_real),
        .data_in_imag(stage2_out_imag),
        .data_out_real(stage3_out_real),
        .data_out_imag(stage3_out_imag),
        .done(stage3_done)
    );
    
    fft_stage #(.STAGE_NUM(4)) stage4_inst (
        .clk(clk), .rst(rst),
        .enable(stage4_en),
        .ifft_mode(ifft_mode),
        .data_in_real(stage3_out_real),
        .data_in_imag(stage3_out_imag),
        .data_out_real(stage4_out_real),
        .data_out_imag(stage4_out_imag),
        .done(stage4_done)
    );
    
    fft_stage #(.STAGE_NUM(5)) stage5_inst (
        .clk(clk), .rst(rst),
        .enable(stage5_en),
        .ifft_mode(ifft_mode),
        .data_in_real(stage4_out_real),
        .data_in_imag(stage4_out_imag),
        .data_out_real(stage5_out_real),
        .data_out_imag(stage5_out_imag),
        .done(stage5_done)
    );
    
    // Instantiate IFFT scaler
    ifft_scaler scaler_inst (
        .clk(clk), .rst(rst),
        .enable(scaler_en),
        .data_in_real(stage5_out_real),
        .data_in_imag(stage5_out_imag),
        .data_out_real(scaled_out_real),
        .data_out_imag(scaled_out_imag),
        .done(scaler_done)
    );
    
    // State machine
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = BIT_REV;
            BIT_REV: if (bit_rev_done) next_state = STAGE0;
            STAGE0: if (stage0_done) next_state = STAGE1;
            STAGE1: if (stage1_done) next_state = STAGE2;
            STAGE2: if (stage2_done) next_state = STAGE3;
            STAGE3: if (stage3_done) next_state = STAGE4;
            STAGE4: if (stage4_done) next_state = STAGE5;
            STAGE5: if (stage5_done) next_state = ifft_mode ? SCALING : DONE;
            SCALING: if (scaler_done) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end
    
    // Output logic
    always @(posedge clk) begin
        if (rst) begin
            done <= 0;
            busy <= 0;
            bit_rev_en <= 0;
            stage0_en <= 0;
            stage1_en <= 0;
            stage2_en <= 0;
            stage3_en <= 0;
            stage4_en <= 0;
            stage5_en <= 0;
            scaler_en <= 0;
            data_out_real <= 0;
            data_out_imag <= 0;
        end else begin
            // Default values
            bit_rev_en <= 0;
            stage0_en <= 0;
            stage1_en <= 0;
            stage2_en <= 0;
            stage3_en <= 0;
            stage4_en <= 0;
            stage5_en <= 0;
            scaler_en <= 0;
            done <= 0;
            
            case (state)
                IDLE: begin
                    busy <= start;
                end
                BIT_REV: begin
                    bit_rev_en <= 1;
                    busy <= 1;
                end
                STAGE0: begin
                    stage0_en <= ~stage0_done;
                    busy <= 1;
                end
                STAGE1: begin
                    stage1_en <= ~stage1_done;
                    busy <= 1;
                end
                STAGE2: begin
                    stage2_en <= ~stage2_done;
                    busy <= 1;
                end
                STAGE3: begin
                    stage3_en <= ~stage3_done;
                    busy <= 1;
                end
                STAGE4: begin
                    stage4_en <= ~stage4_done;
                    busy <= 1;
                end
                STAGE5: begin
                    stage5_en <= ~stage5_done;
                    busy <= 1;
                end
                SCALING: begin
                    scaler_en <= ~scaler_done;
                    busy <= 1;
                end
                DONE: begin
                    done <= 1;
                    busy <= 0;
                    // Copy final output
                    if (ifft_mode) begin
                        data_out_real <= scaled_out_real;
                        data_out_imag <= scaled_out_imag;
                    end else begin
                        data_out_real <= stage5_out_real;
                        data_out_imag <= stage5_out_imag;
                    end
                end
            endcase
        end
    end
endmodule
