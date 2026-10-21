
class test_dpops extends base_test;
  
  function new(virtual cpu_intf intf);
    super.new(intf);
    $display("DP Ops test instance created at time %0t", $time);
  endfunction

endclass : test_dpops
