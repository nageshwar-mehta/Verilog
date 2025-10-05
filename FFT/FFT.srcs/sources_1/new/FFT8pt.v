//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 03.10.2025 04:27:56
//// Design Name: 
//// Module Name: FFT8pt
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module FFT8pt
//  #(parameter WIDTH=16,
//    QF = 9,
//    TW_WIDTH = 12)
//  (
//    input clk, rstn, in_valid,
//    input  signed [WIDTH-1:0] in_real,
//    input  signed [WIDTH-1:0] in_imag,
//    output reg out_valid, out_last,
//    output reg signed [WIDTH-1:0] out_real,
//    output reg signed [WIDTH-1:0] out_imag
//  );
  
  
// //=============ROM INITIALIZATION FOR INPUTS===================//
//  reg signed [WIDTH-1:0] x_real[0:7], x_imag[0:7];
//  reg [2:0] in_count; 
  
  
////=========================FSM================================//   
//  reg [3:0] state;
//  localparam    S_IDLE          = 4'd0, 
//                S_COLLECT       = 4'd1, 
//                S_FFT_FEED      = 4'd2, 
//                S_COMBINE       = 4'd3,
//                S_OUT0          = 4'd4, 
//                S_OUT1          = 4'd5, 
//                S_OUT2          = 4'd6, 
//                S_OUT3          = 4'd7,
//                S_OUT4          = 4'd8, 
//                S_OUT5          = 4'd9, 
//                S_OUT6          = 4'd10, 
//                S_OUT7          = 4'd11;

  
////==================4 POINT FFT OUTPUTS====================//
//  wire signed [WIDTH-1:0] even_out_real, even_out_imag;
//  wire signed [WIDTH-1:0] odd_out_real,  odd_out_imag;
//  wire even__out_valid, odd_out_valid, even_out_last, odd_out_last;
  

////==================2 POINT FFT INPUTS====================//
//  reg even_in_valid, odd_in_valid;
//  reg signed [WIDTH-1:0] even_in_real, even_in_imag;
//  reg signed [WIDTH-1:0] odd_in_real, odd_in_imag;



////==========================================================//
////CULEY-TOOKEY DIVIDE AND CONQUER ALGORITHM FOR DIT -FFT//
////Split input into even/odd time samples.//
////==========================================================//



////============FFT (4-POINT) EVEN================//
//  FFT4pt #(WIDTH) fft_even (
//    .clk(clk), .rstn(rstn),
//    .in_valid(even_in_valid),
//    .in_real(even_in_real),
//    .in_imag(even_in_imag),
//    .out_valid(even_out_valid), .out_last(even__out_last),
//    .out_real(even_out_real), .out_imag(even_out_imag)
//  );  
  

////============FFT (4-POINT) ODD================//
//  FFT4pt #(WIDTH) fft_odd (
//    .clk(clk), .rstn(rstn),
//    .in_valid(odd_in_valid),
//    .in_real(odd_in_real),
//    .in_imag(odd_in_imag),
//    .out_valid(odd_out_valid), .out_last(odd__out_last),
//    .out_real(odd_out_real), .out_imag(odd_out_imag)
//  );  
  
  
////==============ROM INITIALIZATION FOR INTERMEDIATE RESULTS============//
//  reg signed [WIDTH-1:0] E_real[0:3], E_imag[0:3];
//  reg signed [WIDTH-1:0] O_real[0:3], O_imag[0:3];
//  reg [1:0] e_count, o_count;  
  
  
////  real tw70711 = 0.70711;
//  localparam signed [TW_WIDTH-1:0] TW1 = $signed(integer'(0.70710678 * (1<<QF)));
//  integer i;
   
////=============PROCEDURES====================//
//  always @(posedge clk or negedge rstn) begin
//    //------------------------------------//  
//    if(!rstn) begin
//      state     <= S_IDLE;
//      in_count  <= 0;
//      out_valid <= 0;
//      out_last  <= 0;
//      e_count   <= 0;
//      o_count   <= 0;
//      even_in_valid <=0;
//      odd_in_valid <=0;
//      even_in_real <=0;
//      even_in_imag <=0;
//      odd_in_real <= 0;
//      odd_in_imag <=0;
//      out_real <= 0;
//      out_imag <= 0;
//      for(i=0;i<8;i=i+1)begin
//        x_real[i] <=0;
//        x_imag[i] <=0;
//      end
//      for(i=0;i<8;i=i+1)begin
//        E_real[i] <=0;
//        E_imag[i] <=0;
//        O_real[i] <=0;
//        O_imag[i] <=0;
//      end
//    //------------------------------------//       
//    end else begin
//      out_valid <= 0;
//      out_last  <= 0;
//      even_in_valid <= 0;
//      odd_in_valid  <= 0;


