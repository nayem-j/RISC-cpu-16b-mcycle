class agnt;

  driver drv;
  mntr mn;
  gnrtr gnr;

  function new(virtual cpu_intf intf, mailbox mn_scb, mailbox gnr_drv, semaphore sem);
    $display("Agent instance created at time %0t", $time);
    drv = new(intf, gnr_drv, sem);
    mn = new(intf, mn_scb);
    gnr = new(intf, gnr_drv);
  endfunction

endclass : agnt
