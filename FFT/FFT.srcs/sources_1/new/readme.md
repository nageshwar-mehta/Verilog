

# ⚡ Hierarchical Fixed-Point FFT System (Verilog HDL)

## 1. Abstract

This project implements a **scalable and synthesizable Fast Fourier Transform (FFT)** system in Verilog HDL based on the **Cooley–Tukey radix-2 Decimation-In-Time (DIT)** algorithm.
It supports FFT sizes from **2-point to 64-point**, organized hierarchically for modularity and reusability.
Each module performs fixed-point arithmetic with **ROM-based twiddle factors (Q2.14)** and includes **fully verified testbenches** against MATLAB reference models.

---

## 2. Introduction

The **Fast Fourier Transform (FFT)** efficiently computes the **Discrete Fourier Transform (DFT)**, which converts discrete time-domain signals into their frequency components.

The DFT for an ( N )-point signal ( x[n] ) is given by:
[
X[k] = \sum_{n=0}^{N-1} x[n] \cdot e^{-j2\pi kn/N}
]

The **Cooley–Tukey algorithm** reduces computation from ( O(N^2) ) to ( O(N\log_2 N) ) using recursive decomposition.

---

## 3. Algorithm Overview — *Cooley–Tukey Radix-2 DIT FFT*

For a radix-2 DIT FFT:
[
X[k] = E[k] + W_N^k \cdot O[k]
]
[
X[k + N/2] = E[k] - W_N^k \cdot O[k]
]

Where:

* ( E[k] ): FFT of even-indexed samples
* ( O[k] ): FFT of odd-indexed samples
* ( W_N^k = e^{-j2\pi k/N} ): twiddle factor

This recursive process continues until **2-point butterflies**.

---

## 4. System Architecture

Each FFT block recursively combines smaller FFTs, following a **divide-and-conquer** approach.

### 4.1 Hierarchical Module Structure

```
FFT64pt Processor
 ├── FFT32pt Engine
 │    ├── FFT16pt Engine
 │    │    ├── FFT8pt Engine
 │    │    │    ├── FFT4pt Engine
 │    │    │    │    └── FFT2pt Core
```

### 4.2 Functional Flow Diagram

```
          ┌─────────────────────────────────────────────┐
          │                  FFT64pt                   │
          │                                             │
          │   ┌───────────────┐     ┌───────────────┐   │
 Input →──▶──▶│ Even 32-pt FFT│     │ Odd  32-pt FFT│───┤
          │   └───────────────┘     └───────────────┘   │
          │              │             │                │
          │              ▼             ▼                │
          │         ┌─────────────────────────────┐     │
          │         │ Complex Twiddle Multipliers │     │
          │         └─────────────────────────────┘     │
          │                    │                        │
          │                    ▼                        │
          │           ┌────────────────────┐             │
          │           │  Butterfly Combine │             │
          │           └────────────────────┘             │
          │                    │                        │
          │                    ▼                        │
          │                Frequency Output              │
          └─────────────────────────────────────────────┘
```

This structure repeats for all FFT stages (2 → 4 → 8 → 16 → 32 → 64).

---

## 5. Module Hierarchy

| FFT Size | Module Name    | Type      | Algorithm        | Description                 |
| -------- | -------------- | --------- | ---------------- | --------------------------- |
| 2-point  | `FFT2pt.v`     | Core      | Radix-2 DIT      | Basic butterfly computation |
| 4-point  | `FFT4pt.v`     | Engine    | Cooley–Tukey DIT | Combines two 2-pt FFTs      |
| 8-point  | `FFT8pt.v`     | Engine    | Cooley–Tukey DIT | Uses hierarchical recursion |
| 16-point | `FFT16pt.v`    | Engine    | Cooley–Tukey DIT | Employs Q2.14 twiddle ROM   |
| 32-point | `FFT32pt.v`    | Engine    | Cooley–Tukey DIT | Combines two 16-pt cores    |
| 64-point | `FFT64point.v` | Processor | Cooley–Tukey DIT | Full system wrapper         |

