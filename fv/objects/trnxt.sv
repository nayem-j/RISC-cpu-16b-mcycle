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
  constraint c_prim_op_encoding {
    imem_read_data[15:12] dist {
      [4'd2:4'd9] := 3,
      4'd15 := 3, 
      [4'd0:4'd1] := 4,
      [4'd10:4'd14] := 2 
    };
  }

  constraint c_sec_op_encoding {
    if (imem_read_data[15:12] inside {[4'd2:4'd9], 4'd15}) {
      if (imem_read_data[15:12] == 4'd15) {
        /* extended alu ops biased toward the upper range */
        imem_read_data[2:0] dist {
          [3'd0:3'd2] := 2,
          [3'd3:3'd5] := 3,
          [3'd6:3'd7] := 4
        };
      } else {
        // socnday opcode is ignored when the primary opcode is not 4'd15
        imem_read_data[2:0] dist {
          3'd0 := 4,
          [3'd1:3'd7] := 0
        };
      }
    }
  }

  /* keep register fields valid and bias toward the common cases*/
  constraint c_reg_encoding {
    imem_read_data[11:9] dist {
      3'd0 := 1,
      [3'd1:3'd5] := 3,
      [3'd6:3'd7] := 2
    };
    imem_read_data[8:6] dist {
      3'd0 := 0,
      [3'd1:3'd5] := 3,
      [3'd6:3'd7] := 1
    };
    imem_read_data[5:3] dist {
      3'd0 := 0,
      [3'd1:3'd5] := 3,
      [3'd6:3'd7] := 2
    };
  }

  /* match field usage to how the CPU actually decodes */
  constraint c_offset_usage {
    if (imem_read_data[15:12] inside {4'd0, 4'd1}) {
      // load/store: offset in [5:0]
      
      imem_read_data[5:0] dist {
        6'd0 := 4,
        [6'd1:6'd15] := 3,
        [6'd16:6'd3] := 2,
        [6'd32:6'd63] := 1
      };
    }

    if (imem_read_data[15:12] == 4'd10) {
      // jumps
      imem_read_data[11:0] dist {
        [12'd0:12'd2] := 2,
        [12'd3:12'd5] := 3,
        [12'd6:12'd7] := 4,
        [12'd8:12'd4095] := 1
      };
    }
  }

  /* bias memory return data toward useful corner cases */
  constraint c_dmem_read_data_mix {
    dmem_read_data dist {
      16'h0000 := 2, 16'h0001 := 3,
      16'h7FFF := 4, 16'h8000 := 3,
      16'hFFFF := 2, [16'h0002:16'h7FFE] := 1,
      [16'h8001:16'hFFFE] := 1
    };
  }

endclass : trnxt
