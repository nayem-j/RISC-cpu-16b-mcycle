class scrbd;

  virtual cpu_intf intf;
  mailbox mbx;
  trnxt trn;

  int err_cnt, total;

  function new(virtual cpu_intf intf, mailbox mbx);
    $display("Scoreboard instance created at time %0t", $time);
    this.intf = intf;
    this.mbx = mbx;
    this.err_cnt = 0;
    this.total = 0;
  endfunction

  task check();
    forever begin
        @(posedge intf.clk);
        if(mbx.try_get(trn)) begin
            $display("Scoreboard received transaction at time %0t", $time);
            // Checking logic goes here

            total++;
        end
    end
  endtask

  task report();
    $display("Scoreboard report at time %0t", $time);
    $display("Errors %0d, total transactions %0d ", err_cnt, total);
  endtask

endclass : scrbd