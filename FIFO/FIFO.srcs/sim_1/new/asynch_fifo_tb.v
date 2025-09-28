`timescale 1ns/1ps

module async_fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // DUT signals
    reg                  wr_clk, rd_clk;
    reg                  rst_n;
    reg                  wr_en, rd_en;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire                 fifo_full, fifo_empty;

    // DUT instantiation
    Asynchronous_FIFO #(DATA_WIDTH, ADDR_WIDTH) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // Clock generation (different frequencies)
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;    // 100 MHz (10 ns period)

    initial rd_clk = 0;
    always #8 rd_clk = ~rd_clk;    // 62.5 MHz (16 ns period)

    // Stimulus
    integer i;
    initial begin
        // Initialize
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // Release reset
        #20;
        rst_n = 1;

        // Write 10 values into FIFO
        @(posedge wr_clk);
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge wr_clk);
            if (!fifo_full) begin
                wr_en = 1;
                din   = i;
            end
            @(posedge wr_clk);
            wr_en = 0;
        end
        wr_en = 0;

        // Wait a little before reading
        #50;

        // Read values from FIFO
        @(posedge rd_clk);
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge rd_clk);
            if (!fifo_empty) begin
                rd_en = 1;
            end
            @(posedge rd_clk);
            rd_en = 0;
        end
        rd_en = 0;

        // Finish simulation
        #100;
        $finish;
    end

    // Monitor
    initial begin
        $monitor($time, " wr_en=%b rd_en=%b din=%d dout=%d full=%b empty=%b",
                  wr_en, rd_en, din, dout, fifo_full, fifo_empty);
    end

endmodule
