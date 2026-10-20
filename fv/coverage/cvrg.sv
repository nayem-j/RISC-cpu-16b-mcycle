
covergroup cg_ops(virtual cpu_intf intf) @(posedge intf.clk);
  
  option.per_instance = 1;

  imem_read_CP: coverpoint intf.imem_read {
    bins read = {1};
    bins not_read = {0};
  }

  dmem_read_CP: coverpoint intf.dmem_read {
    bins read = {1};
    bins not_read = {0};
  }

  dmem_write_en_CP: coverpoint intf.dmem_write_en {
    bins write = {1};
    bins not_write = {0};
  }

  state_t_CP: coverpoint intf.debug_state {
    bins setup = {0};
    bins fetch = {1};
    bins execute = {2};
    bins storage = {3};
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