
class test_dpops extends base_test;
  
  function new(virtual cpu_intf intf);
    super.new(intf);
    $display("DP Ops test instance created at time %0t", $time);
  endfunction

  virtual task run_test();
    reset(10);
    // DP Ops specific tasks go here
    env.scr.report();
  endtask

endclass : test_dpops