//      case(state)
//        //-------4-INPUTS TO ROM--------//
//        S_IDLE: begin
//          if(in_valid) begin
//            x_real[0] <= in_real;
//            x_imag[0] <= in_imag;
//            in_count  <= 1;
//            state     <= S_COLLECT;
//          end
//        end
//        S_COLLECT: begin
//          if(in_valid) begin
//            x_real[in_count] <= in_real;
//            x_imag[in_count] <= in_imag;
//            if(in_count == 3'd7) begin
//              state <= S_FFT_FEED;
//              in_count <= 0;
//              e_count  <= 0;
//              o_count  <= 0;
//            end else begin
//              in_count <= in_count + 1;
//            end
//          end
//        end
//        //---------------------------------//

//        //----Parallel feeding: send (x0,x2,x4,x6) and (x1,x3,x5,x7)----//
//        S_FFT_FEED: begin
//          case(in_count)
//            0: begin
//              even_in_real  <= x_real[0];
//              even_in_imag  <= x_imag[0];
//              even_in_valid <= 1;

//              odd_in_real   <= x_real[1];
//              odd_in_imag   <= x_imag[1];
//              odd_in_valid  <= 1;

//              in_count <= 1;
//            end
            
//            1: begin
//              even_in_real  <= x_real[2];
//              even_in_imag  <= x_imag[2];
//              even_in_valid <= 1;

//              odd_in_real   <= x_real[3];
//              odd_in_imag   <= x_imag[3];
//              odd_in_valid  <= 1;

//              in_count <= 2;
//              end
//            2: begin
//              even_in_real  <= x_real[4];
//              even_in_imag  <= x_imag[4];
//              even_in_valid <= 1;

//              odd_in_real   <= x_real[5];
//              odd_in_imag   <= x_imag[5];
//              odd_in_valid  <= 1;

//              in_count <= 3;
//              end
              
//            3: begin
//              even_in_real  <= x_real[6];
//              even_in_imag  <= x_imag[6];
//              even_in_valid <= 1;

//              odd_in_real   <= x_real[7];
//              odd_in_imag   <= x_imag[7];
//              odd_in_valid  <= 1;

//              in_count <= 0;
//              state    <= S_COMBINE; // wait for FFT4pt outputs
//            end
//          endcase
//        end
//        //-------------------------------------------------------//
        
        

//        //---------Store 4-point FFT outputs----------//
//        S_COMBINE: begin
//          if(even_out_valid) begin
//            E_real[e_count] <= even_out_real;
//            E_imag[e_count] <= even_out_imag;
//            e_count <= e_count + 1;
//          end
//          if(odd_out_valid) begin
//            O_real[o_count] <= odd_out_real;
//            O_imag[o_count] <= odd_out_imag;
//            o_count <= o_count + 1;
//          end
//          if(even_out_last && odd_out_last) begin
//            e_count <= 0;
//            o_count <= 0;
//            state   <= S_OUT0;
//          end
//        end
//        //---------------------------------------------//


//        //--------STAGE-3 OUTPUT CALCULATIONS-----------//
//        S_OUT0: begin
//          out_real  <= E_real[0] + O_real[0];
//          out_imag  <= E_imag[0] + O_imag[0];
//          out_valid <= 1;
//          state     <= S_OUT1;
//        end

//        S_OUT1: begin
//          // X1 = E1 + W8^1*O1
//          out_real  <= (E_real[1] + tw70711*(O_real[1] + O_imag[1]));
//          out_imag  <= (E_imag[1] + tw70711*(O_imag[1] - O_real[1]));
//          out_valid <= 1;
//          state     <= S_OUT2;
//        end

//        S_OUT2: begin
//          out_real  <= E_real[2] + O_imag[2];
//          out_imag  <= E_imag[2] - O_real[2];
//          out_valid <= 1;
//          state     <= S_OUT3;
//        end
        
//        S_OUT3: begin
//          out_real  <= E_real[3] - tw70711*(O_real[3]+O_imag[3]);
//          out_imag  <= E_imag[3] + tw70711*(O_real[3] - O_imag[3]);
//          out_valid <= 1;
//          state     <= S_OUT4;
//        end
        
//        S_OUT4: begin
//          out_real  <= E_real[0] - O_real[0];
//          out_imag  <= E_imag[0] - O_imag[0];
//          out_valid <= 1;
//          state     <= S_OUT5;
//        end
        
