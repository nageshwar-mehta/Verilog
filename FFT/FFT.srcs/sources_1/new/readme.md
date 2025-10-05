

## 🧠 `README.md` — **Hierarchical Radix-2 FFT System (Verilog)**

```markdown
# ⚡ Hierarchical Radix-2 FFT System (Verilog HDL)

A complete **Fixed-Point FFT Architecture** built using the **Cooley–Tukey Divide-and-Conquer Algorithm**.  
Implements FFT sizes from **2-point to 64-point**, using a scalable, synthesizable, and modular **Radix-2 DIT (Decimation-In-Time)** approach.

---

## 🏗️ Project Overview

This project implements a **family of FFT modules** in Verilog HDL — starting from the basic butterfly unit up to a complete 64-point FFT processor.

Each module follows a **hierarchical design pattern**, allowing larger FFTs to be constructed from smaller verified submodules, maintaining both **scalability** and **hardware efficiency**.

| FFT Size | Module Name | Type | Algorithm | Description |
|:---------:|:-------------|:------|:------------|:--------------|
| 2-point | `FFT2pt.v` | Core | Radix-2 DIT | Basic butterfly computation — the foundation of all higher FFTs |
| 4-point | `FFT4pt.v` | Engine | Cooley–Tukey DIT | Two 2-pt FFTs + twiddle combination stage |
| 8-point | `FFT8pt.v` | Engine | Cooley–Tukey DIT | Two 4-pt FFTs + Q-format scaling pipeline |
| 16-point | `FFT16pt.v` | Engine | Cooley–Tukey DIT | Two 8-pt FFTs + Q2.14 twiddle ROM |
| 32-point | `FFT32pt.v` | Engine | Cooley–Tukey DIT | Two 16-pt FFTs + hierarchical recursion |
| 64-point | `FFT64point.v` | Processor | Cooley–Tukey DIT | Final FFT processor with complete I/O wrapper |

---

## 🔬 Algorithm Used — *Cooley–Tukey Radix-2 DIT FFT*

The **Cooley–Tukey FFT algorithm** efficiently computes the Discrete Fourier Transform (DFT) by recursively breaking it into smaller DFTs:

\[
X[k] = E[k] + W_N^k O[k]
\]
\[
X[k + N/2] = E[k] - W_N^k O[k]
\]

Where:
- \(E[k]\): FFT of even-indexed samples  
- \(O[k]\): FFT of odd-indexed samples  
- \(W_N^k = e^{-j2\pi k/N}\): Twiddle factor (complex rotation term)

This design uses **Decimation-In-Time (DIT)** form of FFT, where the decomposition occurs on **input indices** (even/odd split).

---

## ⚙️ Architecture Hierarchy

Below is the structural hierarchy illustrating how smaller FFT blocks combine into higher-order FFTs:

```

FFT64pt Processor
├── FFT32pt Engine (x2)
│     ├── FFT16pt Engine (x2)
│     │     ├── FFT8pt Engine (x2)
│     │     │     ├── FFT4pt Engine (x2)
│     │     │     │     └── FFT2pt Core (x2)

````

Each stage doubles the FFT size, applying appropriate twiddle multiplication and Q-format normalization.

---

## 🧮 Fixed-Point Implementation

All FFT modules use **fixed-point arithmetic** with parameterized precision.

| Parameter | Description | Typical Value |
|------------|--------------|----------------|
| `WIDTH` | Total word length of input/output | 16 bits |
| `QF` | Fractional bits in Q-format | 9 |
| `TW_WIDTH` | Twiddle ROM precision (Q2.14) | 16 bits |

Twiddle factors are stored in **ROM tables** with **Q2.14 precision**, ensuring numerical accuracy and efficient hardware mapping.

Example (Q2.14 Twiddle ROM Snippet):

```verilog
function signed [15:0] W16_COS(input [2:0] idx);
  case (idx)
    3'd0: W16_COS = 16'sd16384;   // cos(0)
    3'd1: W16_COS = 16'sd15137;   // cos(pi/8)
    3'd2: W16_COS = 16'sd11585;   // cos(pi/4)
    3'd3: W16_COS = 16'sd6269;    // cos(3pi/8)
    3'd4: W16_COS = 16'sd0;       // cos(pi/2)
  endcase
endfunction
````

---

## 🔩 Key Design Features

* **Fully Synthesizable** Verilog modules
* **Hierarchical FFT generation** via module reuse
* **Fixed-point scaling** to maintain amplitude precision
* **ROM-based Twiddle Factors** (Q2.14)
* **Natural order output** (no bit-reversal required)
* **Pipeline-friendly architecture** for future hardware acceleration

---

## 🧪 Verification & Testbench

Each FFT module includes a dedicated **testbench** (`FFTxxpt_tb.v`) that:

* Feeds real & imaginary fixed-point inputs
* Observes streaming outputs with `out_valid` and `out_last`
* Verifies FFT magnitude and phase against MATLAB reference output

Example monitoring output:

```verilog
$monitor("t=%0t | in_real=%d in_imag=%d | out_real=%d out_imag=%d",
          $time, in_real, in_imag, out_real, out_imag);
```

✅ Verified for all FFT sizes: 2, 4, 8, 16, 32, and 64 points.
✅ Matches MATLAB’s FFT results within fixed-point precision tolerance.
✅ Tested using ModelSim & Vivado simulators.

---

## 📊 Output Scaling & Accuracy

To prevent overflow across stages, the design includes **stage-wise normalization**:

* Intermediate results are scaled down after each butterfly.
* Twiddle factor products are right-shifted by `(TW_WIDTH - 2)` to preserve Q-format.

This ensures that the **output amplitude matches the true FFT** values, not `FFT/N` scaled outputs.

---

## 🧩 Applications

* Spectrum analysis in **Cognitive Radio systems**
* Real-time FFT computation in **FPGA-based SDRs**
* Signal decomposition in **Embedded DSP accelerators**
* Hardware demonstration for **Digital Communication systems**

---

## 📚 References

* Cooley, J. W., & Tukey, J. W. (1965). *An algorithm for the machine calculation of complex Fourier series.* Mathematics of Computation.
* Oppenheim, A. V., & Schafer, R. W. (2010). *Discrete-Time Signal Processing.*
* Proakis, J. G. *Digital Signal Processing: Principles, Algorithms, and Applications.*

---

## 🧑‍💻 Author

**Nageshwar Kumar**
🎓 B.Tech in Electrical Engineering, IIT Jammu
💻 Interests: VLSI, Embedded Systems, Signal Processing, IoT & Drones

📬 [LinkedIn Profile](https://www.linkedin.com/in/nageshwar-mehta)
📂 [GitHub Repository](https://github.com/nageshwar-mehta/Verilog)

---

⭐ *If you find this project useful, consider starring the repo — it motivates open-source contributions in the DSP hardware community!* 🚀

```

---

