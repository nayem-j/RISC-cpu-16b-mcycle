
// File: i_mem_8_X.sv
// Author: Md. Jannatul Nayem

/*each entry 8 bit, depth parameterized*/
module i_mem_8_X #(
  parameter                        DEPTH = 1024,
  parameter                        MEM_INIT = ""
)
(
  input  logic                     clk,
  input  logic                     rst,
  input  logic [$clog2(DEPTH)-1:0] mem_access_addr,
  input  logic                     mem_read,
  output logic [7:0]               read_data
);

  logic [7:0] mem [DEPTH-1:0];

  initial begin
    if(MEM_INIT != "") begin
      $readmemh(MEM_INIT, mem);
    end
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      read_data <= 8'd0;
    end else begin
      if(mem_read) begin
        read_data <= mem[mem_access_addr];
      end
    end
  end

endmodule
