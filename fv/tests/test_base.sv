class base_test;

  envr env;
  semaphore sem;

  function new(virtual cpu_intf intf);
    $display("Base test instance created at time %0t", $time);
    sem = new(1); // allow a single reset/driver transaction at a time
    env = new(intf, sem);

    fork
      env.scr.check();
      env.ag.mn.monitor();
      /* Add more parallel processes here if needed */
    join_none

  endfunction

  virtual task reset(input int cycles);
    $display("Resetting for %0d cycles at time %0t", cycles, $time);
    sem.get(1); //acquire
    env.ag.drv.reset(cycles);
  endtask

  virtual task run_test();
    reset(10); // default to 10 cycles for reset
  endtask

endclass : base_test
