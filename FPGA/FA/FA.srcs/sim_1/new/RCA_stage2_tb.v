`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.09.2025 14:50:29
// Design Name: 
// Module Name: RCA_stage2_tb
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


module RCA_stage2_tb();
    reg [3:0]a,b;
    reg cin;
    reg clk;
    
    wire [3:0]sum;
    wire cout;
    
    RCA_2_stage DUT(
        .clk(clk),
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    initial begin 
    clk = 0;
    end
    
    always begin
        #5 clk = ~clk;
    end
    
    always begin 
        #5;
         a = 4'd0;
         b = 4'd0; 
         cin = 1'b0;
         
         #5;
         a = 4'd1;
         b = 4'd1; 
         cin = 1'b1;
         
         #5;
         a = 4'd11;
         b = 4'd1; 
         cin = 1'b1;
         
         #5;
         a = 4'd14;
         b = 4'd5; 
         cin = 1'b1;
         
         #5;
         a = 4'd14;
         b = 4'd5; 
         cin = 1'b0;
         $finish;
    end
    
    

endmodule
