// Code your testbench here
`timescale 1ns / 1ps  // Time unit = 1ns, precision = 1ps

module VendingMachine_tb;

  // ======================================
  // Testbench Signal Declarations
  // ======================================
  reg clk;                // Clock signal
  reg reset;              // Reset signal
  reg [2:0] dol;          // 3-bit input for dollar amount (0 to 7)
  wire change;            // Output: goes high when vending occurs

  // ======================================
  // Instantiate the Design Under Test (DUT)
  // ======================================
  VendingMachine uut (
    .clk(clk),            // Connect testbench clk to DUT clk
    .reset(reset),        // Connect testbench reset to DUT reset
    .dol(dol),            // Connect testbench dol to DUT dol
    .change(change)       // Observe output from DUT
  );

  // ======================================
  // Clock Generation: 100 MHz (10ns period)
  // ======================================
  always #5 clk = ~clk;   // Toggle clock every 5ns

  // ======================================
  // Test Sequence
  // ======================================
  initial begin
    // Dump waveform to a VCD file for viewing in GTKWave/EPWave
    $dumpfile("dump.vcd");           // Create VCD file
    $dumpvars(0, VendingMachine_tb); // Dump everything in this module

    // ========== Test Setup ==========
    clk = 0;         // Initialize clock
    reset = 1;       // Assert reset to initialize FSM
    dol = 0;         // No input at start
    #10 reset = 0;   // Deassert reset, FSM ready to accept inputs

    // ==========================================
    // Test 1: $1 + $1 + $1 → should vend
    // ==========================================
    #10 dol = 3'd1;  // Insert $1
    #10 dol = 3'd0;  // Remove input

    #10 dol = 3'd1;  // Insert $1
    #10 dol = 3'd0;  // Remove input

    #10 dol = 3'd1;  // Insert $1 → now $3 total
    #10 dol = 3'd0;  // Remove input

    // ==========================================
    // Test 2: $3 all at once → instant vend
    // ==========================================
    #20 dol = 3'd3;  // Insert $3 directly
    #10 dol = 3'd0;  // Remove input

    // ==========================================
    // Test 3: $2 then $1 → cumulative vend
    // ==========================================
    #20 dol = 3'd2;  // Insert $2
    #10 dol = 3'd0;

    #10 dol = 3'd1;  // Insert $1 → now $3
    #10 dol = 3'd0;

    // ==========================================
    // Test 4: $2 then $2 → overpay but should vend
    // ==========================================
    #20 dol = 3'd2;  // Insert $2
    #10 dol = 3'd0;

    #10 dol = 3'd2;  // Insert $2 → exceeds $3
    #10 dol = 3'd0;

    // ==========================================
    // Test 5: $5 input — test overlimit handling
    // ==========================================
    #20 dol = 3'd5;  // Insert $5 directly
    #10 dol = 3'd0;

    // ==========================================
    // Test 6: Edge-case invalid inputs ($6 and $7)
    // ==========================================
    #20 dol = 3'd6;  // Insert $6 — highest valid 3-bit value
    #10 dol = 3'd0;

    #20 dol = 3'd7;  // Insert $7 — max 3-bit input
    #10 dol = 3'd0;

    // ==========================================
    // Test 7: Idle time, no inputs
    // ==========================================
    #30;             // Wait — FSM should remain idle

    // ========== End of Simulation ==========
    #50 $finish;     // Terminate the simulation
  end

endmodule
