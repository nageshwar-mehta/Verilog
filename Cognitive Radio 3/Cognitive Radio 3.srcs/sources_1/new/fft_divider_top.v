`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  Nageshwar Kumar (edited)
// Date:      27 Oct 2025
// Design:    fft_divider_top (Corrected)
// Description:
//   Integrates FFT-A and FFT-B complex outputs into arrays
//   and drives the existing complex_divider_s sequentially.
//   This version fixes state encoding, counters, handshakes, signedness,
//   instance naming, and small typos/bugs in the original code.
//////////////////////////////////////////////////////////////////////////////////

module fft_divider_top #(
    parameter integer N = 16,
    parameter integer Q = 9
)(
    input  wire                     clk,
    input  wire                     rstn,   // active-low reset

    input  wire signed [N-1:0]      in_a_re_fft,
    input  wire signed [N-1:0]      in_a_im_fft,
    input  wire signed [N-1:0]      in_b_re_fft,
    input  wire signed [N-1:0]      in_b_im_fft,
    input  wire                     in_valid_a,
    input  wire                     in_valid_b,

    output wire signed [N-1:0]      div_out_real,
    output wire signed [N-1:0]      div_out_imag,
    output wire                     div_out_valid,
    output reg                      out_last
);

    // ---------------- internal storage (signed) ----------------
    reg signed [N-1:0] a_re_fft [0:63];
    reg signed [N-1:0] a_im_fft [0:63];
    reg signed [N-1:0] b_re_fft [0:63];
    reg signed [N-1:0] b_im_fft [0:63];

    // ---------------- states and counters ----------------------
    // Use same enum values for both A and B FSMs (simple and explicit)
    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_LOAD  = 2'd1;
    localparam [1:0] S_DONE  = 2'd2;

    reg [1:0] state_a;
    reg [1:0] state_b;

    reg [5:0] counter_a;
    reg [5:0] counter_b;

    // flags to indicate each channel's FIFO/array is fully loaded
    reg fifo_last_a, fifo_last_b;

    // map the incoming FFT valid signals directly (original code had unused wires)
    wire fft_a_out_valid = in_valid_a;
    wire fft_b_out_valid = in_valid_b;

    // ---------------- FSM A: load A samples --------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_a    <= S_IDLE;
            counter_a  <= 6'd0;
            fifo_last_a<= 1'b0;
        end else begin
            case (state_a)
                S_IDLE: begin
                    counter_a   <= 6'd0;
                    fifo_last_a <= 1'b0;
                    state_a     <= S_LOAD;  // immediately start collecting
                end

                S_LOAD: begin
                    if (fft_a_out_valid) begin
                        a_re_fft[counter_a] <= in_a_re_fft;
                        a_im_fft[counter_a] <= in_a_im_fft;
                        if (counter_a == 6'd63) begin
                            fifo_last_a <= 1'b1;
                            counter_a   <= 6'd0;
                            state_a     <= S_DONE;
                        end else begin
                            counter_a <= counter_a + 6'd1;
                        end
                    end
                end

                S_DONE: begin
                    // stay in DONE until external reset or reuse (no-op)
                    state_a <= S_DONE;
                end

                default: state_a <= S_IDLE;
            endcase
        end
    end

    // ---------------- FSM B: load B samples --------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_b    <= S_IDLE;
            counter_b  <= 6'd0;
            fifo_last_b<= 1'b0;
        end else begin
            case (state_b)
                S_IDLE: begin
                    counter_b   <= 6'd0;
                    fifo_last_b <= 1'b0;
                    state_b     <= S_LOAD;
                end

                S_LOAD: begin
                    if (fft_b_out_valid) begin
                        b_re_fft[counter_b] <= in_b_re_fft;
                        b_im_fft[counter_b] <= in_b_im_fft;
                        if (counter_b == 6'd63) begin
                            fifo_last_b <= 1'b1;
                            counter_b   <= 6'd0;
                            state_b     <= S_DONE;
                        end else begin
                            counter_b <= counter_b + 6'd1;
                        end
                    end
                end

                S_DONE: begin
                    // stay in DONE until external reset or reuse (no-op)
                    state_b <= S_DONE;
                end

                default: state_b <= S_IDLE;
            endcase
        end
    end

    // ---------------- Divider interface ------------------------
    // Pulse-based start handshake (drive i_start when we want to kick a division)
    reg div_start_reg;
    wire div_valid_out;
    assign div_out_valid = div_valid_out; // forward divider's output-valid
    wire div_start = div_start_reg;

    // divider inputs (signed)
    reg signed [N-1:0] in_a_re_div, in_a_im_div, in_b_re_div, in_b_im_div;
    
    wire div_busy;

    // Instantiate complex_divider_s (give instance name and correct port mapping)
    complex_divider_s #(.Q(Q), .N(N)) u_complex_div (
        .i_clk(clk),
        .i_rstn(rstn),
        .i_start(div_start),

        .a_re(in_a_re_div),
        .a_im(in_a_im_div),
        .b_re(in_b_re_div),
        .b_im(in_b_im_div),

        .o_re(div_out_real),
        .o_im(div_out_imag),
        .o_valid(div_valid_out),
        .o_busy(div_busy)
    );

    // ---------------- Division controller (sequentially run through 64 samples) ----------
    reg [5:0] counter_div;
    localparam IDLE_div = 1'b0, WAIT_DIV = 1'b1;
    reg state_div;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_div    <= IDLE_div;
            counter_div  <= 6'd0;
            div_start_reg<= 1'b0;
            in_a_re_div  <= {N{1'b0}};
            in_a_im_div  <= {N{1'b0}};
            in_b_re_div  <= {N{1'b0}};
            in_b_im_div  <= {N{1'b0}};
            out_last     <= 1'b0;
        end else begin
            // default: deassert pulse-start unless set
            div_start_reg <= 1'b0;

            case (state_div)
                IDLE_div: begin
                    // start dividing only when both FIFOs/arrays are fully loaded
                    if (fifo_last_a && fifo_last_b) begin
                        // load current indexed sample and pulse start
                        in_a_re_div <= a_re_fft[counter_div];
                        in_a_im_div <= a_im_fft[counter_div];
                        in_b_re_div <= b_re_fft[counter_div];
                        in_b_im_div <= b_im_fft[counter_div];
                        div_start_reg <= 1'b1;   // one-cycle start pulse
                        state_div <= WAIT_DIV;
                    end
                end

                WAIT_DIV: begin
                    // Wait for divider to assert valid for this started operation
                    if (div_valid_out) begin
                        // sample finished - prepare next index
                        if (counter_div == 6'd63) begin
                            out_last    <= 1'b1;
                            counter_div <= 6'd0;
                            state_div   <= IDLE_div; // optionally stop or repeat
                        end else begin
                            counter_div <= counter_div + 6'd1;
                            state_div   <= IDLE_div; // go back to IDLE to start next division
                        end
                    end
                end

                default: state_div <= IDLE_div;
            endcase
        end
    end

endmodule
