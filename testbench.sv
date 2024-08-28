module test
  import AES_pkg::*;
  (
    output logic clk, req, rstN,
    output logic [128] data,
    output logic [128] key,
    input logic enable,
    input  logic [128] out_data,
);
  timeunit 1ns/1ns;
always #5 clk = ~clk;
  // generate stimulus
  initial begin
   	clk = 0;
    rstN = 0;
    req = 0;
    data = 'h00112233445566778899aabbccddeeff;
    key  = 'h000102030405060708090a0b0c0d0e0f;
    #15 rstN = 1;
    req = 1;
    #10 req = 0;
    #200 $finish;
    //for(int i = 0; i < 128*11; i+=128) begin
      //#10$display("i%0d: %0h", i/128, all_data[i+:128]);
      //#10if(((i+1) % 4) == 0) $display("\n");
	//end
    //#10$display("out_data: %0h", out_data);
  end
endmodule: test



module top;
  import AES_pkg::*;

  logic clk, req, rstN;
  logic [128] data;
  logic [128] key;
  logic enable;
  logic [128] out_data;

  test         test (.*);
  AES_encryptor dut (.*);
  
  initial begin
    $dumpfile("top.vcd");
    $dumpvars(0, top);
  end
endmodule: top