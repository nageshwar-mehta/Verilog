`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2025 19:12:45
// Design Name: 
// Module Name: uart_tx
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
//IDLE -> start -> data -> stop
//data = 8 bits
// |start bit|data-bits|stop-bits|
module uart_tx(input clk, wr_en,rst, tx_en,
               input [7:0] data_in,
               output reg  tx, 
               output busy               
    );
    
    localparam IDLE = 2'b00,
              START = 2'b01,
              DATA = 2'b10,
              STOP = 2'b11;
    reg [1:0] state = IDLE;  
    reg [7:0] data_reg; 
    reg [2:0] index;                     
    
    always @(posedge clk) begin
        if(rst)begin
            tx <= 1'b1; 
            state <= IDLE;
            index <= 3'b0;
        end
        else begin
            case (state)
            IDLE : begin
                tx <= 1'b1;
                if(wr_en)begin
                    state <= START;
                    data_reg <= data_in; //store parallel input data
                    index <= 3'd0;
                end
                else state <= IDLE;
            end
            START : begin
                if(tx_en)begin
                    tx <= 1'b0; //start bit
                    state <= DATA;                
                end
                else state <= START;
            end
            DATA : begin 
                if(tx_en) begin 
                    tx <= data_reg[index];
                    if(index == 3'd7)begin
                        state <= STOP;                    
                    end
                    else begin                    
                        index <= index + 1'b1;
                    end
                end                
            end
            STOP : begin
                if(tx_en)begin
                    tx <= 1'b1; //stop bit
                    state <= IDLE;
                end          
            end
            default : begin
                tx <= 1'b1;
                state <= IDLE;
            end
            endcase
        end        
    end 
    
    assign busy = (state != IDLE );             
                    
endmodule
