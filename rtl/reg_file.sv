
// File: reg_file.sv
// Author: Md. Jannatul Nayem

module reg_file (
  input  logic        clk,
  input  logic        rst,
  input  logic [2:0]  read_addr1,
  input  logic [2:0]  read_addr2,
  input  logic [2:0]  write_addr,
  input  logic        write_en,
  input  logic [15:0] write_data,
  output logic [15:0] read_data1,
  output logic [15:0] read_data2
);
  
  bit [15:0] regs [7:0];
  
  always_ff @(posedge clk) begin
    if(rst) begin
      for (int i = 0;i < 8; i++) begin
        regs[i] <= 16'd0;
      end
    end else begin
      if(write_en) begin
        regs[write_addr] <= write_data;
      end
    end
  end
  
  assign read_data1 = regs[read_addr1];
  assign read_data2 = regs[read_addr2];
  
endmodule
