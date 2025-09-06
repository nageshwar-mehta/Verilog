import numpy as np

# Parameters
num_samples = 64         # number of samples
freq_hz = 15.625e6       # frequency (1 cycle in 64 samples)
q_format_bits = 16       # Q1.15 -> 16 bits
frac_bits = 15           # fractional bits

# Output files
outfile_real_bin = r"C:\Users\nages\verilog_projects\FFT64pt_fixed_point\input_data_real_q15.txt"
outfile_imag_bin = r"C:\Users\nages\verilog_projects\FFT64pt_fixed_point\input_data_imag_q15.txt"
outfile_float    = r"C:\Users\nages\verilog_projects\FFT64pt_fixed_point\signal_samples_float.txt"
# C:\Users\nages\verilog_projects\FFT64pt_fixed_point\generate_input.py

# Generate time axis (arbitrary units for one cycle)
t = np.arange(0, num_samples) / num_samples

# Generate signals
signal_real = np.sin(2 * np.pi * t)    # sine wave
signal_imag = np.zeros_like(signal_real)

# Scale signal by its max absolute value
max_val = np.max(np.abs(signal_real))
signal_real_scaled = signal_real / max_val
signal_imag_scaled = signal_imag / (np.max(np.abs(signal_imag)) if np.max(np.abs(signal_imag)) != 0 else 1)

# Convert to Q1.15
def float_to_q15(val):
    int_val = np.round(val * (2**frac_bits)).astype(int)
    # Convert negative numbers to 2's complement
    int_val = int_val & 0xFFFF
    return int_val

signal_real_q15 = float_to_q15(signal_real_scaled)
signal_imag_q15 = float_to_q15(signal_imag_scaled)

# Write files
with open(outfile_real_bin, "w") as f_real, \
     open(outfile_imag_bin, "w") as f_imag, \
     open(outfile_float, "w") as f_float:

    for r_val, i_val, r_float, i_float in zip(signal_real_q15, signal_imag_q15, signal_real, signal_imag):
        f_real.write(format(r_val, '016b') + "\n")
        f_imag.write(format(i_val, '016b') + "\n")
        f_float.write(f"{r_float:.6f}\t{i_float:.6f}\n")

print(f"Saved {num_samples} samples to {outfile_real_bin}, {outfile_imag_bin}, {outfile_float}")
