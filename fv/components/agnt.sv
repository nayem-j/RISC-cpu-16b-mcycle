class agnt;

  driver drv;
  mntr mn;

  function new(virtual cpu_intf intf, mailbox mbx, semaphore sem);
    $display("Agent instance created at time %0t", $time);
    drv = new(intf, sem);
    mn = new(intf, mbx);
  endfunction

endclass : agnt
