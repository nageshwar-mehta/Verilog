import numpy as np
import struct

# Parameters
num_samples = 64          # number of samples
timescale_ns = 1e-9       # 1 ns step (from `timescale 1ns/1ps`)
freq_hz = 15.625e6        # 1 cycle in 64 samples at 1ns step
amplitude = 1.0           # amplitude
outfile_hex = "input_data_real_hex.txt"
outfile_bin = "input_data_real_bin.txt"
outfile_float = "signal_samples_float.txt"

# Time axis (ns steps)
t = np.arange(0, num_samples) * timescale_ns

# Generate signal (example: sine wave)
signal = amplitude * np.sin(2 * np.pi * freq_hz * t)

# Open files
with open(outfile_hex, "w") as f_hex, \
     open(outfile_bin, "w") as f_bin, \
     open(outfile_float, "w") as f_float:
    
    for val in signal:
        # Pack float into IEEE-754 binary32
        packed = struct.pack('!f', val)   # network (= big endian)
        int_val = struct.unpack('!I', packed)[0]
        
        # Write hex (for Verilog $readmemh)
        f_hex.write(f"{int_val:08X}\n")
        
        # Write binary (32 bits)
        f_bin.write(f"{int_val:032b}\n")
        
        # Write decimal float
        f_float.write(f"{val:.6f}\n")

print(f"Saved {num_samples} samples to {outfile_hex}, {outfile_bin}, {outfile_float}")
