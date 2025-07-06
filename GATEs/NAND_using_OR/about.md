# NAND Gate using OR Gate in Verilog

## Project Name
**NAND using OR Gate**


## 🗓 Date
03 July 2025

---

## Objective
Implement a **NAND gate using only OR and NOT gates in Verilog** to understand **gate-level design and logic equivalence**.

---

## Theory and Background

### What is a NAND Gate?
A **NAND gate** outputs `0` **only if all its inputs are `1`**, else it outputs `1`.

**Truth Table:**

| A | B | NAND (Y) |
|---|---|----------|
| 0 | 0 | 1        |
| 0 | 1 | 1        |
| 1 | 0 | 1        |
| 1 | 1 | 0        |

### Implementing NAND using OR and NOT
Using **De Morgan’s Law**:

\[
\overline{A \cdot B} = \overline{A} + \overline{B}
\]

Meaning:
- Invert both inputs using NOT gates (`~a`, `~b`).
- OR the inverted inputs to get NAND functionality.

---

## Code Explanation

```verilog
module NAND(a, b, y);
    input a, b;
    output y;
    wire w1, w2;

    assign w1 = ~a;      // Invert input a
    assign w2 = ~b;      // Invert input b
    assign y = w1 | w2;  // OR the inverted inputs to get NAND output
endmodule
