`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Jammu
// Engineer: Nageshwar Kumar
// 
// Module Name: FFT2pt_opt
// Description: 2-point Radix-2 DIT FFT Butterfly (Fully Synthesizable)
//
//////////////////////////////////////////////////////////////////////////////////

module FFT2pt_opt
  #(parameter WIDTH = 16)
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

  // Internal storage for 2 input samples
  reg signed [WIDTH-1:0] x_real [0:1];
  reg signed [WIDTH-1:0] x_imag [0:1];
  reg [1:0] state;
  reg [1:0] k;  // sample index (0 or 1)

  // State encoding
  localparam IDLE    = 2'd0;
  localparam OUT_ADD = 2'd1;
  localparam OUT_SUB = 2'd2;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state     <= IDLE;
      k         <= 0;
      out_valid <= 1'b0;
      out_last  <= 1'b0;
      out_real  <= {WIDTH{1'b0}};
      out_imag  <= {WIDTH{1'b0}};
      x_real[0] <= {WIDTH{1'b0}};
      x_real[1] <= {WIDTH{1'b0}};
      x_imag[0] <= {WIDTH{1'b0}};
      x_imag[1] <= {WIDTH{1'b0}};
    end else begin
      // Default outputs
      out_valid <= 1'b0;
      out_last  <= 1'b0;

      case (state)
        IDLE: begin
          if (in_valid) begin
            x_real[k] <= in_real;
            x_imag[k] <= in_imag;
            k <= k + 1'b1;
          end

          if (k == 2'd1 && in_valid) begin // two samples collected
            state <= OUT_ADD;
            k <= 0;
          end
        end

        OUT_ADD: begin
          out_real  <= x_real[0] + x_real[1];
          out_imag  <= x_imag[0] + x_imag[1];
          out_valid <= 1'b1;
          state     <= OUT_SUB;
        end

        OUT_SUB: begin
          out_real  <= x_real[0] - x_real[1];
          out_imag  <= x_imag[0] - x_imag[1];
          out_valid <= 1'b1;
          out_last  <= 1'b1;
          state     <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
