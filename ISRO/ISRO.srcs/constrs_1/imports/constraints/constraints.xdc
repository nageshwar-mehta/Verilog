# ============================================================
# Timing Constraints for Decimation Filter
# ============================================================

# Clock: 100 MHz (plenty of margin for 1.024 MHz sample rate)
create_clock -period 56.000 -name sys_clk [get_ports clk]

# Input delays (adjust based on your external interface)
set_input_delay -clock sys_clk -max 2.000 [get_ports {modulator_in[*]}]
set_input_delay -clock sys_clk -max 2.000 [get_ports modulator_valid]

# Output delays
set_output_delay -clock sys_clk -max 2.000 [get_ports {audio_out[*]}]
set_output_delay -clock sys_clk -max 2.000 [get_ports audio_valid]

# Debug outputs (optional, if present)
set_output_delay -clock sys_clk -max 2.000 [get_ports {cic_out[*]}]
set_output_delay -clock sys_clk -max 2.000 [get_ports cic_valid]
set_output_delay -clock sys_clk -max 2.000 [get_ports {fir1_out[*]}]
set_output_delay -clock sys_clk -max 2.000 [get_ports fir1_valid]

# Asynchronous reset (no timing requirements)
set_false_path -from [get_ports rst_n]

# ============================================================
# Optional: Pin constraints for specific FPGA board
# ============================================================
# Uncomment and modify for your board:
# set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
# set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports rst_n]