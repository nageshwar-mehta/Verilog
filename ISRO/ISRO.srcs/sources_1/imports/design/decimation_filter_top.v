//2 stage pipelining



module decimation_filter_top (
    input  wire        clk,              // System clock (e.g., 1.024 MHz or higher)
    input  wire        rst_n,            // Active-low reset
    
    // Input from Delta-Sigma Modulator
    input  wire signed [3:0] modulator_in,
    input  wire        modulator_valid,
    
    // Final output
    output wire signed [23:0] audio_out,
    output wire        audio_valid,
    
    // Debug outputs (optional)
    output wire signed [22:0] cic_out,
    output wire        cic_valid,
    output wire signed [23:0] fir1_out,
    output wire        fir1_valid
);

    // Internal signals
    wire signed [22:0] cic_data;
    wire cic_data_valid;
    
    wire signed [23:0] fir1_data;
    wire fir1_data_valid;
    
    
    // ========================================
    // Pipelined registers
    // ========================================
    reg reg1_rst_n, reg2_rst_n;
    reg reg1_cic_data_valid, reg2_cic_data_valid ;
    reg signed [22:0] reg1_cic_data, reg2_cic_data;
    reg signed [23:0] reg2_fir1_data;
    reg reg2_fir1_data_valid;
    
    // ========================================
    // STAGE 1: CIC DECIMATOR
    // ========================================
    cic_decimator #(
        .INPUT_WIDTH(4),
        .DECIMATION_RATIO(64),
        .NUM_STAGES(3),
        .DIFF_DELAY(1)
    ) u_cic (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(modulator_in),
        .data_in_valid(modulator_valid),
        .data_out(cic_data),
        .data_out_valid(cic_data_valid)
    );
    
    always@(posedge clk)begin
        reg1_rst_n <= rst_n;
        reg2_rst_n <= reg1_rst_n;
        
        reg1_cic_data_valid <= cic_data_valid;
        reg2_cic_data_valid <= reg1_cic_data_valid;
        
        reg1_cic_data <= cic_data;
        reg2_cic_data  <= reg1_cic_data;
        
        reg2_fir1_data <= fir1_data;
        reg2_fir1_data_valid <= fir1_data_valid;
    end
    
    
    
    // ========================================
    // STAGE 2: CIC COMPENSATION FIR (61 TAPS)
    // ========================================
    fir_cic_compensation #(
        .INPUT_WIDTH(23),
        .OUTPUT_WIDTH(24),
        .COEFF_WIDTH(16),
        .NUM_TAPS(61),
        .DECIMATION(2)
    ) u_fir_comp (
        .clk(clk),
        .rst_n(reg1_rst_n),
        .data_in(reg1_cic_data),
        .data_in_valid(reg1_cic_data_valid),
        .data_out(fir1_data),
        .data_out_valid(fir1_data_valid)
    );
    
    // ========================================
    // STAGE 3: STANDARD LOWPASS FIR (70 TAPS)
    // ========================================
    fir_lowpass_standard #(
        .INPUT_WIDTH(24),
        .OUTPUT_WIDTH(24),
        .COEFF_WIDTH(16),
        .NUM_TAPS(70),
        .DECIMATION(2)
    ) u_fir_lpf (
        .clk(clk),
        .rst_n(reg2_rst_n),
        .data_in(reg2_fir1_data),
        .data_in_valid(reg2_fir1_data_valid),
        .data_out(audio_out),
        .data_out_valid(audio_valid)
    );
    
    // Debug outputs
    assign cic_out = reg2_cic_data;
    assign cic_valid = reg2_cic_data_valid;
    assign fir1_out = reg2_fir1_data;
    assign fir1_valid = reg2_fir1_data_valid;

endmodule