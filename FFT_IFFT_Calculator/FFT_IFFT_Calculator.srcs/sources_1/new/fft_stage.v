
// ============================================================================
// Module 4: Single FFT Stage (with flattened ports)
// ============================================================================
module fft_stage #(
    parameter STAGE_NUM = 0  // Stage number (0 to 5)
) (
    input clk,
    input rst,
    input enable,
    input ifft_mode,
    input [1023:0] data_in_real,  // 64 * 16 bits = 1024 bits
    input [1023:0] data_in_imag,  // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_real, // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_imag, // 64 * 16 bits = 1024 bits
    output reg done
);
    integer i, j, k;
    reg [5:0] butterfly_count;
    reg processing;
    
    // Internal arrays for processing
    reg signed [15:0] data_real [0:63];
    reg signed [15:0] data_imag [0:63];
    
    wire signed [15:0] tw_real, tw_imag;
    reg [5:0] tw_addr;
    
    wire signed [15:0] butterfly_out_cr, butterfly_out_ci;
    wire signed [15:0] butterfly_out_dr, butterfly_out_di;
    
    reg signed [15:0] butterfly_in_ar, butterfly_in_ai;
    reg signed [15:0] butterfly_in_br, butterfly_in_bi;
    
    // Instantiate twiddle ROM
    twiddle_rom tw_rom (
        .addr(tw_addr),
        .ifft_mode(ifft_mode),
        .tw_real(tw_real),
        .tw_imag(tw_imag)
    );
    
    // Instantiate butterfly unit
    butterfly_unit butterfly (
        .ar(butterfly_in_ar), .ai(butterfly_in_ai),
        .br(butterfly_in_br), .bi(butterfly_in_bi),
        .wr(tw_real), .wi(tw_imag),
        .cr(butterfly_out_cr), .ci(butterfly_out_ci),
        .dr(butterfly_out_dr), .di(butterfly_out_di)
    );
    
    // Stage parameters
    localparam BUTTERFLIES_PER_GROUP = 1 << STAGE_NUM;
    localparam NUM_GROUPS = 64 >> (STAGE_NUM + 1);
    
    // Unpack input data
    always @(*) begin
        for (i = 0; i < 64; i = i + 1) begin
            data_real[i] = data_in_real[i*16 +: 16];
            data_imag[i] = data_in_imag[i*16 +: 16];
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            done <= 0;
            processing <= 0;
            butterfly_count <= 0;
            data_out_real <= 0;
            data_out_imag <= 0;
        end else if (enable && !processing) begin
            processing <= 1;
            done <= 0;
            butterfly_count <= 0;
        end else if (processing) begin
            if (butterfly_count < 32) begin
                // Calculate indices for current butterfly
                k = butterfly_count / BUTTERFLIES_PER_GROUP;
                j = butterfly_count % BUTTERFLIES_PER_GROUP;
                
                // Calculate actual array indices
                i = k * (2 * BUTTERFLIES_PER_GROUP) + j;
                
                // Set butterfly inputs
                butterfly_in_ar <= data_real[i];
                butterfly_in_ai <= data_imag[i];
                butterfly_in_br <= data_real[i + BUTTERFLIES_PER_GROUP];
                butterfly_in_bi <= data_imag[i + BUTTERFLIES_PER_GROUP];
                
                // Set twiddle factor address
                tw_addr <= (j * (32 >> STAGE_NUM)) & 6'b011111;
                
                // Store butterfly outputs (1 cycle delay for computation)
                if (butterfly_count > 0) begin
                    k = (butterfly_count - 1) / BUTTERFLIES_PER_GROUP;
                    j = (butterfly_count - 1) % BUTTERFLIES_PER_GROUP;
                    i = k * (2 * BUTTERFLIES_PER_GROUP) + j;
                    
                    data_real[i] <= butterfly_out_cr;
                    data_imag[i] <= butterfly_out_ci;
                    data_real[i + BUTTERFLIES_PER_GROUP] <= butterfly_out_dr;
                    data_imag[i + BUTTERFLIES_PER_GROUP] <= butterfly_out_di;
                end
                
                butterfly_count <= butterfly_count + 1;
            end else if (butterfly_count == 32) begin
                // Store last butterfly output
                k = 31 / BUTTERFLIES_PER_GROUP;
                j = 31 % BUTTERFLIES_PER_GROUP;
                i = k * (2 * BUTTERFLIES_PER_GROUP) + j;
                
                data_real[i] <= butterfly_out_cr;
                data_imag[i] <= butterfly_out_ci;
                data_real[i + BUTTERFLIES_PER_GROUP] <= butterfly_out_dr;
                data_imag[i + BUTTERFLIES_PER_GROUP] <= butterfly_out_di;
                
                // Pack output data
                for (i = 0; i < 64; i = i + 1) begin
                    data_out_real[i*16 +: 16] <= data_real[i];
                    data_out_imag[i*16 +: 16] <= data_imag[i];
                end
                
                done <= 1;
                processing <= 0;
            end
        end
    end
endmodule