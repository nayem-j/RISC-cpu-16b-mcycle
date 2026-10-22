
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


  property prop_reset;
    @(posedge clk) disable iff (!rst)
    (rst) |-> ##1 (debug_state == SETUP && debug_pc == 16'd0);
  endproperty

  property prop_pc_upd;
    @(posedge clk) disable iff (!rst)
    (debug_state == STORAGE) |-> ##1 (debug_pc != $past(debug_pc));
  endproperty
  
  assert property (prop_reset) else $error("\033[38;5;208mReset property failed\033[0m");
  
  assert property (prop_pc_upd) else $error("\033[38;5;208mPC update property failed\033[0m");

endinterface : cpu_intf
