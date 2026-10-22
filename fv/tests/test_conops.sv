
class test_conops extends base_test;

  int num_seq_gnr = 3;

  function new(virtual cpu_intf intf);
    super.new(intf);
    $display("CON Ops test instance created at time %0t", $time);
  endfunction

  virtual task run_test();
    reset(10);
    
    env.ag.gnr.set_gen_kind(GEN_CONOPS);
    env.ag.gnr.gen(num_seq_gnr); // generate the specified number of sequences

    if (simulation_finished) begin
      $display("Simulation finished at time %0t", $time);
      /* let the testbench top do the finishing */
      // $finish;
    end
    env.scr.report();
  endtask  

endclass : test_conops
