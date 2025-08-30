
// ============================================================================
// Module 6: IFFT Scaling Unit (with flattened ports)
// ============================================================================
module ifft_scaler (
    input clk,
    input rst,
    input enable,
    input [1023:0] data_in_real,  // 64 * 16 bits = 1024 bits
    input [1023:0] data_in_imag,  // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_real, // 64 * 16 bits = 1024 bits
    output reg [1023:0] data_out_imag, // 64 * 16 bits = 1024 bits
    output reg done
);
    integer i;
    reg signed [15:0] temp_real, temp_imag;
    
    always @(posedge clk) begin
        if (rst) begin
            done <= 0;
            data_out_real <= 0;
            data_out_imag <= 0;
        end else if (enable) begin
            for (i = 0; i < 64; i = i + 1) begin
                // Extract, scale by 1/64 (shift right by 6), and store
                temp_real = data_in_real[i*16 +: 16];
                temp_imag = data_in_imag[i*16 +: 16];
                data_out_real[i*16 +: 16] <= temp_real >>> 6;
                data_out_imag[i*16 +: 16] <= temp_imag >>> 6;
            end
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
