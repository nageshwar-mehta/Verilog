//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.08.2025 15:36:31
// Design Name: 
// Module Name: twiddle_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ============================================================================
// Module 3: Twiddle Factor ROM
// ============================================================================
module twiddle_rom (
    input [5:0] addr,           // Address for 64 twiddle factors
    input ifft_mode,            // 0: FFT, 1: IFFT
    output reg signed [15:0] tw_real,
    output reg signed [15:0] tw_imag
);
    // Pre-computed twiddle factors for 64-point FFT (scaled to 16-bit)
    // W_N^k = exp(-j*2*pi*k/N) for FFT
    // W_N^k = exp(+j*2*pi*k/N) for IFFT
    
    always @(*) begin
        case(addr)
            6'd0:  begin tw_real = 16'd32767;  tw_imag = ifft_mode ? 16'd0     : 16'd0;     end
            6'd1:  begin tw_real = 16'd32729;  tw_imag = ifft_mode ? 16'd3212  : -16'd3212; end
            6'd2:  begin tw_real = 16'd32610;  tw_imag = ifft_mode ? 16'd6393  : -16'd6393; end
            6'd3:  begin tw_real = 16'd32413;  tw_imag = ifft_mode ? 16'd9512  : -16'd9512; end
            6'd4:  begin tw_real = 16'd32138;  tw_imag = ifft_mode ? 16'd12540 : -16'd12540; end
            6'd5:  begin tw_real = 16'd31786;  tw_imag = ifft_mode ? 16'd15447 : -16'd15447; end
            6'd6:  begin tw_real = 16'd31357;  tw_imag = ifft_mode ? 16'd18205 : -16'd18205; end
            6'd7:  begin tw_real = 16'd30853;  tw_imag = ifft_mode ? 16'd20788 : -16'd20788; end
            6'd8:  begin tw_real = 16'd30274;  tw_imag = ifft_mode ? 16'd23170 : -16'd23170; end
            6'd9:  begin tw_real = 16'd29622;  tw_imag = ifft_mode ? 16'd25330 : -16'd25330; end
            6'd10: begin tw_real = 16'd28899;  tw_imag = ifft_mode ? 16'd27246 : -16'd27246; end
            6'd11: begin tw_real = 16'd28106;  tw_imag = ifft_mode ? 16'd28899 : -16'd28899; end
            6'd12: begin tw_real = 16'd27246;  tw_imag = ifft_mode ? 16'd30274 : -16'd30274; end
            6'd13: begin tw_real = 16'd26320;  tw_imag = ifft_mode ? 16'd31357 : -16'd31357; end
            6'd14: begin tw_real = 16'd25330;  tw_imag = ifft_mode ? 16'd32138 : -16'd32138; end
            6'd15: begin tw_real = 16'd24279;  tw_imag = ifft_mode ? 16'd32610 : -16'd32610; end
            6'd16: begin tw_real = 16'd23170;  tw_imag = ifft_mode ? 16'd32767 : -16'd32767; end
            6'd17: begin tw_real = 16'd22006;  tw_imag = ifft_mode ? 16'd32610 : -16'd32610; end
            6'd18: begin tw_real = 16'd20788;  tw_imag = ifft_mode ? 16'd32138 : -16'd32138; end
            6'd19: begin tw_real = 16'd19520;  tw_imag = ifft_mode ? 16'd31357 : -16'd31357; end
            6'd20: begin tw_real = 16'd18205;  tw_imag = ifft_mode ? 16'd30274 : -16'd30274; end
            6'd21: begin tw_real = 16'd16846;  tw_imag = ifft_mode ? 16'd28899 : -16'd28899; end
            6'd22: begin tw_real = 16'd15447;  tw_imag = ifft_mode ? 16'd27246 : -16'd27246; end
            6'd23: begin tw_real = 16'd14010;  tw_imag = ifft_mode ? 16'd25330 : -16'd25330; end
            6'd24: begin tw_real = 16'd12540;  tw_imag = ifft_mode ? 16'd23170 : -16'd23170; end
            6'd25: begin tw_real = 16'd11039;  tw_imag = ifft_mode ? 16'd20788 : -16'd20788; end
            6'd26: begin tw_real = 16'd9512;   tw_imag = ifft_mode ? 16'd18205 : -16'd18205; end
            6'd27: begin tw_real = 16'd7962;   tw_imag = ifft_mode ? 16'd15447 : -16'd15447; end
            6'd28: begin tw_real = 16'd6393;   tw_imag = ifft_mode ? 16'd12540 : -16'd12540; end
            6'd29: begin tw_real = 16'd4808;   tw_imag = ifft_mode ? 16'd9512  : -16'd9512;  end
            6'd30: begin tw_real = 16'd3212;   tw_imag = ifft_mode ? 16'd6393  : -16'd6393;  end
            6'd31: begin tw_real = 16'd1608;   tw_imag = ifft_mode ? 16'd3212  : -16'd3212;  end
            6'd32: begin tw_real = 16'd0;      tw_imag = ifft_mode ? 16'd32767 : -16'd32767; end
            default: begin tw_real = 16'd32767; tw_imag = 16'd0; end
        endcase
    end
endmodule

