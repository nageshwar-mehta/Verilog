`timescale 1ns / 1ps

module cognitive_radio_top
#(parameter integer WIDTH    = 16,
  parameter integer QF       = 9,
  parameter integer TW_WIDTH = 16
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     in_valid,
    input  wire signed [WIDTH-1:0]  sf_in_re,
    input  wire signed [WIDTH-1:0]  sf_in_im,
    input  wire signed [WIDTH-1:0]  hs1_in_re,
    input  wire signed [WIDTH-1:0]  hs1_in_im,
    input  wire signed [WIDTH-1:0]  w1_in_re,
    input  wire signed [WIDTH-1:0]  w1_in_im,
    output wire signed [WIDTH-1:0]  final_out_re,
    output wire signed [WIDTH-1:0]  final_out_im,
    output wire                     final_out_last,
    output wire                     final_out_valid
);

    // State machine
    reg [3:0] state;
    localparam  S_IDLE       = 4'd0,
                S_FFT        = 4'd1,
                S_DIV        = 4'd2,
                S_ADD        = 4'd3,
                S_IFFT       = 4'd4,
                S_DI         = 4'd5,
                S_MEDIAN     = 4'd6,
                S_SIGMA      = 4'd7,
                S_THRESHOLD  = 4'd8;

    // Storage ROMs
    reg signed [WIDTH-1:0] sf_rom_re [63:0];
    reg signed [WIDTH-1:0] sf_rom_im [63:0];
    reg signed [WIDTH-1:0] hs1_rom_re [63:0];
    reg signed [WIDTH-1:0] hs1_rom_im [63:0];
    reg signed [WIDTH-1:0] w1_rom_re [63:0];
    reg signed [WIDTH-1:0] w1_rom_im [63:0];
    reg signed [WIDTH-1:0] w_by_s_rom_re [63:0];
    reg signed [WIDTH-1:0] w_by_s_rom_im [63:0];
    reg signed [WIDTH-1:0] hs_est_rom_re [63:0];
    reg signed [WIDTH-1:0] hs_est_rom_im [63:0];
    reg signed [WIDTH-1:0] hs_ifft_rom_re [63:0];
    reg signed [WIDTH-1:0] hs_ifft_rom_im [63:0];
    
    // Counters
    reg [5:0] count_fft;
    reg [5:0] count_proc;
    reg [5:0] idx;
    
    // FFT outputs for sf
    wire signed [WIDTH-1:0] sf_out_real, sf_out_imag;
    wire sf_out_valid, sf_out_last;
    
    FFT64pt #(.WIDTH(WIDTH), .QF(QF), .TW_WIDTH(TW_WIDTH)) fft_sf (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid && (state == S_IDLE || state == S_FFT)),
        .in_real(sf_in_re), .in_imag(sf_in_im),
        .out_valid(sf_out_valid), .out_last(sf_out_last),
        .out_real(sf_out_real), .out_imag(sf_out_imag)
    );
    
    // FFT outputs for hs1
    wire signed [WIDTH-1:0] hs1_out_real, hs1_out_imag;
    wire hs1_out_valid, hs1_out_last;
    
    FFT64pt #(.WIDTH(WIDTH), .QF(QF), .TW_WIDTH(TW_WIDTH)) fft_hs1 (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid && (state == S_IDLE || state == S_FFT)),
        .in_real(hs1_in_re), .in_imag(hs1_in_im),
        .out_valid(hs1_out_valid), .out_last(hs1_out_last),
        .out_real(hs1_out_real), .out_imag(hs1_out_imag)
    );
    
    // FFT outputs for w1
    wire signed [WIDTH-1:0] w1_out_real, w1_out_imag;
    wire w1_out_valid, w1_out_last;
    
    FFT64pt #(.WIDTH(WIDTH), .QF(QF), .TW_WIDTH(TW_WIDTH)) fft_w1 (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid && (state == S_IDLE || state == S_FFT)),
        .in_real(w1_in_re), .in_imag(w1_in_im),
        .out_valid(w1_out_valid), .out_last(w1_out_last),
        .out_real(w1_out_real), .out_imag(w1_out_imag)
    );
    
    // Complex division signals (W/S)
    reg signed [2*WIDTH-1:0] div_num_re, div_num_im;
    reg signed [2*WIDTH-1:0] div_denom;
    wire signed [WIDTH-1:0] w_by_s_re, w_by_s_im;
    
    // IFFT module
    reg ifft_in_valid;
    reg signed [WIDTH-1:0] ifft_in_re, ifft_in_im;
    wire signed [WIDTH-1:0] ifft_out_re, ifft_out_im;
    wire ifft_out_valid, ifft_out_last;
    
    IFFT64pt #(.WIDTH(WIDTH), .QF(QF), .TW_WIDTH(TW_WIDTH)) ifft_module (
        .clk(clk), .rstn(rstn),
        .in_valid(ifft_in_valid),
        .in_real(ifft_in_re), .in_imag(ifft_in_im),
        .out_valid(ifft_out_valid), .out_last(ifft_out_last),
        .out_real(ifft_out_re), .out_imag(ifft_out_im)
    );
    
    // Detail coefficient module
    reg di_in_valid;
    reg signed [WIDTH-1:0] di_in_re, di_in_im;
    reg di_in_last;
    wire signed [WIDTH-1:0] di_out_re, di_out_im;
    wire di_out_valid, di_out_last;
    
    detail_coffn #(.WIDTH(WIDTH)) di_module (
        .clk(clk), .rstn(rstn),
        .h_re(di_in_re), .h_im(di_in_im),
        .in_valid(di_in_valid), .in_last(di_in_last),
        .Di_re(di_out_re), .Di_im(di_out_im),
        .out_valid(di_out_valid), .out_last(di_out_last)
    );
    
    // Median module
    reg med_in_valid, med_in_last;
    wire [WIDTH:0] med_out;
    wire med_out_valid, med_busy;
    
    median_Di #(.WIDTH(WIDTH)) median_module (
        .clk(clk), .rstn(rstn),
        .Di_re(di_out_re), .Di_im(di_out_im),
        .in_valid(di_out_valid), .in_last(di_out_last),
        .med_di(med_out),
        .out_valid(med_out_valid), .busy(med_busy)
    );
    
    // Sigma calculation
    reg [WIDTH:0] sigma;
    
    // Thresholding module
    reg thresh_in_valid, thresh_in_last;
    reg signed [WIDTH-1:0] thresh_in_re, thresh_in_im;
    wire signed [WIDTH-1:0] thresh_out_re, thresh_out_im;
    wire thresh_out_valid, thresh_out_last;
    
    thresholding #(.WIDTH(WIDTH)) threshold_module (
        .clk(clk), .rstn(rstn),
        .h_re(thresh_in_re), .h_im(thresh_in_im),
        .in_valid(thresh_in_valid), .in_last(thresh_in_last),
        .sigma(sigma),
        .hs1_re_out(thresh_out_re), .hs1_im_out(thresh_out_im),
        .out_valid(thresh_out_valid), .out_last(thresh_out_last)
    );
    
    integer i;
    
    // Main state machine
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= S_IDLE;
            count_fft <= 0;
            count_proc <= 0;
            idx <= 0;
            ifft_in_valid <= 0;
            di_in_valid <= 0;
            thresh_in_valid <= 0;
            sigma <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (in_valid) begin
                        state <= S_FFT;
                        count_fft <= 0;
                    end
                end
                
                S_FFT: begin
                    // Collect FFT outputs
                    if (sf_out_valid) begin
                        sf_rom_re[count_fft] <= sf_out_real;
                        sf_rom_im[count_fft] <= sf_out_imag;
                    end
                    
                    if (hs1_out_valid) begin
                        hs1_rom_re[count_fft] <= hs1_out_real;
                        hs1_rom_im[count_fft] <= hs1_out_imag;
                    end
                    
                    if (w1_out_valid) begin
                        w1_rom_re[count_fft] <= w1_out_real;
                        w1_rom_im[count_fft] <= w1_out_imag;
                        count_fft <= count_fft + 1;
                    end
                    
                    if (sf_out_last && hs1_out_last && w1_out_last) begin
                        state <= S_DIV;
                        idx <= 0;
                    end
                end
                
                S_DIV: begin
                    if (idx < 64) begin
                        // Complex division: W/S = (w_re*s_re + w_im*s_im + j(w_im*s_re - w_re*s_im)) / (s_re^2 + s_im^2)
                        div_num_re <= (w1_rom_re[idx] * sf_rom_re[idx]) + (w1_rom_im[idx] * sf_rom_im[idx]);
                        div_num_im <= (w1_rom_im[idx] * sf_rom_re[idx]) - (w1_rom_re[idx] * sf_rom_im[idx]);
                        div_denom <= (sf_rom_re[idx] * sf_rom_re[idx]) + (sf_rom_im[idx] * sf_rom_im[idx]);
                        
                        // Store result (simplified - actual division needs proper handling)
                        if (div_denom != 0) begin
                            w_by_s_rom_re[idx] <= div_num_re[2*WIDTH-1:WIDTH] / div_denom[WIDTH-1:0];
                            w_by_s_rom_im[idx] <= div_num_im[2*WIDTH-1:WIDTH] / div_denom[WIDTH-1:0];
                        end
                        
                        idx <= idx + 1;
                    end else begin
                        state <= S_ADD;
                        idx <= 0;
                    end
                end
                
                S_ADD: begin
                    if (idx < 64) begin
                        // ?s = Hs1 + W/S
                        hs_est_rom_re[idx] <= hs1_rom_re[idx] + w_by_s_rom_re[idx];
                        hs_est_rom_im[idx] <= hs1_rom_im[idx] + w_by_s_rom_im[idx];
                        idx <= idx + 1;
                    end else begin
                        state <= S_IFFT;
                        idx <= 0;
                        ifft_in_valid <= 1;
                    end
                end
                
                S_IFFT: begin
                    if (idx < 64) begin
                        ifft_in_re <= hs_est_rom_re[idx];
                        ifft_in_im <= hs_est_rom_im[idx];
                        idx <= idx + 1;
                    end else begin
                        ifft_in_valid <= 0;
                    end
                    
                    if (ifft_out_valid) begin
                        hs_ifft_rom_re[count_proc] <= ifft_out_re;
                        hs_ifft_rom_im[count_proc] <= ifft_out_im;
                        count_proc <= count_proc + 1;
                    end
                    
                    if (ifft_out_last) begin
                        state <= S_DI;
                        idx <= 0;
                        count_proc <= 0;
                        di_in_valid <= 1;
                    end
                end
                
                S_DI: begin
                    if (idx < 64) begin
                        di_in_re <= hs_ifft_rom_re[idx];
                        di_in_im <= hs_ifft_rom_im[idx];
                        di_in_last <= (idx == 63);
                        idx <= idx + 1;
                    end else begin
                        di_in_valid <= 0;
                    end
                    
                    if (di_out_last) begin
                        state <= S_MEDIAN;
                    end
                end
                
                S_MEDIAN: begin
                    // Median module handles Di collection automatically
                    if (med_out_valid) begin
                        state <= S_SIGMA;
                    end
                end
                
                S_SIGMA: begin
                    // sigma = median / 0.6745 ? median * 1.4826
                    // Using approximation: multiply by 3/2 (close to 1.4826)
                    sigma <= (med_out + (med_out >> 1));
                    state <= S_THRESHOLD;
                    idx <= 0;
                    thresh_in_valid <= 1;
                end
                
                S_THRESHOLD: begin
                    if (idx < 64) begin
                        thresh_in_re <= hs_ifft_rom_re[idx];
                        thresh_in_im <= hs_ifft_rom_im[idx];
                        thresh_in_last <= (idx == 63);
                        idx <= idx + 1;
                    end else begin
                        thresh_in_valid <= 0;
                    end
                    
                    if (thresh_out_last) begin
                        state <= S_IDLE;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end
    
    // Output assignments
    assign final_out_re = thresh_out_re;
    assign final_out_im = thresh_out_im;
    assign final_out_valid = thresh_out_valid;
    assign final_out_last = thresh_out_last;

endmodule