class envr;

  agnt ag;
  scrbd scr;
  cvrg cvr;

  mailbox mbx;

  function new(virtual cpu_intf intf, semaphore sem);
    $display("Environment created at time %0t", $time);
    mbx = new();
    ag = new(intf, mbx, sem);
    scr = new(intf, mbx);
    cvr = new(intf);
  endfunction

  
endclass : envr
