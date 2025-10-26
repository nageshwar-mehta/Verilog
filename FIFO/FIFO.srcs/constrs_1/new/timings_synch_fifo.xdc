create_clock -period 4.000 -name clk -waveform {0.000 2.000} [get_ports clk]

create_clock -period 10.000 -name rd_clk -waveform {0.000 5.000} [get_ports rd_clk]
create_clock -period 6.667 -name wr_clk [get_ports wr_clk]
