import numpy as np
import struct

# Parameters
num_samples = 64          # number of samples
timescale_ns = 1e-9       # 1 ns step
freq_hz = 15.625e6        # 1 cycle in 64 samples at 1ns step
amplitude = 1.0           # amplitude

# Output files
outfile_real_bin = "input_data_real_bin.txt"
outfile_imag_bin = "input_data_imag_bin.txt"
outfile_float    = "signal_samples_float.txt"

# Time axis
t = np.arange(0, num_samples) * timescale_ns

# Generate signals
signal_real = amplitude * np.sin(2 * np.pi * freq_hz * t)
signal_imag = np.zeros_like(signal_real)

# Write files
with open(outfile_real_bin, "w") as f_real_bin, \
     open(outfile_imag_bin, "w") as f_imag_bin, \
     open(outfile_float, "w") as f_float:

    for real_val, imag_val in zip(signal_real, signal_imag):
        # ---- REAL ----
        packed_real = struct.pack('!f', real_val)
        int_real = struct.unpack('!I', packed_real)[0]
        bin_real = format(int_real, '032b')  # always 32 bits
        f_real_bin.write(bin_real + "\n")

        # ---- IMAG ----
        packed_imag = struct.pack('!f', imag_val)
        int_imag = struct.unpack('!I', packed_imag)[0]
        bin_imag = format(int_imag, '032b')  # always 32 bits
        f_imag_bin.write(bin_imag + "\n")


        # ---- Human readable ----
        f_float.write(f"{real_val:.6f}\t{imag_val:.6f}\n")

print(f"Saved {num_samples} samples to {outfile_real_bin}, {outfile_imag_bin}, {outfile_float}")
