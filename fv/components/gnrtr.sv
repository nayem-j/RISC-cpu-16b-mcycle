import tb_pkg::*;

class gnrtr;
  
  virtual cpu_intf intf;
  mailbox gnr_drv;
  trnxt trn;

  gen_kind_e gen_kind = GEN_ALL;

  function void set_gen_kind(gen_kind_e kind);
    gen_kind = kind;
  endfunction

  function new(virtual cpu_intf intf, mailbox gnr_drv);
    $display("Generator instance created at time %0t", $time);
    this.intf = intf;
    this.gnr_drv = gnr_drv;
  endfunction

  virtual task gen(input int num_seq_gnr);
    repeat (num_seq_gnr) begin

      case (gen_kind)
        GEN_DPOPS: trn = trnxt_dpops::new();
        GEN_LSOPS: trn = trnxt_lsops::new();
        GEN_CONOPS: trn = trnxt_conops::new();
        default: trn = trnxt::new();
      endcase

      if (!trn.randomize()) begin
        $error("Generator randomization failed at time %0t", $time);
      end
      gnr_drv.put(trn);
      $display("Generator queued randomized transaction at time %0t", $time);
      @(posedge intf.clk);
    end
  endtask

endclass : gnrtr
