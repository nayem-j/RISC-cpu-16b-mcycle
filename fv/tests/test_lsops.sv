class test_lsops extends base_test;

  function new(virtual cpu_intf intf);
    super.new(intf);
    $display("LS Ops test instance created at time %0t", $time);
  endfunction

  virtual task run_test();
    reset(10);
    letpass(1000); // let 1000 simulation cycles pass after reset
    env.scr.report();
  endtask

endclass : test_lsops
