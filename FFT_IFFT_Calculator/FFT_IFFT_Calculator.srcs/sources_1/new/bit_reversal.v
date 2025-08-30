
// ============================================================================
// Module 5: Bit Reversal Unit (with flattened ports)
// ============================================================================
module bit_reversal (
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
    reg [5:0] reversed_idx;
    reg signed [15:0] temp_real, temp_imag;
    
    // Function to reverse 6 bits
    function [5:0] reverse_bits;
        input [5:0] in;
        begin
            reverse_bits = {in[0], in[1], in[2], in[3], in[4], in[5]};
        end
    endfunction
    
    always @(posedge clk) begin
        if (rst) begin
            done <= 0;
            data_out_real <= 0;
            data_out_imag <= 0;
        end else if (enable) begin
            for (i = 0; i < 64; i = i + 1) begin
                reversed_idx = reverse_bits(i[5:0]);
                // Extract from input
                temp_real = data_in_real[i*16 +: 16];
                temp_imag = data_in_imag[i*16 +: 16];
                // Place in bit-reversed position
                data_out_real[reversed_idx*16 +: 16] <= temp_real;
                data_out_imag[reversed_idx*16 +: 16] <= temp_imag;
            end
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule