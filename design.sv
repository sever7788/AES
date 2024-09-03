`include "AES_pkg.sv"
module AES_encryptor
  import AES_pkg::*;
  (
    input logic clk, req, rstN,
    input  logic [0:127] data,
    input  logic [0:127] key,
    output logic enable,
    output logic [0:127] out_data,
);
  
  logic [128] temp_data;
  logic [128] expanded_key;
  states_t state, next;
  logic [3:0] r_cnt;
  
  assign enable = (state == RESET && r_cnt);
  assign out_data = temp_data;
  
  always_ff @(posedge clk or negedge rstN) begin 
    if(!rstN)
      state <= RESET;
    else
      state <= next;
  end
  
  always_ff @(posedge clk or negedge rstN) begin   
    if(!rstN) begin
      expanded_key[0:127] <= '0;
      temp_data <= '0;
      r_cnt <= '0;
    end
    else
      case(state) 
        RESET: begin 
          if(req == 1) begin
            r_cnt <= 0;
            expanded_key[0:127] <= GetRoundKey(key[0:127], 0);
            temp_data <= data^key[0:127];
          end
        end
        MIDDLE: begin
          expanded_key[0:127] <= GetRoundKey(expanded_key[0:127], r_cnt+1);
          temp_data <= MixColumns(ShiftRows(SubBytes(temp_data)))^expanded_key[0:127];
          r_cnt <= r_cnt+1;
        end
        READY: begin
          expanded_key[0:127] <= GetRoundKey(expanded_key[0:127], 10);
          temp_data <= ShiftRows(SubBytes(temp_data))^expanded_key[0:127];
        end
        default:;
        endcase
  end

  //Next State logic
  always_comb begin
    case(state) 
      RESET: next = (req == '0) ? RESET : MIDDLE;
      MIDDLE: next = (r_cnt != 8) ? MIDDLE : READY;
      READY: next = RESET;
      default: next = RESET;
    endcase
  end
endmodule