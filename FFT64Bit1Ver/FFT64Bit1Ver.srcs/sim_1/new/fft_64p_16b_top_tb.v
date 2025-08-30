`timescale 1ns / 1ps

module fft_64p_16b_top_tb;

  // Clock and Reset
  reg clk;
  reg rst;

  // DUT I/O
  reg         Mode;
  reg         Data_Start;
  reg  [31:0] In_Stream;
  wire        next_data;
  wire        Data_Out;
  wire [31:0] Out_Stream;

  // File handling
  integer infile, outfile, status;
  reg [31:0] input_mem [0:63];
  integer i;

  // Instantiate DUT
  fft_64p_16b_top uut (
    .clk(clk),
    .rst(rst),
    .Mode(Mode),
    .Data_Start(Data_Start),
    .In_Stream(In_Stream),
    .next_data(next_data),
    .Data_Out(Data_Out),
    .Out_Stream(Out_Stream)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    // Initialize
    clk = 0;
    rst = 1;
    Mode = 0;  // FFT mode
    Data_Start = 0;
    In_Stream = 0;

    // Apply reset
    #20 rst = 0;
    #20 rst = 1;

    // Read input from hex file
    $readmemh("input.hex", input_mem);

    // Open output file
    outfile = $fopen("output.hex", "w");
    if (outfile == 0) begin
      $display("ERROR: Could not open output.hex");
      $finish;
    end

    // Feed inputs
    for (i = 0; i < 64; i = i + 1) begin
      @(posedge clk);
      Data_Start <= 1;
      In_Stream <= input_mem[i];
      @(posedge clk);
      Data_Start <= 0;

      // Wait for DUT to consume data
      wait (next_data == 1);
    end

    // Wait for outputs
    for (i = 0; i < 64; i = i + 1) begin
      @(posedge clk);
      if (Data_Out) begin
        $fwrite(outfile, "%h\n", Out_Stream);
      end
    end

    $fclose(outfile);
    $display("Simulation completed. Output written to output.hex");
    #50 $finish;
  end

endmodule
