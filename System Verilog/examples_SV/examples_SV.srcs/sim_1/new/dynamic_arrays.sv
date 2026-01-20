`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 23:43:24
// Design Name: 
// Module Name: dynamic_arrays
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


module dynamic_arrays;
    int dyn_arr1[];
    initial begin
        $display("size of dyn_arr1 = %0d",dyn_arr1.size());
        dyn_arr1 = new[6];
        $display("size of dyn_arr1 = %0d",dyn_arr1.size());
        foreach (dyn_arr1[i])begin
            dyn_arr1[i] = i*2;
        end  
        $display("elements of dyn_arr1 = %p", dyn_arr1);      
    end
endmodule
