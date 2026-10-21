import defs::*;

class trnxt;

        logic [15:0] imem_access_addr;
        logic        imem_read;
  rand  logic [15:0] imem_read_data;

        logic [15:0] dmem_access_addr;
        logic [1:0]  dmem_byte_sel;
        logic        dmem_write_en;
        logic [15:0] dmem_write_data;
        logic        dmem_read;
  rand  logic [15:0] dmem_read_data;
  
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

  /* contrains to exercise all major op classes */
  constraint c_valid_instr_mix {
    imem_read_data[15:12] dist {
      [4'd2:4'd9]   := 3, // basic alu ops
      4'd15         := 3, // extended alu ops
      [4'd0:4'd1]   := 4, // load/store ops
      [4'd10:4'd14] := 2  // jump/branch ops
    };
  }

  /* bias memory return data toward useful corner cases */
  constraint c_dmem_read_data_mix {
    dmem_read_data dist {
      16'h0000            := 2,
      16'h0001            := 3,
      16'h7FFF            := 4,
      16'h8000            := 3,
      16'hFFFF            := 2,
      [16'h0002:16'h7FFE] := 1,
      [16'h8001:16'hFFFE] := 1
    };
  }

endclass : trnxt
