import numpy as np
import os

N = 64
scale = 2**15

# Example signals in [-1, 1)
s = np.random.uniform(-1, 1, N)   # time-domain signal s(n)
h = np.random.uniform(-1, 1, N)   # channel impulse response

# AWGN generation: mean=0, variance controlled by sigma
sigma = 0.05   # std dev of noise, ~5% of full scale
w = np.random.normal(0, sigma, N)

# Convert all to Q1.15 integers (signed 16-bit)
s_q15 = np.round(s * (scale-1)).astype(np.int16)
h_q15 = np.round(h * (scale-1)).astype(np.int16)
w_q15 = np.round(w * (scale-1)).astype(np.int16)

# --- Save path: directory where this script is located ---
script_dir = os.path.dirname(os.path.abspath(__file__))

def save_binary(filename, data):
    """Save int16 array as 16-bit binary strings for $readmemb."""
    with open(os.path.join(script_dir, filename), "w") as f:
        for val in data:
            # Convert to unsigned 16-bit, format as binary
            f.write("{:016b}\n".format(np.uint16(val)))

# Save binary Q1.15 files
save_binary("s_real.txt", s_q15)
save_binary("s_imag.txt", np.zeros(N, dtype=np.int16))
print("Signal s(n) samples saved in binary to", script_dir)

save_binary("h_real.txt", h_q15)
save_binary("h_imag.txt", np.zeros(N, dtype=np.int16))
print("Channel h(n) samples saved in binary to", script_dir)

save_binary("w_real.txt", w_q15)
save_binary("w_imag.txt", np.zeros(N, dtype=np.int16))
print("AWGN w(n) samples saved in binary to", script_dir)
