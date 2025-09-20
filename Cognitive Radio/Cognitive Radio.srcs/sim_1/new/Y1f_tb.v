`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Y1f_recieved_signal_fft
//////////////////////////////////////////////////////////////////////////////////

module Y1f_tb;

    reg aclk;
    reg aresetn;

    // DUT inputs
    reg signed [15:0] s_re, s_im;
    reg signed [15:0] h_re, h_im;
    reg signed [15:0] w_re, w_im;
    reg        in_valid, in_last;
    wire       in_ready;

    // DUT outputs
    wire signed [15:0] Y_re, Y_im;
    wire        Y_valid, Y_last;
    
    // config ports 
    reg  [7:0] config_data;
    reg        config_valid;
    wire       config_ready;

    // Memories to load input data
    reg [15:0] s_real_mem [0:63];
    reg [15:0] s_imag_mem [0:63];
    reg [15:0] h_real_mem [0:63];
    reg [15:0] h_imag_mem [0:63];
    reg [15:0] w_real_mem [0:63];
    reg [15:0] w_imag_mem [0:63];

    integer i;
    integer f_re, f_im;

    // Instantiate DUT
    Y1f_recieved_signal_fft dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_re(s_re), .s_im(s_im),
        .h_re(h_re), .h_im(h_im),
        .w_re(w_re), .w_im(w_im),
        .in_valid(in_valid), .in_last(in_last),
        .in_ready(in_ready),
        .Y_re(Y_re), .Y_im(Y_im),
        .Y_valid(Y_valid), .Y_last(Y_last),
        .config_data(config_data),
        .config_valid(config_valid),
        .config_ready(config_ready)
    );

    // Clock generation: 100 MHz
    initial aclk = 0;
    always #5 aclk = ~aclk;

    // Reset sequence
    initial begin
        aresetn = 0;
        in_valid = 0;
        in_last  = 0;
        s_re = 0; s_im = 0;
        h_re = 0; h_im = 0;
        w_re = 0; w_im = 0;
        config_data  = 0;
        config_valid = 0;
        #50;
        aresetn = 1;
    end

    // Configure FFT cores
    initial begin
        wait(aresetn == 1);
        @(posedge aclk);
        config_data  = 8'd1;    // FFT mode
        config_valid = 1'b1;
        wait(config_ready == 1'b1);
        @(posedge aclk);
        config_valid = 1'b0;
    end

    // Load input data from files
    initial begin
        $readmemb("s_real.txt", s_real_mem);
        $readmemb("s_imag.txt", s_imag_mem);
        $readmemb("h_real.txt", h_real_mem);
        $readmemb("h_imag.txt", h_imag_mem);
        $readmemb("w_real.txt", w_real_mem);
        $readmemb("w_imag.txt", w_imag_mem);
    end

    // Drive inputs respecting in_ready
    initial begin
        wait(aresetn == 1);
        wait(config_ready == 1);
        #20;
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge aclk);
            if (in_ready) begin
                in_valid <= 1;
                in_last  <= (i == 63);
                s_re <= s_real_mem[i];
                s_im <= s_imag_mem[i];
                h_re <= h_real_mem[i];
                h_im <= h_imag_mem[i];
                w_re <= w_real_mem[i];
                w_im <= w_imag_mem[i];
            end else begin
                in_valid <= 0; // stall if not ready
                in_last  <= 0;
            end
        end
        @(posedge aclk);
        in_valid <= 0;
        in_last  <= 0;
    end

    // Open output files
    initial begin
        f_re = $fopen("Y1f_real.txt", "w");
        f_im = $fopen("Y1f_imag.txt", "w");
    end

    // Capture outputs
    always @(posedge aclk) begin
        if (Y_valid) begin
            $fwrite(f_re, "%016b\n", Y_re);
            $fwrite(f_im, "%016b\n", Y_im);
        end
        if (Y_valid && Y_last) begin
            $fclose(f_re);
            $fclose(f_im);
            $stop;
        end
    end

endmodule
