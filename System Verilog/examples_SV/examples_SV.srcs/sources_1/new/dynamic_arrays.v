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
    int dyn_arr1[], dyn_arr2[];
    initial begin
        $display("size of dyn_arr1 = %0d", dyn_arr1.size());//size of dyn_arr1 = 0
        dyn_arr1 = new[6];
        dyn_arr2 = new[4];        
        $display("size of dyn_arr1 = %0d", dyn_arr1.size());//size of dyn_arr1 = 6
        dyn_arr2 = '{1,2,3,4};
        foreach (dyn_arr1[i])
            dyn_arr1[i] = i*2;
    
        $display("elements of dyn_arr1 = %p", dyn_arr1);//elements of dyn_arr1 = '{0, 2, 4, 6, 8, 10}
        $display("elements of dyn_arr2 = %p", dyn_arr2);//elements of dyn_arr2 = '{1, 2, 3, 4}
        
        //copy method
        dyn_arr2 = dyn_arr1;
        $display("elements of dyn_arr2 after copying = %p", dyn_arr2); //elements of dyn_arr2 after copying = '{0, 2, 4, 6, 8, 10}
        dyn_arr1[1] = 10;
        $display("elements of dyn_arr1 (after modyfying) = %p", dyn_arr1); //elements of dyn_arr1 (after modyfying) = '{0, 10, 4, 6, 8, 10}
        $display("elements of dyn_arr2 (after modyfying dyn_arr1) = %p", dyn_arr2);//elements of dyn_arr2 (after modyfying dyn_arr1) = '{0, 2, 4, 6, 8, 10}
        
        //changing size
         dyn_arr1 = new[10];//all elements are deleted
         dyn_arr2 = new[10](dyn_arr2);//resizing with restoring prev elements
         $display("elements of dyn_arr1 (after resizing) = %p", dyn_arr1); //elements of dyn_arr1 (after resizing) = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
         $display("elements of dyn_arr2 (after resizing) = %p", dyn_arr2);//elements of dyn_arr2 (after resizing) = '{0, 2, 4, 6, 8, 10, 0, 0, 0, 0}
        
        //delete
        dyn_arr1.delete();
//        dyn_arr2.delete(1); invalid statement in dynamic array
        $display("elements of dyn_arr1 (after deleting) = %p", dyn_arr1); //elements of dyn_arr1 (after resizing) = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
//        $display("elements of dyn_arr2 (after deleting) = %p", dyn_arr2);//elements of dyn_arr2 (after resizing) = '{0, 2, 4, 6, 8, 10, 0, 0, 0, 0}
        
        $finish;
    end

endmodule
