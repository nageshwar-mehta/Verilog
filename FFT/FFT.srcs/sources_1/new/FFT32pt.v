//`timescale 1ns / 1ps
//// 32-point DIT FFT (Verilog)
//// - Uses FFT16pt module (must be defined as you already have)
//// - Natural order input/output


`timescale 1ns / 1ps
module FFT32pt
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
  reg signed [WIDTH-1:0] x_real [0:31], x_imag [0:31];
  reg [4:0] in_count;

  // ---------------- FSM states ------------------
  reg [6:0] state;
  localparam S_IDLE    = 7'd0,
             S_COLLECT = 7'd1,
             S_FFT_FEED= 7'd2,
             S_COMBINE = 7'd3,
             S_OUT0    = 7'd4,  S_OUT16  = 7'd5,
             S_OUT1    = 7'd6,  S_OUT17  = 7'd7,
             S_OUT2    = 7'd8,  S_OUT18 = 7'd9,
             S_OUT3    = 7'd10, S_OUT19 = 7'd11,
             S_OUT4    = 7'd12, S_OUT20 = 7'd13,
             S_OUT5    = 7'd14, S_OUT21 = 7'd15,
             S_OUT6    = 7'd16, S_OUT22 = 7'd17,
             S_OUT7    = 7'd18, S_OUT23 = 7'd19,
             S_OUT8    = 7'd20,  S_OUT24 = 7'd21,
             S_OUT9    = 7'd22,  S_OUT25 = 7'd23,
             S_OUT10    = 7'd24,  S_OUT26 = 7'd25,
             S_OUT11    = 7'd26, S_OUT27 = 7'd27,
             S_OUT12    = 7'd28, S_OUT28 = 7'd29,
             S_OUT13    = 7'd30, S_OUT29 = 7'd31,
             S_OUT14    = 7'd32, S_OUT30 = 7'd33,
             S_OUT15    = 7'd34, S_OUT31 = 7'd35;

  // ---------------- 8-pt submodules -------------
  wire signed [WIDTH-1:0] even_out_real, even_out_imag;
  wire signed [WIDTH-1:0] odd_out_real,  odd_out_imag;
  wire even_out_valid, odd_out_valid, even_out_last, odd_out_last;

  reg even_in_valid, odd_in_valid;
  reg signed [WIDTH-1:0] even_in_real, even_in_imag;
  reg signed [WIDTH-1:0] odd_in_real,  odd_in_imag;

  FFT16pt #(WIDTH, QF, TW_WIDTH) fft_even (
    .clk(clk), .rstn(rstn),
    .in_valid(even_in_valid),
    .in_real(even_in_real), .in_imag(even_in_imag),
    .out_valid(even_out_valid), .out_last(even_out_last),
    .out_real(even_out_real), .out_imag(even_out_imag)
  );

  FFT16pt #(WIDTH, QF, TW_WIDTH) fft_odd (
    .clk(clk), .rstn(rstn),
    .in_valid(odd_in_valid),
    .in_real(odd_in_real), .in_imag(odd_in_imag),
    .out_valid(odd_out_valid), .out_last(odd_out_last),
    .out_real(odd_out_real), .out_imag(odd_out_imag)
  );

  // --------------- intermediate buffers ----------
  reg signed [WIDTH-1:0] E_real[0:15], E_imag[0:15];
  reg signed [WIDTH-1:0] O_real[0:15], O_imag[0:15];
  reg [3:0] e_count, o_count;

   // ---------------- twiddle ROMs (Q2.14 format) ----------------
function signed [TW_WIDTH-1:0] W32_COS;
  input [3:0] idx;
  begin
    case (idx)
      4'd0:  W32_COS =  16'sd16384;   // cos(0)
      4'd1:  W32_COS =  16'sd16069;   // cos(pi/16)
      4'd2:  W32_COS =  16'sd15137;   // cos(2pi/16)
      4'd3:  W32_COS =  16'sd13623;   // cos(3pi/16)
      4'd4:  W32_COS =  16'sd11585;   // cos(4pi/16)
      4'd5:  W32_COS =  16'sd9102;    // cos(5pi/16)
      4'd6:  W32_COS =  16'sd6270;    // cos(6pi/16)
      4'd7:  W32_COS =  16'sd3196;    // cos(7pi/16)
      4'd8:  W32_COS =  16'sd0;       // cos(pi/2)
      4'd9:  W32_COS = -16'sd3196;    // cos(9pi/16)
      4'd10: W32_COS = -16'sd6270;    // cos(10pi/16)
      4'd11: W32_COS = -16'sd9102;    // cos(11pi/16)
      4'd12: W32_COS = -16'sd11585;   // cos(12pi/16)
      4'd13: W32_COS = -16'sd13623;   // cos(13pi/16)
      4'd14: W32_COS = -16'sd15137;   // cos(14pi/16)
      4'd15: W32_COS = -16'sd16069;   // cos(15pi/16)
    endcase
  end
endfunction

function signed [TW_WIDTH-1:0] W32_SIN;
  input [3:0] idx;
  begin
    case (idx)
      4'd0:  W32_SIN =   16'sd0;       // sin(0)
      4'd1:  W32_SIN =  -16'sd3196;    // -sin(pi/16)
      4'd2:  W32_SIN =  -16'sd6270;    // -sin(2pi/16)
      4'd3:  W32_SIN =  -16'sd9102;    // -sin(3pi/16)
      4'd4:  W32_SIN =  -16'sd11585;   // -sin(4pi/16)
      4'd5:  W32_SIN =  -16'sd13623;   // -sin(5pi/16)
      4'd6:  W32_SIN =  -16'sd15137;   // -sin(6pi/16)
      4'd7:  W32_SIN =  -16'sd16069;   // -sin(7pi/16)
      4'd8:  W32_SIN =  -16'sd16384;   // -sin(pi/2)
      4'd9:  W32_SIN =  -16'sd16069;   // -sin(9pi/16)
      4'd10: W32_SIN =  -16'sd15137;   // -sin(10pi/16)
      4'd11: W32_SIN =  -16'sd13623;   // -sin(11pi/16)
      4'd12: W32_SIN =  -16'sd11585;   // -sin(12pi/16)
      4'd13: W32_SIN =  -16'sd9102;    // -sin(13pi/16)
      4'd14: W32_SIN =  -16'sd6270;    // -sin(14pi/16)
      4'd15: W32_SIN =  -16'sd3196;    // -sin(15pi/16)
    endcase
  end
endfunction


  // ---------------- temporaries -----------------
  reg [TW_WIDTH-1:0] W16_SIN_scaled[15:0],W16_COS_scaled[15:0];
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
      for (i=0; i<32; i=i+1) begin x_real[i] <= 0; x_imag[i] <= 0; end
      for (i=0; i<16; i=i+1) begin E_real[i] <= 0; E_imag[i] <= 0; O_real[i] <= 0; O_imag[i] <= 0; end
    end else begin
      out_valid <= 0; out_last <= 0;
      even_in_valid <= 0; odd_in_valid <= 0;

      case (state)
        // ---- Stage 1: Collect inputs ----
        S_IDLE: if (in_valid) begin
          x_real[0] <= in_real;
          x_imag[0] <= in_imag;
          in_count <= 5'd1;
          state <= S_COLLECT;
        end

        S_COLLECT: if (in_valid) begin
          x_real[in_count] <= in_real;
          x_imag[in_count] <= in_imag;
          if (in_count == 5'd31) begin
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
          if (in_count == 5'd15) begin
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

        // ---- Stage 8: butterflies ----
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
          mult_r = $signed(O_real[0]) * $signed(W32_COS(0))
                 - $signed(O_imag[0]) * $signed(W32_SIN(0));
          mult_i = $signed(O_imag[0]) * $signed(W32_COS(0))
                 + $signed(O_real[0]) * $signed(W32_SIN(0));
                 
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
          mult_r = $signed(O_real[1]) * $signed(W32_COS(1))
                 - $signed(O_imag[1]) * $signed(W32_SIN(1));
          mult_i = $signed(O_imag[1]) * $signed(W32_COS(1))
                 + $signed(O_real[1]) * $signed(W32_SIN(1));
                 
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
          mult_r = $signed(O_real[2]) * $signed(W32_COS(2))
                 - $signed(O_imag[2]) * $signed(W32_SIN(2));
          mult_i = $signed(O_imag[2]) * $signed(W32_COS(2))
                 + $signed(O_real[2]) * $signed(W32_SIN(2));
                 
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
          mult_r = $signed(O_real[3]) * $signed(W32_COS(3))
                 - $signed(O_imag[3]) * $signed(W32_SIN(3));
          mult_i = $signed(O_imag[3]) * $signed(W32_COS(3))
                 + $signed(O_real[3]) * $signed(W32_SIN(3));
                 
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
          mult_r = $signed(O_real[4]) * $signed(W32_COS(4))
                 - $signed(O_imag[4]) * $signed(W32_SIN(4));
          mult_i = $signed(O_imag[4]) * $signed(W32_COS(4))
                 + $signed(O_real[4]) * $signed(W32_SIN(4));
                 
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
          mult_r = $signed(O_real[5]) * $signed(W32_COS(5))
                 - $signed(O_imag[5]) * $signed(W32_SIN(5));
          mult_i = $signed(O_imag[5]) * $signed(W32_COS(5))
                 + $signed(O_real[5]) * $signed(W32_SIN(5));
                 
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
          mult_r = $signed(O_real[6]) * $signed(W32_COS(6))
                 - $signed(O_imag[6]) * $signed(W32_SIN(6));
          mult_i = $signed(O_imag[6]) * $signed(W32_COS(6))
                 + $signed(O_real[6]) * $signed(W32_SIN(6));
                 
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
          mult_r = $signed(O_real[7]) * $signed(W32_COS(7))
                 - $signed(O_imag[7]) * $signed(W32_SIN(7));
          mult_i = $signed(O_imag[7]) * $signed(W32_COS(7))
                 + $signed(O_real[7]) * $signed(W32_SIN(7));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[7] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[7] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT8;
        end  
        S_OUT8: begin
          mult_r = $signed(O_real[8]) * $signed(W32_COS(8))
                 - $signed(O_imag[8]) * $signed(W32_SIN(8));
          mult_i = $signed(O_imag[8]) * $signed(W32_COS(8))
                 + $signed(O_real[8]) * $signed(W32_SIN(8));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[8] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[8] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT9;
        end
         // k=9
        S_OUT9: begin
          mult_r = $signed(O_real[9]) * $signed(W32_COS(9))
                 - $signed(O_imag[9]) * $signed(W32_SIN(9));
          mult_i = $signed(O_imag[9]) * $signed(W32_COS(9))
                 + $signed(O_real[9]) * $signed(W32_SIN(9));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[9] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[9] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT10;
        end
        // k=10
        S_OUT10: begin
          mult_r = $signed(O_real[10]) * $signed(W32_COS(10))
                 - $signed(O_imag[10]) * $signed(W32_SIN(10));
          mult_i = $signed(O_imag[10]) * $signed(W32_COS(10))
                 + $signed(O_real[10]) * $signed(W32_SIN(10));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[10] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[10] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT11;
        end
        // k=11
        S_OUT11: begin
          mult_r = $signed(O_real[11]) * $signed(W32_COS(11))
                 - $signed(O_imag[11]) * $signed(W32_SIN(11));
          mult_i = $signed(O_imag[11]) * $signed(W32_COS(11))
                 + $signed(O_real[11]) * $signed(W32_SIN(11));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[11] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[11] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT12;
        end
        // k=12
        S_OUT12: begin
          mult_r = $signed(O_real[12]) * $signed(W32_COS(12))
                 - $signed(O_imag[12]) * $signed(W32_SIN(12));
          mult_i = $signed(O_imag[12]) * $signed(W32_COS(12))
                 + $signed(O_real[12]) * $signed(W32_SIN(12));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[12] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[12] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT13;
        end
        // k=13
        S_OUT13: begin
          mult_r = $signed(O_real[13]) * $signed(W32_COS(13))
                 - $signed(O_imag[13]) * $signed(W32_SIN(13));
          mult_i = $signed(O_imag[13]) * $signed(W32_COS(13))
                 + $signed(O_real[13]) * $signed(W32_SIN(13));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[13] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[13] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT14;
        end  
        // k=14
        S_OUT14: begin
          mult_r = $signed(O_real[14]) * $signed(W32_COS(14))
                 - $signed(O_imag[14]) * $signed(W32_SIN(14));
          mult_i = $signed(O_imag[14]) * $signed(W32_COS(14))
                 + $signed(O_real[14]) * $signed(W32_SIN(14));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[14] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[14] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT15;
        end
        // k=15
        S_OUT15: begin
          mult_r = $signed(O_real[15]) * $signed(W32_COS(15))
                 - $signed(O_imag[15]) * $signed(W32_SIN(15));
          mult_i = $signed(O_imag[15]) * $signed(W32_COS(15))
                 + $signed(O_real[15]) * $signed(W32_SIN(15));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[15] + scaled_r[WIDTH-1:0];
          out_imag <= E_imag[15] + scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT16;
        end
        // k=16
        
        S_OUT16: begin
          mult_r = $signed(O_real[0]) * $signed(W32_COS(0))
                 - $signed(O_imag[0]) * $signed(W32_SIN(0));
          mult_i = $signed(O_imag[0]) * $signed(W32_COS(0))
                 + $signed(O_real[0]) * $signed(W32_SIN(0));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[0] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[0] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT17;
        end
         // k=17
        S_OUT17: begin
          mult_r = $signed(O_real[1]) * $signed(W32_COS(1))
                 - $signed(O_imag[1]) * $signed(W32_SIN(1));
          mult_i = $signed(O_imag[1]) * $signed(W32_COS(1))
                 + $signed(O_real[1]) * $signed(W32_SIN(1));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[1] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[1] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT18;
        end
        // k=18
        S_OUT18: begin
          mult_r = $signed(O_real[2]) * $signed(W32_COS(2))
                 - $signed(O_imag[2]) * $signed(W32_SIN(2));
          mult_i = $signed(O_imag[2]) * $signed(W32_COS(2))
                 + $signed(O_real[2]) * $signed(W32_SIN(2));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[2] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[2] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT19;
        end
        // k=19
        S_OUT19: begin
          mult_r = $signed(O_real[3]) * $signed(W32_COS(3))
                 - $signed(O_imag[3]) * $signed(W32_SIN(3));
          mult_i = $signed(O_imag[3]) * $signed(W32_COS(3))
                 + $signed(O_real[3]) * $signed(W32_SIN(3));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[3] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[3] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT20;
        end
        // k=20
        S_OUT20: begin
          mult_r = $signed(O_real[4]) * $signed(W32_COS(4))
                 - $signed(O_imag[4]) * $signed(W32_SIN(4));
          mult_i = $signed(O_imag[4]) * $signed(W32_COS(4))
                 + $signed(O_real[4]) * $signed(W32_SIN(4));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[4] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[4] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT21;
        end
        // k=21
        S_OUT21: begin
          mult_r = $signed(O_real[5]) * $signed(W32_COS(5))
                 - $signed(O_imag[5]) * $signed(W32_SIN(5));
          mult_i = $signed(O_imag[5]) * $signed(W32_COS(5))
                 + $signed(O_real[5]) * $signed(W32_SIN(5));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[5] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[5] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT22;
        end
        // k=22
        S_OUT22: begin
          mult_r = $signed(O_real[6]) * $signed(W32_COS(6))
                 - $signed(O_imag[6]) * $signed(W32_SIN(6));
          mult_i = $signed(O_imag[6]) * $signed(W32_COS(6))
                 + $signed(O_real[6]) * $signed(W32_SIN(6));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[6] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[6] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT23;
        end
        // k=23
        S_OUT23: begin
          mult_r = $signed(O_real[7]) * $signed(W32_COS(7))
                 - $signed(O_imag[7]) * $signed(W32_SIN(7));
          mult_i = $signed(O_imag[7]) * $signed(W32_COS(7))
                 + $signed(O_real[7]) * $signed(W32_SIN(7));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[7] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[7] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT24;
        end  
        
        // k=24
        S_OUT24: begin
          mult_r = $signed(O_real[8]) * $signed(W32_COS(8))
                 - $signed(O_imag[8]) * $signed(W32_SIN(8));
          mult_i = $signed(O_imag[8]) * $signed(W32_COS(8))
                 + $signed(O_real[8]) * $signed(W32_SIN(8));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[8] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[8] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT25;
        end
         // k=25
        S_OUT25: begin
          mult_r = $signed(O_real[9]) * $signed(W32_COS(9))
                 - $signed(O_imag[9]) * $signed(W32_SIN(9));
          mult_i = $signed(O_imag[9]) * $signed(W32_COS(9))
                 + $signed(O_real[9]) * $signed(W32_SIN(9));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[9] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[9] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT26;
        end
        // k=26
        S_OUT26: begin
          mult_r = $signed(O_real[10]) * $signed(W32_COS(10))
                 - $signed(O_imag[10]) * $signed(W32_SIN(10));
          mult_i = $signed(O_imag[10]) * $signed(W32_COS(10))
                 + $signed(O_real[10]) * $signed(W32_SIN(10));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[10] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[10] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT27;
        end
        // k=27
        S_OUT27: begin
          mult_r = $signed(O_real[11]) * $signed(W32_COS(11))
                 - $signed(O_imag[11]) * $signed(W32_SIN(11));
          mult_i = $signed(O_imag[11]) * $signed(W32_COS(11))
                 + $signed(O_real[11]) * $signed(W32_SIN(11));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[11] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[11] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT28;
        end
        // k=28
        S_OUT28: begin
          mult_r = $signed(O_real[12]) * $signed(W32_COS(12))
                 - $signed(O_imag[12]) * $signed(W32_SIN(12));
          mult_i = $signed(O_imag[12]) * $signed(W32_COS(12))
                 + $signed(O_real[12]) * $signed(W32_SIN(12));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[12] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[12] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT29;
        end
        // k=29
        S_OUT29: begin
          mult_r = $signed(O_real[13]) * $signed(W32_COS(13))
                 - $signed(O_imag[13]) * $signed(W32_SIN(13));
          mult_i = $signed(O_imag[13]) * $signed(W32_COS(13))
                 + $signed(O_real[13]) * $signed(W32_SIN(13));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[13] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[13] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT30;
        end  
        // k=30
        S_OUT30: begin
          mult_r = $signed(O_real[14]) * $signed(W32_COS(14))
                 - $signed(O_imag[14]) * $signed(W32_SIN(14));
          mult_i = $signed(O_imag[14]) * $signed(W32_COS(14))
                 + $signed(O_real[14]) * $signed(W32_SIN(14));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[14] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[14] - scaled_i[WIDTH-1:0];
          out_valid <= 1;
          state <= S_OUT31;
        end
        // k=6
        S_OUT31: begin
          mult_r = $signed(O_real[15]) * $signed(W32_COS(15))
                 - $signed(O_imag[15]) * $signed(W32_SIN(15));
          mult_i = $signed(O_imag[15]) * $signed(W32_COS(15))
                 + $signed(O_real[15]) * $signed(W32_SIN(15));
                 
          // Normalize back to input Q-format (Q7.9)
          scaled_r = mult_r >>> (TW_WIDTH - 2);   // shift by 14 if TW_WIDTH=16
          scaled_i = mult_i >>> (TW_WIDTH - 2);
        
          out_real <= E_real[15] - scaled_r[WIDTH-1:0];
          out_imag <= E_imag[15] - scaled_i[WIDTH-1:0];
          out_valid <= 1;out_last <= 1;
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
