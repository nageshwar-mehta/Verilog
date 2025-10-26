`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  (provided)
// Date:      26 Oct 2025
// Module:    fft_divider_top
// Purpose:   Integrate two FFT64pt outputs through FIFOs into a complex divider.
//            Uses a 2-cycle handshake (issue FIFO read, then start divider next cycle)
//            to avoid read/data race. Produces div_out_valid for each division and
//            out_last pulse when 64 divisions completed.
//////////////////////////////////////////////////////////////////////////////////

module fft_divider_top #(
    parameter integer N = 16, // width of complex samples
    parameter integer Q = 9   // fractional bits (Q format)
)(
    input  wire                     clk,
    input  wire                     rstn,        // active-low reset
//    input  wire                     start,       // optional top-level start of 64-burst
    // FFT A inputs (streaming into FFT blocks elsewhere)
    input  wire signed [N-1:0]      in_a_re_fft,
    input  wire signed [N-1:0]      in_a_im_fft,
    // FFT B inputs
    input  wire signed [N-1:0]      in_b_re_fft,
    input  wire signed [N-1:0]      in_b_im_fft,
    input  wire                     in_valid_a,    // connect to out_valid of ffts
    input  wire                     in_valid_b,
    // Divider outputs
    output wire signed [N-1:0]      div_out_real,
    output wire signed [N-1:0]      div_out_imag,
    output wire                     div_out_valid,
    output reg                     out_last
);

    // ------------------------------------------------------------------
    // Instantiate two FFT64pt modules (A and B)
    // (Assumes FFT64pt module uses ports: clk, rstn, in_valid, in_real, in_imag,
    //  out_valid, out_last, out_real, out_imag)
    // ------------------------------------------------------------------
//    wire fft_a_valid, fft_b_valid;
//    wire out_last_a, out_last_b;
//    wire signed [N-1:0] fft_a_re, fft_a_im;
//    wire signed [N-1:0] fft_b_re, fft_b_im;

//    FFT64pt fft_A (
//        .clk(clk),
//        .rstn(rstn),
//        .in_valid(in_valid),
//        .in_real(in_a_real),
//        .in_imag(in_a_imag),
//        .out_valid(fft_a_valid),
//        .out_last(out_last_a),
//        .out_real(fft_a_re),
//        .out_imag(fft_a_im)
//    );

//    FFT64pt fft_B (
//        .clk(clk),
//        .rstn(rstn),
//        .in_valid(in_valid),
//        .in_real(in_b_real),
//        .in_imag(in_b_imag),
//        .out_valid(fft_b_valid),
//        .out_last(out_last_b),
//        .out_real(fft_b_re),
//        .out_imag(fft_b_im)
//    );

    // ------------------------------------------------------------------
    // FIFOs for buffering outputs of FFT A and FFT B
    // Using your synchronous FIFO (same clock domain). Four FIFOs:
    //   fifo_a_re, fifo_a_im, fifo_b_re, fifo_b_im
    // FIFO interface expected:
    // (clk, data_in, w_in, r_in, rst, data_out, fifo_empty, fifo_full)
    // ------------------------------------------------------------------
    wire signed [N-1:0] a_re_out, a_im_out, b_re_out, b_im_out;
    wire fifo_a_re_empty,  fifo_a_re_full;
    wire fifo_a_im_empty,  fifo_a_im_full;
    wire fifo_b_re_empty,  fifo_b_re_full;
    wire fifo_b_im_empty,  fifo_b_im_full;
    reg r_en;         // read enable into all 4 FIFOs (single-cycle)

    // FIFO depth 64 to buffer full FFT burst
    Synchronous_FIFO #(.width(N), .depth(64)) fifo_a_re (
        .clk(clk),
        .data_in(in_a_re_fft),
        .w_in(in_valid_a),
        .r_in(r_en),        // r_en is the single read enable (shared for re+im)
        .rst(rstn),
        .data_out(a_re_out),
        .fifo_empty(fifo_a_re_empty),
        .fifo_full(fifo_a_re_full)
    );

    Synchronous_FIFO #(.width(N), .depth(64)) fifo_a_im (
        .clk(clk),
        .data_in(in_a_im_fft),
        .w_in(in_valid_a),
        .r_in(r_en),
        .rst(rstn),
        .data_out(a_im_out),
        .fifo_empty(fifo_a_im_empty),
        .fifo_full(fifo_a_im_full)
    );

    Synchronous_FIFO #(.width(N), .depth(64)) fifo_b_re (
        .clk(clk),
        .data_in(in_b_re_fft),
        .w_in(in_valid_b),
        .r_in(r_en),
        .rst(rstn),
        .data_out(b_re_out),
        .fifo_empty(fifo_b_re_empty),
        .fifo_full(fifo_b_re_full)
    );

    Synchronous_FIFO #(.width(N), .depth(64)) fifo_b_im (
        .clk(clk),
        .data_in(in_b_im_fft),
        .w_in(in_valid_b),
        .r_in(r_en),
        .rst(rstn),
        .data_out(b_im_out),
        .fifo_empty(fifo_b_im_empty),
        .fifo_full(fifo_b_im_full)
    );

    // ------------------------------------------------------------------
    // Complex divider (parallel version): consumes one complex pair per start
    // (Assumes complex_divider_s ports: i_clk,i_rstn,i_start,a_re,a_im,b_re,b_im,o_re,o_im,o_valid,o_busy)
    // ------------------------------------------------------------------
    wire busy, valid;
    reg start_div; // asserted one cycle to start divider for current inputs

    complex_divider_s #(.Q(Q), .N(N)) u_divider (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_start(start_div),
        .a_re(a_re_out),
        .a_im(a_im_out),
        .b_re(b_re_out),
        .b_im(b_im_out),
        .o_re(div_out_real),
        .o_im(div_out_imag),
        .o_valid(valid),
        .o_busy(busy)
    );

    assign div_out_valid = valid;

    // ------------------------------------------------------------------
    // Control FSM:
    //  IDLE    -> ISSUE_RD  (assert r_en to read FIFO outputs)
    //  ISSUE_RD-> START_DIV (next cycle assert start_div; FIFO outputs stable)
    //  START_DIV-> wait for valid from divider -> back to IDLE
    // ------------------------------------------------------------------
    
    reg [1:0] state;
    localparam IDLE     = 2'd0;
    localparam ISSUE_RD = 2'd1;
    localparam STARTDIV = 2'd2;
    
    reg [6:0]counter;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            r_en <= 1'b0;
            start_div <= 1'b0;
        end else begin
            // default deassert signals
            r_en <= 1'b0;
            start_div <= 1'b0;

            case (state)
                IDLE: begin
                    // Request a read only when all four FIFOs have data and divider not busy
                    // (Checking empties ensures valid pairs are available)
                    if (!fifo_a_re_empty && !fifo_a_im_empty &&
                        !fifo_b_re_empty && !fifo_b_im_empty && !busy) begin
                        r_en <= 1'b1;               // issue FIFO read (data_out will be updated at posedge)
                        state <= ISSUE_RD;
                    end
                end

                ISSUE_RD: begin
                    // Now FIFO data_out signals are stable for this cycle - start divider
                    // by asserting start_div for one cycle.
                    start_div <= 1'b1;
                    r_en <=1'b0;
                    state <= STARTDIV;
                end

                STARTDIV: begin
                    // Wait for divider to assert valid for this sample
                    if (valid) begin
                        state <= IDLE;
                        counter <= counter + 1;
                        if(counter == 64) begin
                            out_last <=1;
                            counter<=0;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Division counter & out_last generator
    // - Clears on external 'start' signal or reset.
    // - Increments on each divider 'valid' and pulses out_last when we reach 64.
    // ------------------------------------------------------------------
//    reg [6:0] div_count; // counts 0..63
//    reg out_last_r;

//    always @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            div_count <= 7'd0;
//            out_last_r <= 1'b0;
//        end else begin
//            out_last_r <= 1'b0; // default no pulse
//            if (start) begin
//                // external start of new 64-burst: reset counter
//                div_count <= 7'd0;
//            end else if (valid) begin
//                if (div_count == 7'd63) begin
//                    div_count <= 7'd0;
//                    out_last_r <= 1'b1;
//                end else begin
//                    div_count <= div_count + 1;
//                end
//            end
//        end
//    end

//    assign out_last = out_last_r;

endmodule
