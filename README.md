# Vending Machine FSM – Verilog Implementation

This project implements a Finite State Machine (FSM) model of a vending machine using Verilog HDL. The vending machine accepts dollar amounts via a 2-bit input and asserts a `change` signal when the amount reaches \$3 or more. This simulation-based project uses a testbench to rigorously validate all typical and edge-case scenarios, such as sequential payments, overpayments, and invalid inputs. The design is structured for deployment on FPGA platforms and verified using simulation tools such as Icarus Verilog and GTKWave.

---

## Project File Structure

* `VendingMachine.v` – Verilog module that implements the FSM controlling vending logic.
* `VendingMachine_tb.v` – Comprehensive testbench for simulating different payment sequences and validating vending behavior.
* `dump.vcd` – Output waveform file generated during simulation, viewable with GTKWave.

---

## Module Overview

### VendingMachine

This module implements a simple FSM that accepts up to \$3 of input before vending. It reacts to input values on a per-clock-cycle basis and transitions through four defined states:

* **s0**: Represents \$0 received.
* **s1**: Represents \$1 received.
* **s2**: Represents \$2 received.
* **s3**: Represents \$3 or more, which triggers vending.

The FSM logic updates on the rising edge of the clock or on reset. The `change` output is asserted when the machine reaches or exceeds the \$3 threshold. After vending, the FSM returns to the initial state (`s0`).

### VendingMachine\_tb

The testbench simulates real-world user behavior by injecting timed payment values and observing the `change` signal response. The testbench performs the following:

* Initializes signals and applies reset.
* Emulates multiple payment scenarios:

  * \$1 + \$1 + \$1 (incremental payment)
  * \$3 all at once (direct vend)
  * \$2 + \$1 (cumulative vend)
  * \$2 + \$2 (overpayment)
  * \$5, \$6, and \$7 (edge case overlimit inputs)
  * No input (idle behavior)
* Generates waveform logs using `$dumpfile` and `$dumpvars` for viewing in GTKWave.

---

## FSM State Definitions

| State | Binary | Description          |
| ----- | ------ | -------------------- |
| s0    | 00     | Idle / \$0 received  |
| s1    | 01     | \$1 received         |
| s2    | 10     | \$2 received         |
| s3    | 11     | \$3 or more, vending |

---

## Testbench Scenario Breakdown

| Test | Input Sequence    | Expected Outcome               |
| ---- | ----------------- | ------------------------------ |
| 1    | \$1 → \$1 → \$1   | Vend after 3rd input           |
| 2    | \$3               | Immediate vend                 |
| 3    | \$2 → \$1         | Cumulative vend                |
| 4    | \$2 → \$2         | Overpayment; vend              |
| 5    | \$5               | Immediate vend; handles excess |
| 6    | \$6 → \$7         | Validates upper limit inputs   |
| 7    | No input for 30ns | FSM remains idle               |

---

## Simulation & Debugging Strategy

* All key signals (`clk`, `reset`, `dol`, `change`, `state`, `next_state`) are dumped for waveform visualization.
* Timing delays emulate real user behavior and allow state verification.
* The testbench ensures that `dol` returns to 0 after each payment to model real-world pulse behavior.

---

## Technical Insights and Learning Reflections

* **reg** is used to store state across clock cycles; necessary for FSM internal states and outputs.
* **wire** is used for real-time combinational paths; cannot store values.
* **parameter** provides named constants for state labeling, improving code readability.
* **<=** (non-blocking assignment) ensures proper ordering in sequential logic.
* FSM should handle all possible input values explicitly to avoid inferred latches or undefined behavior.
* Overpayment handling is built into the FSM via `dol >= 3` conditional checks.
* The `change` signal is asserted exactly when vending occurs and cleared after returning to idle.
* Testbenches simulate user interaction by pulsing input signals and verifying system response.

---

## How to Simulate

### Prerequisites

* Icarus Verilog: [http://iverilog.icarus.com/](http://iverilog.icarus.com/)
* GTKWave: [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

### Simulation Commands

```bash
# Compile design and testbench
iverilog -o vending_sim.vvp VendingMachine_tb.v VendingMachine.v

# Run simulation
vvp vending_sim.vvp

# View waveforms
gtkwave dump.vcd
```

---

## Author

Kourosh Rashidiyan
June 2025

