`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2025 23:08:26
// Design Name: 
// Module Name: uart_rx
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
//rx_en -> baud rate generator

module uart_rx(
               input clk, rst, rx, rdy_clr, rx_en,
               output reg rdy,
               output reg [7:0] data_out
    );
    
    localparam START = 2'b00,
               DATA =  2'b01,
               STOP =  2'b10;
    reg [1:0] state = START;
    reg [3:0] sample = 0;
    reg [2:0] index = 0;
    reg [7:0] data_reg = 8'b0;
                   
    
    always @(posedge clk)begin
        if(rst) begin
            rdy <= 0;
            data_out <= 0;
            state <= START;
            sample <= 0;
            index <= 0;
            data_reg <=0;                        
        end
        else begin
            if(rdy_clr) rdy <= 0;
            if(rx_en)begin
                case(state)
                    START : begin
                        if(rx == 0)begin //start bit came
                            sample <= sample + 1;
                            if(sample == 7)begin
                                sample <=0;
                                state <= DATA;
                            end
                        end
                        else begin
                            sample <= 0;
                        end                       
                    end 
                    DATA : begin
                        sample <= sample + 1;
                        if(sample == 8) begin
                            data_reg[index] <= rx;
                            if(index == 7) begin
                                index <= 0;
                                sample <= 0;
                                state <= STOP;
                            end
                            else index <= index + 4'b1;
                        end
                    end  
                    STOP : begin
                        sample <= sample + 1;
                        if (sample == 8) begin
                            state <= START;
                            data_out <= data_reg;
                            rdy <= (rx == 1); //stop bit correct or not (error checking)
                            sample <= 0;
                        end                        
                    end 
                    default : begin
                        state <= START;
                    end                
                    
                endcase 
            end
        end
    end
    
    
endmodule
