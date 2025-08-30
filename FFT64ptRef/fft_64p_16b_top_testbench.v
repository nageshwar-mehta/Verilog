module fft_64p_16b_top_testbench;

  reg     [31:0] In_Stream;
  reg            Data_Start;
  reg            clk;
  reg            rst;
  wire           next_data;
  wire           Data_Out;
  wire    [31:0] Out_Stream;

  reg [31:0] rom [0:63];
  reg [31:0] ram [0:63];
  integer i;

  // Instantiate DUT
  fft_64p_16b_top dut (
    .In_Stream(In_Stream),
    .Mode(1'b0),
    .Data_Start(Data_Start),
    .clk(clk),
    .rst(rst),
    .next_data(next_data),
    .Out_Stream(Out_Stream),
    .Data_Out(Data_Out)
  );

  // Clock
  initial clk = 0;
  always #10 clk = ~clk; // 20ns period

  // Reset
  initial begin
    rst = 1;
    Data_Start = 0;
    In_Stream  = 0;
    #50;
    rst = 0;
  end

  // Load ROM
  initial begin
    $readmemh("C:\\Users\\nages\\verilog_projects\\MultiBandCR\\MultiBandCR.sim\\sim_1\\behav\\xsim\\timeseries.hex", rom);
    $display("ROM[0]=%h, ROM[1]=%h", rom[0], rom[1]);
  end

  // Feed input to DUT
  initial begin
    @(negedge rst); // wait for reset de-assert
    #20;
    for(i=0; i<64; i=i+1) begin
      @(posedge clk);
      In_Stream  <= rom[i];
      Data_Start <= 1;
      @(posedge clk);
      Data_Start <= 0; // pulse for one cycle
    end
  end

  // Capture Output
  integer j = 0;
  always @(posedge clk) begin
    if (Data_Out) begin
      ram[j] <= Out_Stream;
      j = j+1;
    end
  end

  // Write Output to File
  initial begin
    #50000; // wait sufficient time
    $writememh("C:\\Users\\nages\\verilog_projects\\MultiBandCR\\MultiBandCR.sim\\sim_1\\behav\\xsim\\freqseries.hex", ram);
    $finish;
  end

endmodule
