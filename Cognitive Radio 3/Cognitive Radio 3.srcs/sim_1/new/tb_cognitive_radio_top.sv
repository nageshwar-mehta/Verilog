`timescale 1ns / 1ps

module tb_cognitive_radio_top();

    // Parameters
    parameter WIDTH    = 16;
    parameter QF       = 9;
    parameter TW_WIDTH = 16;
    parameter CLK_PERIOD = 10; // 100 MHz clock

    // Testbench signals
    reg                      clk;
    reg                      rstn;
    reg                      in_valid;
    reg  signed [WIDTH-1:0]  sf_in_re;
    reg  signed [WIDTH-1:0]  sf_in_im;
    reg  signed [WIDTH-1:0]  hs1_in_re;
    reg  signed [WIDTH-1:0]  hs1_in_im;
    reg  signed [WIDTH-1:0]  w1_in_re;
    reg  signed [WIDTH-1:0]  w1_in_im;
    wire signed [WIDTH-1:0]  final_out_re;
    wire signed [WIDTH-1:0]  final_out_im;
    wire                     final_out_last;
    wire                     final_out_valid;

    // Output capture
    reg signed [WIDTH-1:0] output_data_re [0:63];
    reg signed [WIDTH-1:0] output_data_im [0:63];
    integer output_count;

    // Counter for input feeding
    integer i;

    // Instantiate DUT
    cognitive_radio_top #(
        .WIDTH(WIDTH),
        .QF(QF),
        .TW_WIDTH(TW_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .sf_in_re(sf_in_re),
        .sf_in_im(sf_in_im),
        .hs1_in_re(hs1_in_re),
        .hs1_in_im(hs1_in_im),
        .w1_in_re(w1_in_re),
        .w1_in_im(w1_in_im),
        .final_out_re(final_out_re),
        .final_out_im(final_out_im),
        .final_out_last(final_out_last),
        .final_out_valid(final_out_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Function to convert real to Q7.9 fixed point
    function signed [WIDTH-1:0] real_to_fixed;
        input real value;
        begin
            real_to_fixed = $rtoi(value * (2.0 ** QF));
        end
    endfunction

    // Function to convert Q7.9 fixed point to real
    function real fixed_to_real;
        input signed [WIDTH-1:0] value;
        begin
            fixed_to_real = $itor(value) / (2.0 ** QF);
        end
    endfunction

    // Task to feed input data (fixed test vectors)
    task feed_inputs;
        begin
            $display("Starting to feed inputs at time %0t", $time);
            in_valid = 1;
            
            // Sample 0
            sf_in_re = 16'sh0A00; sf_in_im = 16'sh0200;
            hs1_in_re = 16'sh0C00; hs1_in_im = 16'sh0300;
            w1_in_re = 16'sh0800; w1_in_im = 16'sh0100;
            @(posedge clk);
            
            // Sample 1
            sf_in_re = 16'sh0980; sf_in_im = 16'sh0280;
            hs1_in_re = 16'sh0B80; hs1_in_im = 16'sh0380;
            w1_in_re = 16'sh0780; w1_in_im = 16'sh0180;
            @(posedge clk);
            
            // Sample 2
            sf_in_re = 16'sh0900; sf_in_im = 16'sh0300;
            hs1_in_re = 16'sh0B00; hs1_in_im = 16'sh0400;
            w1_in_re = 16'sh0700; w1_in_im = 16'sh0200;
            @(posedge clk);
            
            // Sample 3
            sf_in_re = 16'sh0880; sf_in_im = 16'sh0380;
            hs1_in_re = 16'sh0A80; hs1_in_im = 16'sh0480;
            w1_in_re = 16'sh0680; w1_in_im = 16'sh0280;
            @(posedge clk);
            
            // Sample 4
            sf_in_re = 16'sh0800; sf_in_im = 16'sh0400;
            hs1_in_re = 16'sh0A00; hs1_in_im = 16'sh0500;
            w1_in_re = 16'sh0600; w1_in_im = 16'sh0300;
            @(posedge clk);
            
            // Sample 5
            sf_in_re = 16'sh0780; sf_in_im = 16'sh0480;
            hs1_in_re = 16'sh0980; hs1_in_im = 16'sh0580;
            w1_in_re = 16'sh0580; w1_in_im = 16'sh0380;
            @(posedge clk);
            
            // Sample 6
            sf_in_re = 16'sh0700; sf_in_im = 16'sh0500;
            hs1_in_re = 16'sh0900; hs1_in_im = 16'sh0600;
            w1_in_re = 16'sh0500; w1_in_im = 16'sh0400;
            @(posedge clk);
            
            // Sample 7
            sf_in_re = 16'sh0680; sf_in_im = 16'sh0580;
            hs1_in_re = 16'sh0880; hs1_in_im = 16'sh0680;
            w1_in_re = 16'sh0480; w1_in_im = 16'sh0480;
            @(posedge clk);
            
            // Sample 8
            sf_in_re = 16'sh0600; sf_in_im = 16'sh0600;
            hs1_in_re = 16'sh0800; hs1_in_im = 16'sh0700;
            w1_in_re = 16'sh0400; w1_in_im = 16'sh0500;
            @(posedge clk);
            
            // Sample 9
            sf_in_re = 16'sh0580; sf_in_im = 16'sh0680;
            hs1_in_re = 16'sh0780; hs1_in_im = 16'sh0780;
            w1_in_re = 16'sh0380; w1_in_im = 16'sh0580;
            @(posedge clk);
            
            // Sample 10
            sf_in_re = 16'sh0500; sf_in_im = 16'sh0700;
            hs1_in_re = 16'sh0700; hs1_in_im = 16'sh0800;
            w1_in_re = 16'sh0300; w1_in_im = 16'sh0600;
            @(posedge clk);
            
            // Sample 11
            sf_in_re = 16'sh0480; sf_in_im = 16'sh0780;
            hs1_in_re = 16'sh0680; hs1_in_im = 16'sh0880;
            w1_in_re = 16'sh0280; w1_in_im = 16'sh0680;
            @(posedge clk);
            
            // Sample 12
            sf_in_re = 16'sh0400; sf_in_im = 16'sh0800;
            hs1_in_re = 16'sh0600; hs1_in_im = 16'sh0900;
            w1_in_re = 16'sh0200; w1_in_im = 16'sh0700;
            @(posedge clk);
            
            // Sample 13
            sf_in_re = 16'sh0380; sf_in_im = 16'sh0880;
            hs1_in_re = 16'sh0580; hs1_in_im = 16'sh0980;
            w1_in_re = 16'sh0180; w1_in_im = 16'sh0780;
            @(posedge clk);
            
            // Sample 14
            sf_in_re = 16'sh0300; sf_in_im = 16'sh0900;
            hs1_in_re = 16'sh0500; hs1_in_im = 16'sh0A00;
            w1_in_re = 16'sh0100; w1_in_im = 16'sh0800;
            @(posedge clk);
            
            // Sample 15
            sf_in_re = 16'sh0280; sf_in_im = 16'sh0980;
            hs1_in_re = 16'sh0480; hs1_in_im = 16'sh0A80;
            w1_in_re = 16'sh0080; w1_in_im = 16'sh0880;
            @(posedge clk);
            
            // Sample 16
            sf_in_re = 16'sh0200; sf_in_im = 16'sh0A00;
            hs1_in_re = 16'sh0400; hs1_in_im = 16'sh0B00;
            w1_in_re = 16'sh0000; w1_in_im = 16'sh0900;
            @(posedge clk);
            
            // Sample 17
            sf_in_re = 16'sh0180; sf_in_im = 16'sh0A80;
            hs1_in_re = 16'sh0380; hs1_in_im = 16'sh0B80;
            w1_in_re = 16'shFF80; w1_in_im = 16'sh0980;
            @(posedge clk);
            
            // Sample 18
            sf_in_re = 16'sh0100; sf_in_im = 16'sh0B00;
            hs1_in_re = 16'sh0300; hs1_in_im = 16'sh0C00;
            w1_in_re = 16'shFF00; w1_in_im = 16'sh0A00;
            @(posedge clk);
            
            // Sample 19
            sf_in_re = 16'sh0080; sf_in_im = 16'sh0B80;
            hs1_in_re = 16'sh0280; hs1_in_im = 16'sh0C80;
            w1_in_re = 16'shFE80; w1_in_im = 16'sh0A80;
            @(posedge clk);
            
            // Sample 20
            sf_in_re = 16'sh0000; sf_in_im = 16'sh0C00;
            hs1_in_re = 16'sh0200; hs1_in_im = 16'sh0D00;
            w1_in_re = 16'shFE00; w1_in_im = 16'sh0B00;
            @(posedge clk);
            
            // Sample 21
            sf_in_re = 16'shFF80; sf_in_im = 16'sh0C80;
            hs1_in_re = 16'sh0180; hs1_in_im = 16'sh0D80;
            w1_in_re = 16'shFD80; w1_in_im = 16'sh0B80;
            @(posedge clk);
            
            // Sample 22
            sf_in_re = 16'shFF00; sf_in_im = 16'sh0D00;
            hs1_in_re = 16'sh0100; hs1_in_im = 16'sh0E00;
            w1_in_re = 16'shFD00; w1_in_im = 16'sh0C00;
            @(posedge clk);
            
            // Sample 23
            sf_in_re = 16'shFE80; sf_in_im = 16'sh0D80;
            hs1_in_re = 16'sh0080; hs1_in_im = 16'sh0E80;
            w1_in_re = 16'shFC80; w1_in_im = 16'sh0C80;
            @(posedge clk);
            
            // Sample 24
            sf_in_re = 16'shFE00; sf_in_im = 16'sh0E00;
            hs1_in_re = 16'sh0000; hs1_in_im = 16'sh0F00;
            w1_in_re = 16'shFC00; w1_in_im = 16'sh0D00;
            @(posedge clk);
            
            // Sample 25
            sf_in_re = 16'shFD80; sf_in_im = 16'sh0E80;
            hs1_in_re = 16'shFF80; hs1_in_im = 16'sh0F80;
            w1_in_re = 16'shFB80; w1_in_im = 16'sh0D80;
            @(posedge clk);
            
            // Sample 26
            sf_in_re = 16'shFD00; sf_in_im = 16'sh0F00;
            hs1_in_re = 16'shFF00; hs1_in_im = 16'sh1000;
            w1_in_re = 16'shFB00; w1_in_im = 16'sh0E00;
            @(posedge clk);
            
            // Sample 27
            sf_in_re = 16'shFC80; sf_in_im = 16'sh0F80;
            hs1_in_re = 16'shFE80; hs1_in_im = 16'sh1080;
            w1_in_re = 16'shFA80; w1_in_im = 16'sh0E80;
            @(posedge clk);
            
            // Sample 28
            sf_in_re = 16'shFC00; sf_in_im = 16'sh1000;
            hs1_in_re = 16'shFE00; hs1_in_im = 16'sh1100;
            w1_in_re = 16'shFA00; w1_in_im = 16'sh0F00;
            @(posedge clk);
            
            // Sample 29
            sf_in_re = 16'shFB80; sf_in_im = 16'sh1080;
            hs1_in_re = 16'shFD80; hs1_in_im = 16'sh1180;
            w1_in_re = 16'shF980; w1_in_im = 16'sh0F80;
            @(posedge clk);
            
            // Sample 30
            sf_in_re = 16'shFB00; sf_in_im = 16'sh1100;
            hs1_in_re = 16'shFD00; hs1_in_im = 16'sh1200;
            w1_in_re = 16'shF900; w1_in_im = 16'sh1000;
            @(posedge clk);
            
            // Sample 31
            sf_in_re = 16'shFA80; sf_in_im = 16'sh1180;
            hs1_in_re = 16'shFC80; hs1_in_im = 16'sh1280;
            w1_in_re = 16'shF880; w1_in_im = 16'sh1080;
            @(posedge clk);
            
            // Sample 32
            sf_in_re = 16'shFA00; sf_in_im = 16'sh1200;
            hs1_in_re = 16'shFC00; hs1_in_im = 16'sh1300;
            w1_in_re = 16'shF800; w1_in_im = 16'sh1100;
            @(posedge clk);
            
            // Sample 33
            sf_in_re = 16'shF980; sf_in_im = 16'sh1180;
            hs1_in_re = 16'shFB80; hs1_in_im = 16'sh1280;
            w1_in_re = 16'shF780; w1_in_im = 16'sh1080;
            @(posedge clk);
            
            // Sample 34
            sf_in_re = 16'shF900; sf_in_im = 16'sh1100;
            hs1_in_re = 16'shFB00; hs1_in_im = 16'sh1200;
            w1_in_re = 16'shF700; w1_in_im = 16'sh1000;
            @(posedge clk);
            
            // Sample 35
            sf_in_re = 16'shF880; sf_in_im = 16'sh1080;
            hs1_in_re = 16'shFA80; hs1_in_im = 16'sh1180;
            w1_in_re = 16'shF680; w1_in_im = 16'sh0F80;
            @(posedge clk);
            
            // Sample 36
            sf_in_re = 16'shF800; sf_in_im = 16'sh1000;
            hs1_in_re = 16'shFA00; hs1_in_im = 16'sh1100;
            w1_in_re = 16'shF600; w1_in_im = 16'sh0F00;
            @(posedge clk);
            
            // Sample 37
            sf_in_re = 16'shF780; sf_in_im = 16'sh0F80;
            hs1_in_re = 16'shF980; hs1_in_im = 16'sh1080;
            w1_in_re = 16'shF580; w1_in_im = 16'sh0E80;
            @(posedge clk);
            
            // Sample 38
            sf_in_re = 16'shF700; sf_in_im = 16'sh0F00;
            hs1_in_re = 16'shF900; hs1_in_im = 16'sh1000;
            w1_in_re = 16'shF500; w1_in_im = 16'sh0E00;
            @(posedge clk);
            
            // Sample 39
            sf_in_re = 16'shF680; sf_in_im = 16'sh0E80;
            hs1_in_re = 16'shF880; hs1_in_im = 16'sh0F80;
            w1_in_re = 16'shF480; w1_in_im = 16'sh0D80;
            @(posedge clk);
            
            // Sample 40
            sf_in_re = 16'shF600; sf_in_im = 16'sh0E00;
            hs1_in_re = 16'shF800; hs1_in_im = 16'sh0F00;
            w1_in_re = 16'shF400; w1_in_im = 16'sh0D00;
            @(posedge clk);
            
            // Sample 41
            sf_in_re = 16'shF580; sf_in_im = 16'sh0D80;
            hs1_in_re = 16'shF780; hs1_in_im = 16'sh0E80;
            w1_in_re = 16'shF380; w1_in_im = 16'sh0C80;
            @(posedge clk);
            
            // Sample 42
            sf_in_re = 16'shF500; sf_in_im = 16'sh0D00;
            hs1_in_re = 16'shF700; hs1_in_im = 16'sh0E00;
            w1_in_re = 16'shF300; w1_in_im = 16'sh0C00;
            @(posedge clk);
            
            // Sample 43
            sf_in_re = 16'shF480; sf_in_im = 16'sh0C80;
            hs1_in_re = 16'shF680; hs1_in_im = 16'sh0D80;
            w1_in_re = 16'shF280; w1_in_im = 16'sh0B80;
            @(posedge clk);
            
            // Sample 44
            sf_in_re = 16'shF400; sf_in_im = 16'sh0C00;
            hs1_in_re = 16'shF600; hs1_in_im = 16'sh0D00;
            w1_in_re = 16'shF200; w1_in_im = 16'sh0B00;
            @(posedge clk);
            
            // Sample 45
            sf_in_re = 16'shF380; sf_in_im = 16'sh0B80;
            hs1_in_re = 16'shF580; hs1_in_im = 16'sh0C80;
            w1_in_re = 16'shF180; w1_in_im = 16'sh0A80;
            @(posedge clk);
            
            // Sample 46
            sf_in_re = 16'shF300; sf_in_im = 16'sh0B00;
            hs1_in_re = 16'shF500; hs1_in_im = 16'sh0C00;
            w1_in_re = 16'shF100; w1_in_im = 16'sh0A00;
            @(posedge clk);
            
            // Sample 47
            sf_in_re = 16'shF280; sf_in_im = 16'sh0A80;
            hs1_in_re = 16'shF480; hs1_in_im = 16'sh0B80;
            w1_in_re = 16'shF080; w1_in_im = 16'sh0980;
            @(posedge clk);
            
            // Sample 48
            sf_in_re = 16'shF200; sf_in_im = 16'sh0A00;
            hs1_in_re = 16'shF400; hs1_in_im = 16'sh0B00;
            w1_in_re = 16'shF000; w1_in_im = 16'sh0900;
            @(posedge clk);
            
            // Sample 49
            sf_in_re = 16'shF180; sf_in_im = 16'sh0980;
            hs1_in_re = 16'shF380; hs1_in_im = 16'sh0A80;
            w1_in_re = 16'shEF80; w1_in_im = 16'sh0880;
            @(posedge clk);
            
            // Sample 50
            sf_in_re = 16'shF100; sf_in_im = 16'sh0900;
            hs1_in_re = 16'shF300; hs1_in_im = 16'sh0A00;
            w1_in_re = 16'shEF00; w1_in_im = 16'sh0800;
            @(posedge clk);
            
            // Sample 51
            sf_in_re = 16'shF080; sf_in_im = 16'sh0880;
            hs1_in_re = 16'shF280; hs1_in_im = 16'sh0980;
            w1_in_re = 16'shEE80; w1_in_im = 16'sh0780;
            @(posedge clk);
            
            // Sample 52
            sf_in_re = 16'shF000; sf_in_im = 16'sh0800;
            hs1_in_re = 16'shF200; hs1_in_im = 16'sh0900;
            w1_in_re = 16'shEE00; w1_in_im = 16'sh0700;
            @(posedge clk);
            
            // Sample 53
            sf_in_re = 16'shEF80; sf_in_im = 16'sh0780;
            hs1_in_re = 16'shF180; hs1_in_im = 16'sh0880;
            w1_in_re = 16'shED80; w1_in_im = 16'sh0680;
            @(posedge clk);
            
            // Sample 54
            sf_in_re = 16'shEF00; sf_in_im = 16'sh0700;
            hs1_in_re = 16'shF100; hs1_in_im = 16'sh0800;
            w1_in_re = 16'shED00; w1_in_im = 16'sh0600;
            @(posedge clk);
            
            // Sample 55
            sf_in_re = 16'shEE80; sf_in_im = 16'sh0680;
            hs1_in_re = 16'shF080; hs1_in_im = 16'sh0780;
            w1_in_re = 16'shEC80; w1_in_im = 16'sh0580;
            @(posedge clk);
            
            // Sample 56
            sf_in_re = 16'shEE00; sf_in_im = 16'sh0600;
            hs1_in_re = 16'shF000; hs1_in_im = 16'sh0700;
            w1_in_re = 16'shEC00; w1_in_im = 16'sh0500;
            @(posedge clk);
            
            // Sample 57
            sf_in_re = 16'shED80; sf_in_im = 16'sh0580;
            hs1_in_re = 16'shEF80; hs1_in_im = 16'sh0680;
            w1_in_re = 16'shEB80; w1_in_im = 16'sh0480;
            @(posedge clk);
            
            // Sample 58
            sf_in_re = 16'shED00; sf_in_im = 16'sh0500;
            hs1_in_re = 16'shEF00; hs1_in_im = 16'sh0600;
            w1_in_re = 16'shEB00; w1_in_im = 16'sh0400;
            @(posedge clk);
            
            // Sample 59
            sf_in_re = 16'shEC80; sf_in_im = 16'sh0480;
            hs1_in_re = 16'shEE80; hs1_in_im = 16'sh0580;
            w1_in_re = 16'shEA80; w1_in_im = 16'sh0380;
            @(posedge clk);
            
            // Sample 60
            sf_in_re = 16'shEC00; sf_in_im = 16'sh0400;
            hs1_in_re = 16'shEE00; hs1_in_im = 16'sh0500;
            w1_in_re = 16'shEA00; w1_in_im = 16'sh0300;
            @(posedge clk);
            
            // Sample 61
            sf_in_re = 16'shEB80; sf_in_im = 16'sh0380;
            hs1_in_re = 16'shED80; hs1_in_im = 16'sh0480;
            w1_in_re = 16'shE980; w1_in_im = 16'sh0280;
            @(posedge clk);
            
            // Sample 62
            sf_in_re = 16'shEB00; sf_in_im = 16'sh0300;
            hs1_in_re = 16'shED00; hs1_in_im = 16'sh0400;
            w1_in_re = 16'shE900; w1_in_im = 16'sh0200;
            @(posedge clk);
            
            // Sample 63 (last)
            sf_in_re = 16'shEA80; sf_in_im = 16'sh0280;
            hs1_in_re = 16'shEC80; hs1_in_im = 16'sh0380;
            w1_in_re = 16'shE880; w1_in_im = 16'sh0180;
            @(posedge clk);
            
            in_valid = 0;
            sf_in_re = 0;
            sf_in_im = 0;
            hs1_in_re = 0;
            hs1_in_im = 0;
            w1_in_re = 0;
            w1_in_im = 0;
            
            $display("Input feeding completed at time %0t", $time);
        end
    endtask

    // Capture outputs
    always @(posedge clk) begin
        if (final_out_valid) begin
            output_data_re[output_count] = final_out_re;
            output_data_im[output_count] = final_out_im;
            
            $display("Output[%0d]: Re = %f (0x%h), Im = %f (0x%h)", 
                     output_count,
                     fixed_to_real(final_out_re), final_out_re,
                     fixed_to_real(final_out_im), final_out_im);
            
            output_count = output_count + 1;
            
            if (final_out_last) begin
                $display("Last output received at time %0t, total outputs: %0d", 
                         $time, output_count);
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize signals
        rstn = 0;
        in_valid = 0;
        sf_in_re = 0;
        sf_in_im = 0;
        hs1_in_re = 0;
        hs1_in_im = 0;
        w1_in_re = 0;
        w1_in_im = 0;
        output_count = 0;

        // Create waveform dump
        $dumpfile("cognitive_radio_top.vcd");
        $dumpvars(0, tb_cognitive_radio_top);

        // Display header
        $display("\n========================================");
        $display("Cognitive Radio Testbench - Fixed Inputs");
        $display("========================================\n");
        $display("Test vectors: 64 fixed-point samples");
        $display("Format: Q7.9 (16-bit signed)");
        $display("========================================\n");
        
        // Reset sequence
        #(CLK_PERIOD * 5);
        rstn = 1;
        $display("Reset released at time %0t", $time);
        
        #(CLK_PERIOD * 5);

        // Feed test data
        feed_inputs();

        // Wait for processing to complete
        $display("\nWaiting for processing to complete...");
        $display("Note: Division takes ~20 cycles per sample");
        wait(final_out_last);
        #(CLK_PERIOD * 10);

        // Display summary
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total outputs received: %0d", output_count);
        $display("Test completed at time %0t ns", $time);
        $display("========================================\n");

        // Verify output count
        if (output_count == 64) begin
            $display("PASS: Received expected 64 outputs");
        end else begin
            $display("FAIL: Expected 64 outputs, got %0d", output_count);
        end

        // Display some sample outputs
        $display("\nSample output values (first 5):");
        for (i = 0; i < 5; i = i + 1) begin
            $display("  Out[%0d]: Re=%f, Im=%f", 
                     i, 
                     fixed_to_real(output_data_re[i]),
                     fixed_to_real(output_data_im[i]));
        end

        // Additional cycles for observation
        #(CLK_PERIOD * 20);

        $display("\nSimulation finished successfully!");
        $finish;
    end

    // Timeout watchdog - increased for complex divider
    initial begin
        #(CLK_PERIOD * 200000); // Timeout after 200000 clock cycles
        $display("\nERROR: Simulation timeout!");
        $display("Processing took too long, possible deadlock");
        $display("Current state: %0d", dut.state);
        $display("Output count: %0d", output_count);
        $finish;
    end

    // Monitor state changes in DUT
    initial begin
        $display("\nTime\t\tState\tin_valid\tout_valid\tout_last");
        $display("----\t\t-----\t--------\t---------\t--------");
    end
    
    always @(posedge clk) begin
        if (dut.state != 0 || final_out_valid || final_out_last) begin
            $display("%0t\t%0d\t%b\t\t%b\t\t%b", 
                     $time, dut.state, in_valid, final_out_valid, final_out_last);
        end
    end

endmodule