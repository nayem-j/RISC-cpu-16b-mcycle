
import defs::*;

interface cpu_intf (input logic clk);
  logic        rst;
  logic [15:0] imem_access_addr;
  logic        imem_read;
  logic [15:0] imem_read_data;


  logic [15:0] dmem_access_addr;
  logic [1:0]  dmem_byte_sel;
  logic        dmem_write_en;
  logic [15:0] dmem_write_data;
  logic        dmem_read;
  logic [15:0] dmem_read_data;

  state_t      debug_state;
  logic [15:0] debug_pc;
  logic [15:0] debug_fetched;
  logic [1:0]  debug_alu_op;
  logic [15:0] debug_alu_result;
  logic [2:0]  debug_flags;
  logic [2:0]  debug_rs1_addr;
  logic [15:0] debug_rs1_data;
  logic [2:0]  debug_rs2_addr;
  logic [15:0] debug_rs2_data;
  logic [2:0]  debug_rd_addr;
  logic [15:0] debug_rd_data;
  logic        debug_reg_write_en;


  property p_reset;
    @(posedge clk) disable iff (!rst)
    (rst) |-> ##1 (debug_state == SETUP && debug_pc == 16'd0);
  endproperty

  assert property (p_reset) else $error("Reset property failed");

endinterface : cpu_intf