//        S_OUT5: begin
//          out_real  <= E_real[1] - tw70711*(O_real[1]+O_imag[1]);
//          out_imag  <= E_imag[1] + tw70711*(O_imag[1] - O_real[1]);
//          out_valid <= 1;
//          state     <= S_OUT6;
//        end
        
//        S_OUT6: begin
//          out_real  <= E_real[2] - O_imag[2];
//          out_imag  <= E_imag[2] - O_real[2];
//          out_valid <= 1;
//          state     <= S_OUT7;
//        end
        
//        S_OUT7: begin
//          out_real  <= E_real[3] + tw70711*(O_real[3]+O_imag[3]);
//          out_imag  <= E_imag[3] - tw70711*(O_real[3] - O_imag[3]);
//          out_valid <= 1;
//          out_last  <= 1;
//          state     <= S_IDLE;
//        end
//        //-------------------------------------------------------//
//        default : state <= S_IDLE;
//      endcase
//    end
//  end
  
//endmodule






`timescale 1ns / 1ps
module FFT8pt
  #(parameter integer WIDTH   = 16,
    parameter integer QF      = 9,    // fractional bits (Qm.QF)
    parameter integer TW_WIDTH= 12,   // bit-width to store twiddle constants
    parameter signed [TW_WIDTH-1:0] TW1 = 12'sd362 // 0.70710678 * 2^QF ~ 362 for QF=9
  )
  (
    input  clk, rstn, in_valid,
    input  signed [WIDTH-1:0] in_real,
    input  signed [WIDTH-1:0] in_imag,
    output reg out_valid, out_last,
    output reg signed [WIDTH-1:0] out_real,
    output reg signed [WIDTH-1:0] out_imag
  );

 //=============ROM INITIALIZATION FOR INPUTS===================//
  reg signed [WIDTH-1:0] x_real[0:7], x_imag[0:7];
  reg [2:0] in_count;

//=========================FSM================================// 
  reg [3:0] state;
  localparam    S_IDLE    = 4'd0,
                S_COLLECT = 4'd1,
                S_FFT_FEED= 4'd2,
                S_COMBINE = 4'd3,
                S_OUT0    = 4'd4,
                S_OUT1    = 4'd5,
                S_OUT2    = 4'd6,
                S_OUT3    = 4'd7,
                S_OUT4    = 4'd8,
                S_OUT5    = 4'd9,
                S_OUT6    = 4'd10,
                S_OUT7    = 4'd11;

                
//==================4 POINT FFT OUTPUTS====================//
  wire signed [WIDTH-1:0] even_out_real, even_out_imag;
  wire signed [WIDTH-1:0] odd_out_real,  odd_out_imag;
  wire even_out_valid, odd_out_valid, even_out_last, odd_out_last;


//==================4 POINT FFT INPUTS====================//
  reg even_in_valid, odd_in_valid;
  reg signed [WIDTH-1:0] even_in_real, even_in_imag;
  reg signed [WIDTH-1:0] odd_in_real, odd_in_imag;
  
  
//==========================================================//
//CULEY-TOOKEY DIVIDE AND CONQUER ALGORITHM FOR DIT -FFT//
//Split input into even/odd time samples.//
//==========================================================//
  
//============FFT (4-POINT) EVEN================//
  FFT4pt #(WIDTH) fft_even (
    .clk(clk), .rstn(rstn),
    .in_valid(even_in_valid),
    .in_real(even_in_real), .in_imag(even_in_imag),
    .out_valid(even_out_valid), .out_last(even_out_last),
    .out_real(even_out_real), .out_imag(even_out_imag)
  );
  
  
  //============FFT (4-POINT) ODD================//
  FFT4pt #(WIDTH) fft_odd (
    .clk(clk), .rstn(rstn),
    .in_valid(odd_in_valid),
    .in_real(odd_in_real), .in_imag(odd_in_imag),
    .out_valid(odd_out_valid), .out_last(odd_out_last),
    .out_real(odd_out_real), .out_imag(odd_out_imag)
  );

//==============ROM INITIALIZATION FOR INTERMEDIATE RESULTS============//
  reg signed [WIDTH-1:0] E_real[0:3], E_imag[0:3];
  reg signed [WIDTH-1:0] O_real[0:3], O_imag[0:3];
  reg [1:0] e_count, o_count;

  // Fixed-point temporaries widths (conservative)
  // tmp_sum width = WIDTH+1 (sum/diff of two WIDTH-bit signed numbers)
  reg signed [WIDTH:0] tmp_sum;

  // tmp_mult width = (WIDTH+1) + TW_WIDTH -> keep +1
  reg signed [WIDTH + TW_WIDTH : 0] tmp_mult;

  // tmp_scaled width after shifting right by QF
  reg signed [WIDTH + TW_WIDTH - QF : 0] tmp_scaled;

  // tmp_out for final add (keep one extra bit)
  reg signed [WIDTH + TW_WIDTH - QF + 1 : 0] tmp_out;

  integer i;

//=============STATE MACHINE PROCEDURES====================//
  always @(posedge clk or negedge rstn) begin
  
  //------------RESET---------------//
    if (!rstn) begin
      state <= S_IDLE;
      in_count <= 0;
      out_valid <= 0;
      out_last <= 0;
      e_count <= 0;
      o_count <= 0;
      even_in_valid <= 0; 
      odd_in_valid <= 0;
      even_in_real <= 0; 
      even_in_imag <= 0;
      odd_in_real <= 0; 
      odd_in_imag <= 0;
      out_real <= 0; 
      out_imag <= 0;
      tmp_sum <= 0; 
      tmp_mult <= 0; 
      tmp_scaled <= 0; 
      tmp_out <= 0;
      for (i=0; i<8; i=i+1) begin
        x_real[i] <= 0; 
        x_imag[i] <= 0; 
       end
      for (i=0; i<4; i=i+1) begin 
        E_real[i] <= 0; 
        E_imag[i] <= 0; 
        O_real[i] <= 0; 
        O_imag[i] <= 0; 
        end
//---------------------------------------//



//---------------------------------------//        
    end else begin
      out_valid <= 0;
      out_last <= 0;
      even_in_valid <= 0;
      odd_in_valid <= 0;

      case (state)
//-------------8-INPUTS TO ROM------------//
        S_IDLE: begin
          if (in_valid) begin
            x_real[0] <= in_real;
            x_imag[0] <= in_imag;
            in_count <= 3'd1;
            state <= S_COLLECT;
          end
        end

        S_COLLECT: begin
          if (in_valid) begin
            x_real[in_count] <= in_real;
            x_imag[in_count] <= in_imag;
            if (in_count == 3'd7) begin
              in_count <= 3'd0;
              e_count <= 2'd0; o_count <= 2'd0;
              state <= S_FFT_FEED;
            end else begin
              in_count <= in_count + 1;
            end
          end
        end
//-------------------------------------------------------//

        

//----Parallel feeding: send (x0,x2,x4,x6) and (x1,x3,x5,x7)----//        
        S_FFT_FEED: begin        
          case (in_count)
          
            3'd0: begin
              even_in_real  <= x_real[0]; 
              even_in_imag <= x_imag[0]; 
              even_in_valid <= 1'b1;
              
              odd_in_real   <= x_real[1]; 
              odd_in_imag  <= x_imag[1]; 
              odd_in_valid  <= 1'b1;
              
              in_count <= 3'd1;
            end
            
            3'd1: begin
              even_in_real  <= x_real[2]; 
              even_in_imag <= x_imag[2]; 
              even_in_valid <= 1'b1;
              
              odd_in_real   <= x_real[3]; 
              odd_in_imag  <= x_imag[3]; 
              odd_in_valid  <= 1'b1;
              
              in_count <= 3'd2;
            end
            
            3'd2: begin
              even_in_real  <= x_real[4]; 
              even_in_imag <= x_imag[4]; 
              even_in_valid <= 1'b1;
              
              odd_in_real   <= x_real[5]; 
              odd_in_imag  <= x_imag[5]; 
              odd_in_valid  <= 1'b1;
              
              in_count <= 3'd3;
            end
            
            3'd3: begin
              even_in_real  <= x_real[6]; 
              even_in_imag <= x_imag[6]; 
              even_in_valid <= 1'b1;
              
              odd_in_real   <= x_real[7]; 
              odd_in_imag  <= x_imag[7]; 
              odd_in_valid  <= 1'b1;
              
              in_count <= 3'd0;           
              state <= S_COMBINE;
            end
            
          endcase
        end
//------------------------------------------------------//


//-------------Store 4-point FFT outputs-------------//        
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
            e_count <= 2'd0; o_count <= 2'd0;
            state <= S_OUT0;
          end
        end
        //---------------------------------------------//


        //--------STAGE-2 OUTPUT CALCULATIONS-----------//        
        S_OUT0: begin
          // X0 = E0 + O0
          out_real <= E_real[0] + O_real[0];
          out_imag <= E_imag[0] + O_imag[0];
          out_valid <= 1'b1;
          state <= S_OUT1;
        end

        S_OUT1: begin
          // X1 = E1 + W8^1 * O1
          // X1_real = E_r1 + 0.7071*(Or1 + Oi1)
          // X1_imag = E_i1 + 0.7071*(Oi1 - Or1)

          // real part
          tmp_sum  = $signed(O_real[1]) + $signed(O_imag[1]);      // width WIDTH+1
          tmp_mult = tmp_sum * TW1;                                // width WIDTH+TW_WIDTH+1
          // rounding
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;                            // back to Q-format
          tmp_out = $signed(E_real[1]) + tmp_scaled;               // add E term
          out_real <= tmp_out[WIDTH-1:0];

          // imag part
          tmp_sum  = $signed(O_imag[1]) - $signed(O_real[1]);
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_imag[1]) + tmp_scaled;
          out_imag <= tmp_out[WIDTH-1:0];

          out_valid <= 1'b1;
          state <= S_OUT2;
        end

        S_OUT2: begin
          // X2 = E2 + W8^2*O2 ; W8^2 = -j => W*O real = Oi , imag = -Or
          out_real <= E_real[2] + O_imag[2];
          out_imag <= E_imag[2] - O_real[2];
          out_valid <= 1'b1;
          state <= S_OUT3;
        end

        S_OUT3: begin
          // X3 = E3 + W8^3 * O3 ; W8^3 = -0.7071 - j0.7071
          // Correct:
          // X3_real = E_r3 + t*(O_i3 - O_r3)  = E_r3 - t*(O_r3 - O_i3)
          // X3_imag = E_i3 - t*(O_r3 + O_i3)
        
          // real: tmp_sum = Or3 - Oi3 ; out_real = E_r3 - t*(Or3 - Oi3)
          tmp_sum  = $signed(O_real[3]) - $signed(O_imag[3]);  // Or - Oi
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_real[3]) - tmp_scaled;
          out_real <= tmp_out[WIDTH-1:0];
        
          // imag: tmp_sum = Or3 + Oi3 ; out_imag = E_i3 - t*(Or3 + Oi3)
          tmp_sum  = $signed(O_real[3]) + $signed(O_imag[3]);  // Or + Oi
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_imag[3]) - tmp_scaled;
          out_imag <= tmp_out[WIDTH-1:0];
        
          out_valid <= 1'b1;
          state <= S_OUT4;
        end


        S_OUT4: begin
          // X4 = E0 - O0
          out_real <= E_real[0] - O_real[0];
          out_imag <= E_imag[0] - O_imag[0];
          out_valid <= 1'b1;
          state <= S_OUT5;
        end

        S_OUT5: begin
          // X5 = E1 - W8^1 * O1
          // X5_real = E_r1 - t*(Or1 + Oi1)
          tmp_sum  = $signed(O_real[1]) + $signed(O_imag[1]);
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_real[1]) - tmp_scaled;
          out_real <= tmp_out[WIDTH-1:0];
        
          // X5_imag = E_i1 + t*(Or1 - Oi1)  <-- note order: Or - Oi
          tmp_sum  = $signed(O_real[1]) - $signed(O_imag[1]);  // Or - Oi  (was reversed before)
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_imag[1]) + tmp_scaled;
          out_imag <= tmp_out[WIDTH-1:0];
        
          out_valid <= 1'b1;
          state <= S_OUT6;
        end


        S_OUT6: begin
          // X6 = E2 - W8^2*O2 = E2 + j*O2
          // j*O2 => real = -Oi, imag = Or; so X6_real = E_r2 - Oi2 ; X6_imag = E_i2 + Or2
          out_real <= E_real[2] - O_imag[2];
          out_imag <= E_imag[2] + O_real[2];
          out_valid <= 1'b1;
          state <= S_OUT7;
        end

        S_OUT7: begin
          // X7 = E3 - W8^3 * O3
          // X7_real = E_r3 + 0.7071*(Or3 - Oi3)
          // X7_imag = E_i3 + 0.7071*(Or3 + Oi3)

          tmp_sum  = $signed(O_real[3]) - $signed(O_imag[3]);
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_real[3]) + tmp_scaled;
          out_real <= tmp_out[WIDTH-1:0];

          tmp_sum  = $signed(O_real[3]) + $signed(O_imag[3]);
          tmp_mult = tmp_sum * TW1;
          tmp_mult = tmp_mult + ( tmp_mult >= 0 ? (1 << (QF-1)) : - (1 << (QF-1)) );
          tmp_scaled = tmp_mult >>> QF;
          tmp_out = $signed(E_imag[3]) + tmp_scaled;
          out_imag <= tmp_out[WIDTH-1:0];

          out_valid <= 1'b1;
          out_last <= 1'b1; //FINAL OUTPUT
          state <= S_IDLE;
        end

        default: state <= S_IDLE;
      endcase
    end
  end

endmodule
