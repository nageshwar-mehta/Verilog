module tb_div();
    parameter N = 16, Q = 8;
    reg [N-1:0] a,b;
    reg start, clk, rst;
    wire [N-1:0] q;
    wire done, ovf;

    Fixed_Point_DividerR1 #(.Q(Q), .N(N)) uut (
        .i_dividend(a),
        .i_divisor(b),
        .i_start(start),
        .i_clk(clk),
        .div_rst(rst),
        .o_quotient_out(q),
        .o_complete(done),
        .o_overflow(ovf)
    );

    initial clk = 0; always #5 clk = ~clk;
    initial begin
        rst = 1; start = 0; #20;
        rst = 0;
        // example: 1.5 / 0.5  (with Q=8 => 1.5 = 1.5*256 = 384 -> binary)
        a = 16'sd384; // 1.5
        b = 16'sd128; // 0.5
        #10 start = 1; #10 start = 0;
        wait (done == 1);
        $display("quotient = %d ovf=%b", q, ovf); // expect ~3.0 => 3.0 *256 = 768 ~ 0x300
        #100 $finish;
    end
endmodule
