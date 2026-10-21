// File: soc.sv
// Author: Md. Jannatul Nayem

module soc #(
  parameter    MEM_DEPTH = 1024
)(
  input logic  clk, 
  input logic  rst
);

  // wires
  logic [15:0] imem_access_addr;
  logic        imem_read;
  logic [15:0] imem_read_data;

  logic [15:0] dmem_access_addr;
  logic [1:0]  dmem_byte_sel;
  logic        dmem_write_en;
  logic [15:0] dmem_write_data;
  logic        dmem_read;
  logic [15:0] dmem_read_data;


  // inst memory instance
  i_mem #(
    .START_ADDRESS('h0),
    .DEPTH(MEM_DEPTH)
  ) imem_i (
    .clk(clk),
    .rst(rst),
    .mem_access_addr(imem_access_addr),
    .mem_read(imem_read),
    .read_data(imem_read_data)
  );

  // data memory instance
  d_mem #(
    .START_ADDRESS(16'hF000),
    .DEPTH(MEM_DEPTH)
  ) dmem_i(
    .clk(clk),
    .rst(rst),
    .mem_access_addr(dmem_access_addr),
    .byte_sel(dmem_byte_sel),
    .write_en(dmem_write_en),
    .write_data(dmem_write_data),
    .mem_read(dmem_read),
    .read_data(dmem_read_data)
  );

  // memory mapped test peripheral
  test_reg #(
    .START_ADDRESS(16'hFFFF)
  ) test_reg_i (
    .clk(clk),
    .rst(rst),
    .access_addr(dmem_access_addr),
    .write_en(dmem_write_en),
    .write_data(dmem_write_data),
    .read_data(dmem_read_data),
    .read(dmem_read)
  );

  // cpu instance and memories connection
  cpu_16b_mcycle cpu_i (
    .clk(clk),
    .rst(rst),
    .imem_access_addr(imem_access_addr),
    .imem_read(imem_read),
    .imem_read_data(imem_read_data),
    .dmem_access_addr(dmem_access_addr),
    .dmem_byte_sel(dmem_byte_sel),
    .dmem_write_en(dmem_write_en),
    .dmem_write_data(dmem_write_data),
    .dmem_read(dmem_read),
    .dmem_read_data(dmem_read_data)
  );

endmodule

