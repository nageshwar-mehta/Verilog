
`timescale 1ns / 1ps

module FFT4pt
  #(parameter WIDTH=16)
  (
    input clk, rstn, in_valid,
    input  signed [WIDTH-1:0] in_real,
    input  signed [WIDTH-1:0] in_imag,
    output reg out_valid, out_last,
    output reg signed [WIDTH-1:0] out_real,
    output reg signed [WIDTH-1:0] out_imag
  );

 //=============ROM INITIALIZATION FOR INPUTS===================//
  reg signed [WIDTH-1:0] x_real[0:3], x_imag[0:3];
  reg [1:0] in_count;

 //=========================FSM================================// 
  reg [3:0] state;
  localparam S_IDLE     = 4'd0,
             S_COLLECT  = 4'd1,
             S_FFT_FEED = 4'd2,  // parallel feeding stage
             S_COMBINE  = 4'd3,
             S_OUT0     = 4'd4,
             S_OUT1     = 4'd5,
             S_OUT2     = 4'd6,
             S_OUT3     = 4'd7;

//==================2 POINT FFT OUTPUTS====================//
  wire signed [WIDTH-1:0] even_out_real, even_out_imag;
  wire signed [WIDTH-1:0] odd_out_real,  odd_out_imag;
  wire even_out_valid, odd_out_valid, even_last, odd_last;

//==================2 POINT FFT INPUTS====================//
  reg even_in_valid, odd_in_valid;
  reg signed [WIDTH-1:0] even_in_real, even_in_imag;
  reg signed [WIDTH-1:0] odd_in_real, odd_in_imag;


//==========================================================//
//CULEY-TOOKEY DIVIDE AND CONQUER ALGORITHM FOR DIT -FFT//
//Split input into even/odd time samples.//
//==========================================================//

//============FFT (2-POINT) EVEN================//
  FFT2pt #(WIDTH) fft_even (
    .clk(clk), .rstn(rstn),
    .in_valid(even_in_valid),
    .in_real(even_in_real),
    .in_imag(even_in_imag),
    .out_valid(even_out_valid), .out_last(even_last),
    .out_real(even_out_real), .out_imag(even_out_imag)
  );

//============FFT (2-POINT) ODD================//
  FFT2pt #(WIDTH) fft_odd (
    .clk(clk), .rstn(rstn),
    .in_valid(odd_in_valid),
    .in_real(odd_in_real),
    .in_imag(odd_in_imag),
    .out_valid(odd_out_valid), .out_last(odd_last),
    .out_real(odd_out_real), .out_imag(odd_out_imag)
  );

//==============ROM INITIALIZATION FOR INTERMEDIATE RESULTS============//
  reg signed [WIDTH-1:0] E_real[0:1], E_imag[0:1];
  reg signed [WIDTH-1:0] O_real[0:1], O_imag[0:1];
  reg [1:0] e_count, o_count;
  
  
//=============PROCEDURES====================//
  always @(posedge clk or negedge rstn) begin
    //------------------------------------//  
    if(!rstn) begin
      state     <= S_IDLE;
      in_count  <= 0;
      out_valid <= 0;
      out_last  <= 0;
      e_count   <= 0;
      o_count   <= 0;
    //------------------------------------//       
    end else begin
      out_valid <= 0;
      out_last  <= 0;
      even_in_valid <= 0;
      odd_in_valid  <= 0;


      case(state)
        //-------4-INPUTS TO ROM--------//
        S_IDLE: begin
          if(in_valid) begin
            x_real[0] <= in_real;
            x_imag[0] <= in_imag;
            in_count  <= 1;
            state     <= S_COLLECT;
          end
        end
        S_COLLECT: begin
          if(in_valid) begin
            x_real[in_count] <= in_real;
            x_imag[in_count] <= in_imag;
            if(in_count == 2'd3) begin
              state <= S_FFT_FEED;
              in_count <= 0;
            end else begin
              in_count <= in_count + 1;
            end
          end
        end
        //---------------------------------//

        //----Parallel feeding: send (x0,x2)->even fft and (x1,x3) -->odd fft----//
        S_FFT_FEED: begin
          case(in_count)
            0: begin
              even_in_real  <= x_real[0];
              even_in_imag  <= x_imag[0];
              even_in_valid <= 1;

              odd_in_real   <= x_real[1];
              odd_in_imag   <= x_imag[1];
              odd_in_valid  <= 1;

              in_count <= 1;
            end
            1: begin
              even_in_real  <= x_real[2];
              even_in_imag  <= x_imag[2];
              even_in_valid <= 1;

              odd_in_real   <= x_real[3];
              odd_in_imag   <= x_imag[3];
              odd_in_valid  <= 1;

              in_count <= 0;
              state    <= S_COMBINE; // wait for FFT2pt outputs
            end
          endcase
        end
        //-------------------------------------------------------//
        
        

        //---------Store 2-point FFT outputs----------//
        S_COMBINE: begin
          if(even_out_valid) begin
            E_real[e_count] <= even_out_real;
            E_imag[e_count] <= even_out_imag;
            e_count <= e_count + 1;
          end
          if(odd_out_valid) begin
            O_real[o_count] <= odd_out_real;
            O_imag[o_count] <= odd_out_imag;
            o_count <= o_count + 1;
          end
          if(even_last && odd_last) begin
            e_count <= 0;
            o_count <= 0;
            state   <= S_OUT0;
          end
        end
        //---------------------------------------------//


        //--------STAGE-2 OUTPUT CALCULATIONS-----------//
        S_OUT0: begin
          out_real  <= E_real[0] + O_real[0];
          out_imag  <= E_imag[0] + O_imag[0];
          out_valid <= 1;
          state     <= S_OUT1;
        end

        S_OUT1: begin
          // X1 = E1 - j*O1 = (E1r + O1i) + j(E1i - O1r)
          out_real  <= E_real[1] + O_imag[1];
          out_imag  <= E_imag[1] - O_real[1];
          out_valid <= 1;
          state     <= S_OUT2;
        end

        S_OUT2: begin
          out_real  <= E_real[0] - O_real[0];
          out_imag  <= E_imag[0] - O_imag[0];
          out_valid <= 1;
          state     <= S_OUT3;
        end

        S_OUT3: begin
          // X3 = E1 + j*O1 = (E1r - O1i) + j(E1i + O1r)
          out_real  <= E_real[1] - O_imag[1];
          out_imag  <= E_imag[1] + O_real[1];
          out_valid <= 1;
          out_last  <= 1;  // final output
          state     <= S_IDLE;
        end
        //-------------------------------------------------------//

      endcase
    end
  end
endmodule


