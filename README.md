# Hex Keypad Scanner (Grayhill 4x4) – Verilog Implementation

This project presents a fully elaborated Verilog design and simulation setup for interfacing with a 4x4 hexadecimal matrix keypad, such as the Grayhill 96 series. It models the digital logic behavior of a keypad scanning FSM (Finite State Machine), featuring input synchronization, keypress decoding, debouncing strategy, and comprehensive testbench validation. Designed to run on FPGA-based development platforms, the project is simulation-ready using Icarus Verilog and GTKWave.

---

## Project File Structure

* `Row_Signal.v` – Combinational module that detects the active row from key and column inputs.
* `Synchronizer.v` – Double flip-flop design that synchronizes asynchronous row signals.
* `Hex_Keypad_Grayhill_072.v` – The central FSM module that drives the column scanning, key decoding, and valid flag output.
* `Hex_Keypad_tb.v` – A robust testbench with individualized key signal declarations and diverse key press simulation cases.
* `VendingMachine.v` – FSM-based vending logic that detects dollar inputs and controls vending output.
* `VendingMachine_tb.v` – Testbench to simulate and verify different input payment scenarios.
* `dump.vcd` – Generated during simulation for waveform inspection using GTKWave.

---

## Modules Breakdown and Functionality

### Row\_Signal

This module is purely combinational. It observes the current active column and checks the 16-bit input `Key` (representing the 4x4 keypad layout). For each row, it asserts a bit in the output `Row[3:0]` if any key in that row is pressed in conjunction with the currently active column.

Example: If `Col[1]` is active and `Key[5]` is high (representing row 1, column 1), then `Row[1]` becomes high.

### Synchronizer

Handles the conversion of potentially asynchronous row activity into a stable, clocked signal that the FSM can safely process. It uses a classic two-stage flip-flop approach:

* Stage 1 samples the result of an OR-reduction of the row signal.
* Stage 2 outputs the delayed version of stage 1 to produce the final `S_Row` signal.

This ensures metastability mitigation before FSM interaction.

### Hex\_Keypad\_Grayhill\_072

This is the main FSM which performs the following operations:

1. Idle (S\_0): Waits for any row activity.
2. Scan Columns (S\_1–S\_4): Sequentially activates each column and reads rows.
3. Decode: Matches the `{Row, Col}` combination to a hexadecimal key code.
4. Hold (S\_5): Maintains state while key is pressed to avoid repeated triggering.

It outputs:

* `Code[3:0]`: Hex code (0–F) of the detected key.
* `Valid`: Signal asserted when a legitimate keypress is detected.
* `Col[3:0]`: Actively driven column control signals.

FSM uses one-hot state encoding (`S_0` through `S_5`) to reduce decoding complexity.

### VendingMachine

This module implements a simple finite state machine to model vending behavior based on inserted money. It accepts dollar inputs in the range \$0 to \$3 (2-bit input). The FSM transitions through the following states:

* `s0`: Initial or reset state. Awaiting payment.
* `s1`: After receiving \$1.
* `s2`: After receiving \$2.
* `s3`: \$3 or more accumulated, vending occurs.

Transitions are determined based on the current input (`dol`). If \$3 or more is reached at any point, the output `change` is asserted and the state returns to `s0`.

### VendingMachine\_tb

This testbench drives realistic scenarios to verify the behavior of the `VendingMachine` FSM. It tests the following conditions:

* Accumulated payment using \$1 increments.
* Instant payment with \$3.
* Mixed combinations like \$2 followed by \$1.
* Overpayment using \$5.
* Inputs beyond expected range (\$6 and \$7).
* Idle time testing with no inputs.

Includes waveform dumping via `$dumpfile` and `$dumpvars` for GTKWave.

---

## Simulation & Validation Goals

* Confirm FSM transitions and logic under clean and noisy input conditions.
* Validate correctness of `Code` and `change` outputs.
* Confirm proper synchronization via `S_Row` signal.
* Test debounce logic and rejection of spurious transitions.
* Ensure FSM reset and reentry behavior across test cases.