---

## 6. Fixed-Point Arithmetic (Q-Format)

### 6.1 Data Representation

| Parameter      | Meaning           | Typical Value |
| -------------- | ----------------- | ------------- |
| `WIDTH`        | Total bit width   | 16 bits       |
| `QF`           | Fractional bits   | 9             |
| `TW_WIDTH`     | Twiddle ROM width | 16 bits       |
| Twiddle Format | Fixed-point Q2.14 | —             |

### 6.2 Twiddle Factor Example

```verilog
function signed [15:0] W16_COS;
  input [2:0] idx;
  case (idx)
    3'd0: W16_COS = 16'sd16384;  // cos(0)
    3'd1: W16_COS = 16'sd15137;  // cos(pi/8)
    3'd2: W16_COS = 16'sd11585;  // cos(pi/4)
    3'd3: W16_COS = 16'sd6269;   // cos(3pi/8)
    3'd4: W16_COS = 16'sd0;      // cos(pi/2)
  endcase
endfunction
```

### 6.3 Scaling and Normalization

Each multiplication produces a **Q(Width + TW_WIDTH)** intermediate result, then right-shifted:
[
\text{scaled} = \frac{\text{product}}{2^{(TW_WIDTH - 2)}}
]
ensuring normalized outputs in the same Q-format.

---

## 7. Butterfly Computation

For complex inputs ( (a + jb) ) and twiddle ( (c - jd) ):

[
(a + jb)(c - jd) = (ac + bd) + j(bc - ad)
]

In Verilog:

```verilog
mult_r = a * c + b * d;  // Real part
mult_i = b * c - a * d;  // Imaginary part
```

---

## 8. Verification and Simulation

Each FFT module has a dedicated **testbench** with:

* Input feed (`in_valid`)
* Output monitoring (`out_valid`, `out_last`)
* MATLAB reference comparison

Simulation tools used:

* Xilinx Vivado 2023.1
* ModelSim PE Student Edition
* MATLAB Fixed-Point Toolbox

### 8.1 Example Output (16-pt FFT)

```
t=1050 | out_real=256 | out_imag=512
t=1060 | out_real=128 | out_imag=-640
...
```

Outputs were matched to within ±1 LSB of MATLAB FFT results.

---

## 9. Key Features

✅ Fully synthesizable Verilog implementation
✅ Hierarchical Cooley–Tukey recursion
✅ ROM-based twiddle factors (Q2.14 precision)
✅ Scalable to any ( 2^N ) point FFT
✅ Fixed-point accuracy maintained
✅ Testbench verified against MATLAB models
✅ Natural order output — no bit reversal required

---

## 10. Applications

* Cognitive Radio Spectrum Analysis
* FPGA-based Signal Processing
* SDR (Software Defined Radio) Front-ends
* Digital Modulation/Demodulation
* VLSI DSP and Hardware Accelerator Research

---

## 11. References

1. Cooley, J. W., & Tukey, J. W. (1965). *An Algorithm for the Machine Calculation of Complex Fourier Series.* *Mathematics of Computation, 19*(90), 297–301.
2. Oppenheim, A. V., & Schafer, R. W. (2010). *Discrete-Time Signal Processing.* Pearson.

---

## 12. Author

**Nageshwar Kumar**
🎓 *B.Tech, Electrical Engineering – IIT Jammu*
💡 *Focus Areas:* VLSI Design, DSP, Embedded Systems, IoT, Drones

📬 [LinkedIn](https://www.linkedin.com/in/nageshwar-mehta)
📂 [GitHub Repository](https://github.com/nageshwar-mehta/Verilog)

---

> 🧠 *“Divide and conquer — the essence of the Cooley–Tukey FFT — powers not just algorithms, but scalable hardware design.”*
> ⭐ If this project adds value to your DSP learning, consider starring it on GitHub!


