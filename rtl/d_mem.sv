
// File: d_mem.sv
// Author: Md. Jannatul Nayem

module d_mem #(
  parameter                      DEPTH = 1024
)
(
  input  logic                   clk,
  input  logic                   rst,
  input  logic [$clog2(DEPTH):0] mem_access_addr,
  input  logic [1:0]             byte_sel,
  input  logic                   write_en,
  input  logic [15:0]            write_data,
  input  logic                   mem_read,
  output logic [15:0]            read_data
);

  /*memory bank0*/
  d_mem_8_X #(
    .DEPTH(DEPTH),
    .MEM_INIT("d_mem_b0.mem")
  ) mem_b0 (
    .clk(clk),
    .rst(rst),
    .mem_access_addr(mem_access_addr & ~1'b1),
    .write_en(write_en & byte_sel[0]),
    .write_data(write_data[7:0]),
    .mem_read(mem_read),
    .read_data(read_data[7:0])
  );


  /*memory bank1*/
  d_mem_8_X #(
    .DEPTH(DEPTH),
    .MEM_INIT("d_mem_b1.mem")
  ) mem_b1 (
    .clk(clk),
    .rst(rst),
    .mem_access_addr(mem_access_addr & ~1'b1),
    .write_en(write_en & byte_sel[1]),
    .write_data(write_data[15:8]),
    .mem_read(mem_read),
    .read_data(read_data[15:8])
  );


endmodule

