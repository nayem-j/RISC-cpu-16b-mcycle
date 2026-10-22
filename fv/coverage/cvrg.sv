
covergroup cg_ops(virtual cpu_intf intf) @(posedge intf.clk);
  
  option.per_instance = 1;

  imem_read_CP: coverpoint intf.imem_read {
    bins read = {1};
  }

  dmem_read_CP: coverpoint intf.dmem_read {
    bins read = {1};
  }

  dmem_write_en_CP: coverpoint intf.dmem_write_en {
    bins write = {1};
  }

  state_t_CP: coverpoint intf.debug_state {
    bins setup = {0};
    bins fetch = {1};
    bins execute = {2};
    bins storage = {3};
  }

  prim_op_CP: coverpoint intf.debug_fetched[15:12] {
    bins prim_ops[16] = {[4'd0:4'd15]};
  }

  sec_op_CP: coverpoint intf.debug_fetched[2:0] {
    bins sec_ops[8] = {[3'd0:3'd7]};
  }

  branch_taken_CP: coverpoint (intf.debug_fetched[15:12] == 4'd10) || (intf.debug_fetched[15:12] == 4'd11 && intf.debug_rs1_data == intf.debug_rs2_data) || (intf.debug_fetched[15:12] == 4'd12 && intf.debug_rs1_data != intf.debug_rs2_data) || (intf.debug_fetched[15:12] == 4'd13 && $signed(intf.debug_rs1_data) < $signed(intf.debug_rs2_data)) || (intf.debug_fetched[15:12] == 4'd14 && $signed(intf.debug_rs1_data) > $signed(intf.debug_rs2_data)) ? 1'b1 : 1'b0 {
    bins taken = {1};
    bins not_taken = {0};
  }

  branch_offset_CP: coverpoint $signed(intf.debug_fetched[5:0]) {
    bins neg_large = {[-32:-9]};
    bins neg_small = {[-8:-1]};
    bins zero = {0};
    bins pos_small = {[1:8]};
    bins pos_large = {[9:31]};
  }

  alu_op_CP: coverpoint intf.debug_alu_op {
    bins dpops = {0};
    bins lsops = {1, 2}; 
    bins conops = {3};
  }

  flags_zf_CP: coverpoint intf.debug_flags[0] {
    bins zf_set = {1};
    bins zf_clear = {0};
  }

  flags_sf_CP: coverpoint intf.debug_flags[1] {
    bins sf_set = {1};
    bins sf_clear = {0};
  }

  flags_cf_CP: coverpoint intf.debug_flags[2] {
    bins cf_set = {1};
    bins cf_clear = {0};
  }

  rs1_addr_CP: coverpoint intf.debug_rs1_addr {
    bins rs1[8] = {[3'd0:3'd7]};
  }
  
  rs2_addr_CP: coverpoint intf.debug_rs2_addr {
    bins rs2[8] = {[3'd0:3'd7]};
  }
  
  branch_cross_CP: cross branch_taken_CP, branch_offset_CP;

endgroup : cg_ops


class cvrg; // Coverage class for CPU operations

virtual cpu_intf intf;

cg_ops cg;

function new(virtual cpu_intf intf);
  $display("Coverage instance created at time %0t", $time);
  this.intf = intf;
  cg = new(intf);
endfunction

endclass : cvrg