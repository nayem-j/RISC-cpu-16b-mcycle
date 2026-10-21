
class mntr;

  virtual cpu_intf intf;
  mailbox mn_scb;
  trnxt trn;
  bit simulation_finished;

  function new(virtual cpu_intf intf, mailbox mn_scb);
    $display("Monitor instance created at time %0t", $time);
    this.intf = intf;
    this.mn_scb = mn_scb;
    this.simulation_finished = 1'b0;
  endfunction

  virtual task monitor();
    forever begin
        @(posedge intf.clk);

        trn = new();

        trn.imem_access_addr     = intf.imem_access_addr;
        trn.imem_read            = intf.imem_read;
        trn.imem_read_data       = intf.imem_read_data;

        trn.dmem_access_addr     = intf.dmem_access_addr;
        trn.dmem_byte_sel        = intf.dmem_byte_sel;
        trn.dmem_write_en        = intf.dmem_write_en;
        trn.dmem_write_data      = intf.dmem_write_data;
        trn.dmem_read            = intf.dmem_read;
        trn.dmem_read_data       = intf.dmem_read_data;

        trn.debug_state          = intf.debug_state;
        trn.debug_pc             = intf.debug_pc;
        trn.debug_fetched        = intf.debug_fetched;
        trn.debug_alu_op         = intf.debug_alu_op;
        trn.debug_alu_result     = intf.debug_alu_result;
        trn.debug_flags          = intf.debug_flags;
        trn.debug_rs1_addr       = intf.debug_rs1_addr;
        trn.debug_rs1_data       = intf.debug_rs1_data;
        trn.debug_rs2_addr       = intf.debug_rs2_addr;
        trn.debug_rs2_data       = intf.debug_rs2_data;
        trn.debug_rd_addr        = intf.debug_rd_addr;
        trn.debug_rd_data        = intf.debug_rd_data;
        trn.debug_reg_write_en   = intf.debug_reg_write_en;

        if (intf.dmem_write_en && intf.dmem_access_addr == 16'hFFFF &&
            intf.dmem_write_data[15])
        begin
          simulation_finished = 1'b1;
          $display("Simulation finished flag set at time %0t with exit code %0h", $time, intf.dmem_write_data[3:0]);
          continue; // Skip mailbox put for this transaction
        end

        $display("Transaction captured at time %0t", $time);
        mn_scb.put(trn);
    end
  endtask

endclass : mntr
