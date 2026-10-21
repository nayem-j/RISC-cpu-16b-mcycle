class base_test;

  envr env;
  semaphore sem;

  bit simulation_finished;

  function new(virtual cpu_intf intf);
    $display("Base test instance created at time %0t", $time);
    sem = new(1); // allow a single reset/driver transaction at a time
    env = new(intf, sem);

    fork
      env.ag.mn.monitor();
      env.scr.check();
      /* Add more parallel processes here if need be */

      check_simulation_finished();
    join_none

  endfunction

  virtual task check_simulation_finished();
    forever begin
      @(posedge env.ag.mn.intf.clk);
      if (env.ag.mn.simulation_finished) begin
        simulation_finished = 1'b1;
      end
    end
  endtask

  virtual task reset(input int cycles);
    $display("Resetting for %0d cycles at time %0t", cycles, $time);
    sem.get(1); //acquire
    env.ag.drv.reset(cycles);
  endtask

  virtual task letpass(input int cycles);
    $display("Let %0d simulation cycles pass at time %0t", cycles, $time);
    while (cycles > 0) begin
      @(posedge env.ag.drv.intf.clk);
      if (simulation_finished) begin
        break;
      end
      cycles--;
    end
  endtask

  virtual task run_test();
    reset(10);
    letpass(1000); // let 1000 simulation cycles pass after reset
    if (simulation_finished) begin
      $display("Simulation finished at time %0t", $time);
      /* let the testbench top do the finishing */
      // $finish;
    end
    env.scr.report();
  endtask

endclass : base_test
