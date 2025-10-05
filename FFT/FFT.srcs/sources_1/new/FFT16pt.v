//`timescale 1ns / 1ps
//// 16-point DIT FFT (Verilog)
//// - Uses FFT8pt module (must be defined as you already have)
//// - Natural order input/output


`timescale 1ns / 1ps
module FFT16pt
  #(parameter integer WIDTH    = 16,
    parameter integer QF       = 9,    // fractional bits (Qm.QF)
    parameter integer TW_WIDTH = 16    // twiddle constant width
  )
  (
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     in_valid,
    input  signed [WIDTH-1:0]       in_real,
    input  signed [WIDTH-1:0]       in_imag,
    output reg                      out_valid,
    output reg                      out_last,
    output reg signed [WIDTH-1:0]   out_real,
    output reg signed [WIDTH-1:0]   out_imag
  );

  // ---------------- input buffer ----------------
  reg signed [WIDTH-1:0] x_real [0:15], x_imag [0:15];
  reg [3:0] in_count;

  // ---------------- FSM states ------------------
  reg [5:0] state;
  localparam S_IDLE    = 6'd0,
             S_COLLECT = 6'd1,
             S_FFT_FEED= 6'd2,
             S_COMBINE = 6'd3,
             S_OUT0    = 6'd4,  S_OUT8  = 6'd5,
             S_OUT1    = 6'd6,  S_OUT9  = 6'd7,
             S_OUT2    = 6'd8,  S_OUT10 = 6'd9,
             S_OUT3    = 6'd10, S_OUT11 = 6'd11,
             S_OUT4    = 6'd12, S_OUT12 = 6'd13,
             S_OUT5    = 6'd14, S_OUT13 = 6'd15,
             S_OUT6    = 6'd16, S_OUT14 = 6'd17,
             S_OUT7    = 6'd18, S_OUT15 = 6'd19;

  // ---------------- 8-pt submodules -------------
  wire signed [WIDTH-1:0] even_out_real, even_out_imag;
  wire signed [WIDTH-1:0] odd_out_real,  odd_out_imag;
  wire even_out_valid, odd_out_valid, even_out_last, odd_out_last;

  reg even_in_valid, odd_in_valid;
  reg signed [WIDTH-1:0] even_in_real, even_in_imag;
  reg signed [WIDTH-1:0] odd_in_real,  odd_in_imag;

  FFT8pt #(WIDTH, QF, TW_WIDTH) fft_even (
    .clk(clk), .rstn(rstn),
    .in_valid(even_in_valid),
    .in_real(even_in_real), .in_imag(even_in_imag),
    .out_valid(even_out_valid), .out_last(even_out_last),
    .out_real(even_out_real), .out_imag(even_out_imag)
  );

  FFT8pt #(WIDTH, QF, TW_WIDTH) fft_odd (
    .clk(clk), .rstn(rstn),
    .in_valid(odd_in_valid),
    .in_real(odd_in_real), .in_imag(odd_in_imag),
    .out_valid(odd_out_valid), .out_last(odd_out_last),
    .out_real(odd_out_real), .out_imag(odd_out_imag)
  );

  // --------------- intermediate buffers ----------
  reg signed [WIDTH-1:0] E_real[0:7], E_imag[0:7];
  reg signed [WIDTH-1:0] O_real[0:7], O_imag[0:7];
  reg [2:0] e_count, o_count;

  // ---------------- twiddle ROM ----------------
  function signed [TW_WIDTH-1:0] W16_COS;
    input [2:0] idx;
//    Q2.14 format
    begin
      case (idx)
        3'd0: W16_COS =  16'sd16384;   // cos(0)
        3'd1: W16_COS =  16'sd15137;   // cos(pi/8)
        3'd2: W16_COS =  16'sd11585;   // cos(pi/4)
        3'd3: W16_COS =  16'sd6269;   // cos(3pi/8)
        3'd4: W16_COS =  16'sd0;     // cos(pi/2)
        3'd5: W16_COS = -16'sd6269;   // cos(5pi/8)
        3'd6: W16_COS = -16'sd11585;   // cos(3pi/4)
        3'd7: W16_COS = -16'sd15137;   // cos(7pi/8)
      endcase
    end
  endfunction

  function signed [TW_WIDTH-1:0] W16_SIN;
    input [2:0] idx;
//    Q1.15 format
    begin
      case (idx)
        3'd0: W16_SIN =  16'sd0;     // -sin(0)
        3'd1: W16_SIN = -16'sd6270;   // -sin(pi/8)
        3'd2: W16_SIN = -16'sd11585;   // -sin(pi/4)
        3'd3: W16_SIN = -16'sd15137;   // -sin(3pi/8)
        3'd4: W16_SIN = -16'sd16384;   // -sin(pi/2)
        3'd5: W16_SIN = -16'sd15137;   // -sin(5pi/8)
        3'd6: W16_SIN = -16'sd11585;   // -sin(3pi/4)
        3'd7: W16_SIN = -16'sd6270;   // -sin(7pi/8)
      endcase
    end
  endfunction

  // ---------------- temporaries -----------------
  reg [TW_WIDTH-1:0] W16_SIN_scaled[7:0],W16_COS_scaled[7:0];
  reg signed [WIDTH+TW_WIDTH:0] mult_r, mult_i;
  reg signed [WIDTH+TW_WIDTH-QF:0] scaled_r, scaled_i;

  integer i;

  // ---------------- main FSM ----------------------
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state <= S_IDLE;
      in_count <= 0;
      out_valid <= 0; out_last <= 0;
      even_in_valid <= 0; odd_in_valid <= 0;
      out_real <= 0; out_imag <= 0;
      e_count <= 0; o_count <= 0;
      for (i=0; i<16; i=i+1) begin x_real[i] <= 0; x_imag[i] <= 0; end
      for (i=0; i<8; i=i+1) begin E_real[i] <= 0; E_imag[i] <= 0; O_real[i] <= 0; O_imag[i] <= 0; end
    end else begin
      out_valid <= 0; out_last <= 0;
      even_in_valid <= 0; odd_in_valid <= 0;

      case (state)
        // ---- Stage 1: Collect inputs ----
        S_IDLE: if (in_valid) begin
          x_real[0] <= in_real;
          x_imag[0] <= in_imag;
          in_count <= 4'd1;
          state <= S_COLLECT;
        end

        S_COLLECT: if (in_valid) begin
          x_real[in_count] <= in_real;
          x_imag[in_count] <= in_imag;
          if (in_count == 4'd15) begin
            in_count <= 0; e_count <= 0; o_count <= 0;
            state <= S_FFT_FEED;
          end else in_count <= in_count + 1;
        end

        // ---- Stage 2: feed to FFT8 ----
        S_FFT_FEED: begin
          even_in_real  <= x_real[in_count<<1];
          even_in_imag  <= x_imag[in_count<<1];
          even_in_valid <= 1;
          odd_in_real   <= x_real[(in_count<<1)+1];
          odd_in_imag   <= x_imag[(in_count<<1)+1];
          odd_in_valid  <= 1;
          if (in_count == 4'd7) begin
            in_count <= 0; state <= S_COMBINE;
          end else in_count <= in_count + 1;
        end

        // ---- Stage 3: collect outputs ----
        S_COMBINE: begin
          if (even_out_valid) begin
            E_real[e_count] <= even_out_real;
            E_imag[e_count] <= even_out_imag;
            e_count <= e_count + 1;
          end
          if (odd_out_valid) begin
            O_real[o_count] <= odd_out_real;
            O_imag[o_count] <= odd_out_imag;
            o_count <= o_count + 1;
          end
          if (even_out_last && odd_out_last) begin
            e_count <= 0; o_count <= 0;
            state <= S_OUT0;
          end
        end

        // ---- Stage 4: butterflies ----
        // k=0
//        S_OUT0: begin
//          W16_SIN_scaled[0] = W16_SIN(0)>>>(TW_WIDTH-QF-1);//Q7.9
//          W16_COS_scaled[0] = W16_COS(0)>>>(TW_WIDTH-QF-1);//Q7.9
//          mult_r = O_real[0]*W16_COS_scaled[0] + O_imag[0]*W16_SIN_scaled[0];//Q14.18
//          mult_i = O_imag[0]*W16_COS_scaled[0] - O_real[0]*W16_SIN_scaled[0];//Q14.18
//          scaled_r = mult_r >>> QF; scaled_i = mult_i >>> QF;//.9
//          out_real <= E_real[0] + scaled_r[WIDTH-1:0];
//          out_imag <= E_imag[0] + scaled_i[WIDTH-1:0];
//          out_valid <= 1; state <= S_OUT1;
//        end
// ---- Stage 4: butterflies ----
        S_OUT0: begin
          mult_r = $signed(O_real[0]) * $signed(W16_COS(0))
                 - $signed(O_imag[0]) * $signed(W16_SIN(0));
          mult_i = $signed(O_imag[0]) * $signed(W16_COS(0))
                 + $signed(O_real[0]) * $signed(W16_SIN(0));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[0] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[0] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT1;
        end
         // k=1
        S_OUT1: begin
          mult_r = $signed(O_real[1]) * $signed(W16_COS(1))
                 - $signed(O_imag[1]) * $signed(W16_SIN(1));
          mult_i = $signed(O_imag[1]) * $signed(W16_COS(1))
                 + $signed(O_real[1]) * $signed(W16_SIN(1));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[1] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[1] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT2;
        end
        // k=2
        S_OUT2: begin
          mult_r = $signed(O_real[2]) * $signed(W16_COS(2))
                 - $signed(O_imag[2]) * $signed(W16_SIN(2));
          mult_i = $signed(O_imag[2]) * $signed(W16_COS(2))
                 + $signed(O_real[2]) * $signed(W16_SIN(2));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[2] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[2] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT3;
        end
        // k=3
        S_OUT3: begin
          mult_r = $signed(O_real[3]) * $signed(W16_COS(3))
                 - $signed(O_imag[3]) * $signed(W16_SIN(3));
          mult_i = $signed(O_imag[3]) * $signed(W16_COS(3))
                 + $signed(O_real[3]) * $signed(W16_SIN(3));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[3] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[3] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT4;
        end
        // k=4
        S_OUT4: begin
          mult_r = $signed(O_real[4]) * $signed(W16_COS(4))
                 - $signed(O_imag[4]) * $signed(W16_SIN(4));
          mult_i = $signed(O_imag[4]) * $signed(W16_COS(4))
                 + $signed(O_real[4]) * $signed(W16_SIN(4));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[4] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[4] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT5;
        end
        // k=5
        S_OUT5: begin
          mult_r = $signed(O_real[5]) * $signed(W16_COS(5))
                 - $signed(O_imag[5]) * $signed(W16_SIN(5));
          mult_i = $signed(O_imag[5]) * $signed(W16_COS(5))
                 + $signed(O_real[5]) * $signed(W16_SIN(5));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[5] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[5] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT6;
        end
        // k=6
        S_OUT6: begin
          mult_r = $signed(O_real[6]) * $signed(W16_COS(6))
                 - $signed(O_imag[6]) * $signed(W16_SIN(6));
          mult_i = $signed(O_imag[6]) * $signed(W16_COS(6))
                 + $signed(O_real[6]) * $signed(W16_SIN(6));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[6] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[6] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT7;
        end
        // k=7
        S_OUT7: begin
          mult_r = $signed(O_real[7]) * $signed(W16_COS(7))
                 - $signed(O_imag[7]) * $signed(W16_SIN(7));
          mult_i = $signed(O_imag[7]) * $signed(W16_COS(7))
                 + $signed(O_real[7]) * $signed(W16_SIN(7));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[7] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[7] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT8;
        end        
        S_OUT8: begin
          mult_r = $signed(O_real[0]) * $signed(W16_COS(0))
                 - $signed(O_imag[0]) * $signed(W16_SIN(0));
          mult_i = $signed(O_imag[0]) * $signed(W16_COS(0))
                 + $signed(O_real[0]) * $signed(W16_SIN(0));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[0] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[0] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT9;
        end
        S_OUT9: begin
          mult_r = $signed(O_real[1]) * $signed(W16_COS(1))
                 - $signed(O_imag[1]) * $signed(W16_SIN(1));
          mult_i = $signed(O_imag[1]) * $signed(W16_COS(1))
                 + $signed(O_real[1]) * $signed(W16_SIN(1));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[1] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[1] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT10;
        end
        S_OUT10: begin
          mult_r = $signed(O_real[2]) * $signed(W16_COS(2))
                 - $signed(O_imag[2]) * $signed(W16_SIN(2));
          mult_i = $signed(O_imag[2]) * $signed(W16_COS(2))
                 + $signed(O_real[2]) * $signed(W16_SIN(2));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[2] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[2] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT11;
        end
        S_OUT11: begin
          mult_r = $signed(O_real[3]) * $signed(W16_COS(3))
                 - $signed(O_imag[3]) * $signed(W16_SIN(3));
          mult_i = $signed(O_imag[3]) * $signed(W16_COS(3))
                 + $signed(O_real[3]) * $signed(W16_SIN(3));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[3] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[3] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT12;
        end
        S_OUT12: begin
          mult_r = $signed(O_real[4]) * $signed(W16_COS(4))
                 - $signed(O_imag[4]) * $signed(W16_SIN(4));
          mult_i = $signed(O_imag[4]) * $signed(W16_COS(4))
                 + $signed(O_real[4]) * $signed(W16_SIN(4));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[4] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[4] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT13;
        end
        S_OUT13: begin
          mult_r = $signed(O_real[5]) * $signed(W16_COS(5))
                 - $signed(O_imag[5]) * $signed(W16_SIN(5));
          mult_i = $signed(O_imag[5]) * $signed(W16_COS(5))
                 + $signed(O_real[5]) * $signed(W16_SIN(5));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[5] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[5] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT14;
        end
        S_OUT14: begin
          mult_r = $signed(O_real[6]) * $signed(W16_COS(6))
                 - $signed(O_imag[6]) * $signed(W16_SIN(6));
          mult_i = $signed(O_imag[6]) * $signed(W16_COS(6))
                 + $signed(O_real[6]) * $signed(W16_SIN(6));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[6] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[6] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT15;
        end
        S_OUT15: begin
          mult_r = $signed(O_real[7]) * $signed(W16_COS(7))
                 - $signed(O_imag[7]) * $signed(W16_SIN(7));
          mult_i = $signed(O_imag[7]) * $signed(W16_COS(7))
                 + $signed(O_real[7]) * $signed(W16_SIN(7));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[7] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[7] - scaled_i[WIDTH-1:0];
          out_valid <= 1; out_last <= 1;
          state <= S_IDLE;
        end
//        S_OUT15: begin
//          out_real <= E_real[7] - scaled_r;
//          out_imag <= E_imag[7] - scaled_i;
//          out_valid <= 1; out_last <= 1;
//          state <= S_IDLE;
//        end

        default: state <= S_IDLE;
      endcase
    end
  end
endmodule




//endmodule
