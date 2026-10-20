class test_conops extends base_test;

  function new(virtual cpu_intf intf);
    super.new(intf);
    $display("CON Ops test instance created at time %0t", $time);
  endfunction

  virtual task run_test();
    reset(10);
    env.scr.report();
  endtask

endclass : test_conops