---

## FSM State Definitions (VendingMachine)

| State | Binary | Description          |
| ----- | ------ | -------------------- |
| `s0`  | 00     | Idle / \$0 received  |
| `s1`  | 01     | \$1 accumulated      |
| `s2`  | 10     | \$2 accumulated      |
| `s3`  | 11     | \$3 or more, vending |

---

## Testbench Scenario Breakdown

| Test | Input Sequence    | Expected Outcome                |
| ---- | ----------------- | ------------------------------- |
| 1    | 1 + 1 + 1         | Vends after 3rd dollar          |
| 2    | 3                 | Immediate vend                  |
| 3    | 2 + 1             | Cumulative vend at \$3          |
| 4    | 2 + 2             | Vends, handles overpayment      |
| 5    | 5                 | Immediate vend, handles \$5     |
| 6    | 6, 7              | Vends, handles max 3-bit values |
| 7    | No input for 30ns | FSM remains idle                |

---

## Waveform Visualization Strategy

* Each module has waveform signals defined through `$dumpvars`.
* GTKWave can be used to inspect FSM state (`state`, `next_state`), `change`, `dol`, and `clk`.
* Delays are used to emulate realistic input behavior.
* Waveforms confirm correct transitions, resets, and vend pulses.

---

## Learning Reflections

* `reg` signals retain state across clock cycles and are required for FSM state and outputs assigned in sequential blocks.
* `wire` signals are used for combinational paths and `assign` statements.
* Double flip-flop synchronizers are essential when handling asynchronous mechanical inputs.
* `parameter` improves readability and enables easy state labeling.
* `<=` (non-blocking) must be used for correct sequential behavior.
* FSM should always handle all input cases to avoid latches or undefined behavior.
* Testbenches must toggle input values (e.g., return `dol` to 0 after each payment) to simulate user interactions.

---

## Keypad Mapping Table (Row, Col → Hex Code)

| Row | Col | Binary (Row, Col) | Key Code |
| --- | --- | ----------------- | -------- |
| 0   | 0   | 0001\_0001        | 0x0      |
| 0   | 1   | 0001\_0010        | 0x1      |
| 0   | 2   | 0001\_0100        | 0x2      |
| 0   | 3   | 0001\_1000        | 0x3      |
| 1   | 0   | 0010\_0001        | 0x4      |
| 1   | 1   | 0010\_0010        | 0x5      |
| 1   | 2   | 0010\_0100        | 0x6      |
| 1   | 3   | 0010\_1000        | 0x7      |
| 2   | 0   | 0100\_0001        | 0x8      |
| 2   | 1   | 0100\_0010        | 0x9      |
| 2   | 2   | 0100\_0100        | 0xA      |
| 2   | 3   | 0100\_1000        | 0xB      |
| 3   | 0   | 1000\_0001        | 0xC      |
| 3   | 1   | 1000\_0010        | 0xD      |
| 3   | 2   | 1000\_0100        | 0xE      |
| 3   | 3   | 1000\_1000        | 0xF      |

---

## Technical Summary

This Verilog design showcases practical digital design techniques:

* FSM logic using one-hot and binary encoding
* Synchronization of mechanical input signals
* Sequential vs combinational design practices
* Modular architecture and simulation-driven verification
* Waveform inspection to validate design correctness
* Behavioral and structural Verilog features for real-world interfaces

---

## How to Build and Run Simulation

### Prerequisites

Install [Icarus Verilog](http://iverilog.icarus.com/) and [GTKWave](http://gtkwave.sourceforge.net/).

### Simulation Steps

```bash
# Compile all modules and testbenches
iverilog -o simulation.vvp Hex_Keypad_tb.v VendingMachine_tb.v Row_Signal.v Synchronizer.v Hex_Keypad_Grayhill_072.v VendingMachine.v

# Run the simulation
vvp simulation.vvp

# View the waveform
gtkwave dump.vcd
```

---

## Author

Kourosh Rashidiyan
June 2025

