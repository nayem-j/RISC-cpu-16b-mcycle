class envr;

  agnt ag;
  scrbd scr;
  cvrg cvr;

  mailbox mn_scb, gnr_drv;

  function new(virtual cpu_intf intf, semaphore sem);
    $display("Environment created at time %0t", $time);
    mn_scb = new();
    gnr_drv = new();
    ag = new(intf, mn_scb, gnr_drv, sem);
    scr = new(intf, mn_scb);
    cvr = new(intf);
  endfunction

  
endclass : envr
