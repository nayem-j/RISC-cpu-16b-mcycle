
class driver;

  virtual cpu_intf intf;
  semaphore sem;

  int timeout = 0;

  function new(virtual cpu_intf intf, semaphore sem);
    $display("Driver instance created at time %0t", $time);
    this.intf = intf;
    this.sem = sem;
  endfunction

  task reset(input int cycles);
    intf.rst <= 1;
    repeat(cycles) @(posedge intf.clk);
    intf.rst <= 0;
    sem.put(1); // release
  endtask

endclass : driver
