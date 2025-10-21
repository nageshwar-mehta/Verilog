//// tb_complex_divide.v
//`timescale 1ns/1ps
//module tb_complex_divide;
//    parameter WL = 32;
//    parameter FL = 16;

//    reg clk = 0;
//    always #5 clk = ~clk; // 100 MHz sim tick

//    reg rstn = 0;
//    initial begin
//        #12 rstn = 1;
//    end

//    reg validIn = 0;
//    reg signed [WL-1:0] num_re;
//    reg signed [WL-1:0] num_im;
//    reg signed [WL-1:0] den_re;
//    reg signed [WL-1:0] den_im;
//    wire signed [WL-1:0] out_re;
//    wire signed [WL-1:0] out_im;
//    wire dbz;
//    wire validOut;

//    complex_divide_cordic #(.WL(WL), .FL(FL), .CORDIC_ITERS(30)) U (
//        .clk(clk), .rstn(rstn), .validIn(validIn),
//        .num_re(num_re), .num_im(num_im), .den_re(den_re), .den_im(den_im),
//        .out_re(out_re), .out_im(out_im), .dbz(dbz), .validOut(validOut)
//    );

//    // helper to convert real double -> fixed QFL
//    function signed [WL-1:0] toQ;
//        input real v;
//        integer i;
//        real scaled;
//        begin
//            scaled = v * (2.0 ** FL);
//            toQ = $rtoi(scaled);
//        end
//    endfunction

//    // Display outputs in real form
//    function real fromQ;
//        input signed [WL-1:0] qv;
//        begin
//            fromQ = $itor($signed(qv)) / (2.0 ** FL);
//        end
//    endfunction

//    integer step;
//    initial begin
//        // wait reset
//        @(posedge rstn);
//        #2;

//        // set some test vectors (complex numbers)
//        real a_re = 3.25, a_im = -1.5;
//        real b_re = 1.125, b_im = 0.5;

//        num_re = toQ(a_re);
//        num_im = toQ(a_im);
//        den_re = toQ(b_re);
//        den_im = toQ(b_im);

//        validIn = 1;
//        @(posedge clk);
//        validIn = 0;

//        // wait for validOut
//        wait(validOut == 1);
//        $display("Result fixed out_re=%d out_im=%d", out_re, out_im);
//        $display("Result real     out_re=%f out_im=%f", fromQ(out_re), fromQ(out_im));
//        $display("Matlab expect   %f + j%f", a_re/b_re, a_im/b_re); // rough (not correct for complex); user must compute complex division in testbench if needed
//        #100;
//        $finish;
//    end
//endmodule
