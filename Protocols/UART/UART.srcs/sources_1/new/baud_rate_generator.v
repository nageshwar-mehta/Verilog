`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nageshwar Kumar - IIT Jammu (nagesh03mehta@gmail.com)
// 
// Create Date: 16.11.2025 19:16:25
// Design Name: 
// Module Name: baud_rate_generator
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
//assuming clk freq = 50MHz
//baud rate = 9600
//cycles needed => (50*10^6)/9600 = 5208 cycles
//for reciever we don't want to loose any data so we do oversampling by factor of 16
 // therefore rx_cycles needed => 5208/16 = 325 cycles
 
module baud_rate_generator(
    input clk, rst,
    output rx_en,
    output tx_en
    );
    
    reg [8:0]rx_counter;
    reg [12:0]tx_counter;
    
    //RX counter 
    always @(posedge clk) begin
        if(rst) rx_counter <= 0;
        else if(rx_counter == 324)begin
            rx_counter <= 0;
        end
        else begin 
            rx_counter <= rx_counter + 1'b1;
        end
    end
    
    always @(posedge clk) begin
        if(rst) rx_counter <= 0;
        else if(tx_counter == 5207)begin
            tx_counter <= 0;
        end
        else begin 
            tx_counter <= tx_counter + 1'b1;
        end
    end
    
    assign rx_en = (rx_counter == 324) ? 1'b1 : 1'b0;
    assign tx_en = (tx_counter == 5207) ? 1'b1 : 1'b0;
    
        
endmodule
