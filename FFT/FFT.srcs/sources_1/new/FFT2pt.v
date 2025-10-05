`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2025 01:41:34
// Design Name: 
// Module Name: FFT2pt
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


module FFT2pt
    #(parameter WIDTH = 16) 
    (input clk, rstn,in_valid, 
    input signed [WIDTH -1:0] in_real,
    input signed [WIDTH -1:0] in_imag,
    output reg out_valid, out_last,
    output reg signed [WIDTH -1:0] out_real,
    output reg signed [WIDTH -1:0] out_imag
    );
    
    //Store two inputs : 
    reg signed[WIDTH-1:0] x_real[0:1], x_imag[0:1];
    reg [1:0]state ;
    
    //states
    localparam IDLE =   2'd0;
    localparam IN_COLLECT = 2'd1;
    localparam OUT_0 = 2'd2;
    localparam OUT_1 = 2'd3;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            state <= IDLE;
            out_valid <= 1'b0;
            out_last <= 1'b0;
            out_real <= {WIDTH{1'b0}};
            out_imag <= {WIDTH{1'b0}}; 
            x_real[0] <= {WIDTH{1'b0}};
            x_real[1] <= {WIDTH{1'b0}};
            x_imag[0] <= {WIDTH{1'b0}};
            x_imag[1] <= {WIDTH{1'b0}};           
        end
        else begin 
            out_valid<=1'b0;
            out_last<=1'b0;
            case(state)
                IDLE : begin
                    if(in_valid)begin
                        x_real[0]<=in_real;
                        x_imag[0]<=in_imag;
                        state <= IN_COLLECT;
                    end
                end
                IN_COLLECT : begin
                    if(in_valid)begin
                        x_real[1]<=in_real;
                        x_imag[1]<=in_imag;
                        state <= OUT_0;
                    end
                end
                OUT_0 : begin
                    out_real<=x_real[0]+x_real[1];
                    out_imag<=x_imag[0]+x_imag[1];
                    out_valid<=1'b1;
                    state <= OUT_1;
                end
                OUT_1 : begin
                    out_real<=x_real[0]-x_real[1];
                    out_imag<=x_imag[0]-x_imag[1];
                    out_valid<=1'b1;
                    out_last<=1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
    
    
endmodule
