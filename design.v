// Code your design here
module VendingMachine(
  input clk,
  input reset,
  input [1:0] dol,     // Accepts 2-bit input (00, 01, 10, 11 = $0–$3)
  output reg change    // Output should be reg since assigned inside always block
);

  // FSM States
  parameter s0 = 2'b00;  // $0
  parameter s1 = 2'b01;  // $1
  parameter s2 = 2'b10;  // $2
  parameter s3 = 2'b11;  // $3 (vend)

  reg [1:0] state, next_state;

  // Sequential logic: state update on clock or reset
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= s0;           // Reset state to s0
    else
      state <= next_state;   // Advance to next state
  end

  // Combinational logic: next state and output
  always @(*) begin
    // Default assignments
    next_state = state;
    change = 0;

    case (state)
      s0: begin
        if (dol == 2'd1) next_state = s1;
        else if (dol == 2'd2) next_state = s2;
        else if (dol >= 2'd3) begin
          next_state = s3;
          change = 1;
        end
      end

      s1: begin
        if (dol == 2'd1) next_state = s2;
        else if (dol >= 2'd2) begin
          next_state = s3;
          change = 1;
        end
      end

      s2: begin
        if (dol >= 2'd1) begin
          next_state = s3;
          change = 1;
        end
      end

      s3: begin
        next_state = s0;   // After vending, reset state
        change = 0;
      end

      default: begin
        next_state = s0;
        change = 0;
      end
    endcase
  end

endmodule

          
          
    
  
/*  
  parameter s0 = 2'b00;
  parameter s1 = 2'b01;
  parameter s2 = 2'b10;
  
  reg[1:0] in_state;
  reg{1:0] no_state;
  
  always @(posedge clock)
    begin
      if (reset)
        dol <= 3'b000;
      end
  	  else if (in_state && dol <= 3'b001)
        s0 <= s1
      else if(no_state && dol <= 3'b000)
        no_state <= 2'b00;
        s1 <= s0;
      end
*/    
          
              
       
  
        
  
