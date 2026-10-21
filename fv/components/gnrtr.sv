
class gnrtr;
  
  virtual cpu_intf intf;
  mailbox gnr_drv;
  trnxt trn;

  function new(virtual cpu_intf intf, mailbox gnr_drv);
    $display("Generator instance created at time %0t", $time);
    this.intf = intf;
    this.gnr_drv = gnr_drv;
  endfunction

  virtual task gen(input int num_seq_gnr);
    repeat (num_seq_gnr) begin
      trn = new();
      if (!trn.randomize()) begin
        $error("Generator randomization failed at time %0t", $time);
      end
      gnr_drv.put(trn);
      $display("Generator queued randomized transaction at time %0t", $time);
      @(posedge intf.clk);
    end
  endtask

endclass : gnrtr
