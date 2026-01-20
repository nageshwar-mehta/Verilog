`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 22:56:53
// Design Name: 
// Module Name: packed_unpacked
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


module packed_unpacked;

// bit [7:0] packed_1d_arr;
// initial begin
//    packed_1d_arr = 8'd19;
//    $display("Size of packed_1d_arr = %0d",$size(packed_1d_arr));
//    for(int i=0;i<$size(packed_1d_arr);i++)begin
//        $display("packed_1d_arr[%0d] = %0b",i,packed_1d_arr[i]);
//    end
// end

// bit [3:0][7:0]packed_2d_arr;
// initial begin
////    packed_2d_arr = 32'hffef_ffef;
//    packed_2d_arr = {8'd250,8'd200,8'd150,8'd100};
//    $display("Size of packed_2d_arr = %0d",$size(packed_2d_arr));
//    for(int i=0;i<$size(packed_2d_arr);i++)begin
//        $display("packed_2d_arr[%0d] = %0b (%0d)",i,packed_2d_arr[i],packed_2d_arr[i]);
//    end
// end


 bit [2:0][3:0][7:0]packed_3d_arr;
 initial begin
    packed_3d_arr = 96'hffff_ffff_ffef_ffef_aaaa_aaaa_bbbb_bbbb;
//    packed_2d_arr = {8'd250,8'd200,8'd150,8'd100};
    $display("Size of packed_3d_arr = %0d",$size(packed_3d_arr));
    for(int i=0;i<$size(packed_3d_arr);i++)begin
        $display("packed_3d_arr[%0d] = %0b (%0d)",i,packed_3d_arr[i],packed_3d_arr[i]);
        for(int j=0;j<$size(packed_3d_arr[i]);j++)begin
            $display("packed_3d_arr[%0d][%0d] = %0b (%0d)",i,j,packed_3d_arr[i][j],packed_3d_arr[i][j]);
        end
    end
 end

endmodule
