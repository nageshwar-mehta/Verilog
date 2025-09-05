import struct
import numpy as np

# ---- Helpers ----
def bin_to_float(bin_str):
    """Convert 32-bit binary string to IEEE-754 float."""
    return struct.unpack('!f', int(bin_str, 2).to_bytes(4, byteorder='big'))[0]

def read_bin_file(filename):
    """Read binary strings and convert to float array."""
    vals = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                vals.append(bin_to_float(line))
    return np.array(vals, dtype=np.float32)

# ---- File paths ----
fft_real_file = r"C:\Users\nages\verilog_projects\FFT-IP\FFT-IP.sim\sim_1\behav\xsim\fft_out_real.txt"
fft_imag_file = r"C:\Users\nages\verilog_projects\FFT-IP\FFT-IP.sim\sim_1\behav\xsim\fft_out_imag.txt"

input_real_file = r"C:\Users\nages\verilog_projects\input_data_real_bin.txt"
input_imag_file = r"C:\Users\nages\verilog_projects\input_data_imag_bin.txt"

# ---- Load inputs ----
real_in = read_bin_file(input_real_file)
imag_in = read_bin_file(input_imag_file)
complex_in = real_in + 1j * imag_in

# ---- NumPy FFT reference ----
ref_fft = np.fft.fft(complex_in)

# ---- Load FFT IP outputs ----
real_out = read_bin_file(fft_real_file)
imag_out = read_bin_file(fft_imag_file)
hw_fft = real_out + 1j * imag_out

# ---- Compare ----
abs_diff = np.abs(ref_fft - hw_fft)
rel_err = abs_diff / (np.abs(ref_fft) + 1e-12)

for i, (ref, hw, ad, re) in enumerate(zip(ref_fft, hw_fft, abs_diff, rel_err)):
    print(f"Bin {i:02d}: REF={ref:.6f}, HW={hw:.6f}, |Δ|={ad:.3e}, RelErr={re:.3e}")

print("\nMax abs error:", np.max(abs_diff))
print("Max relative error:", np.max(rel_err))
