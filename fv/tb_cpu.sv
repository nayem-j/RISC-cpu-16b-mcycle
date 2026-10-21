import tb_params::*;

module tb_cpu;

  string test = "dpops";
  bit clk;

  // Test class handles
  test_dpops dpops;
  test_lsops lsops;
  test_conops conops;

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end
  
  // CPU interface
  cpu_intf intf(clk);

  // Design instance
  cpu_16b_mcycle dut_cpu_16b_mcycle_i (
    .clk(intf.clk),
    .rst(intf.rst),

    .imem_access_addr(intf.imem_access_addr),
    .imem_read(intf.imem_read),
    .imem_read_data(intf.imem_read_data),

    .dmem_access_addr(intf.dmem_access_addr),
    .dmem_byte_sel(intf.dmem_byte_sel),
    .dmem_write_en(intf.dmem_write_en),
    .dmem_write_data(intf.dmem_write_data),
    .dmem_read(intf.dmem_read),
    .dmem_read_data(intf.dmem_read_data),

    .debug_state(intf.debug_state),
    .debug_pc(intf.debug_pc),
    .debug_fetched(intf.debug_fetched),
    .debug_alu_op(intf.debug_alu_op),
    .debug_alu_result(intf.debug_alu_result),
    .debug_flags(intf.debug_flags),
    .debug_rs1_data(intf.debug_rs1_data),
    .debug_rs2_data(intf.debug_rs2_data),
    .debug_rd_data(intf.debug_rd_data),
    .debug_reg_write_en(intf.debug_reg_write_en)
  );

  // inst memory instance
  i_mem #(
    .START_ADDRESS(16'h0000),
    .DEPTH(MEM_DEPTH)
  ) imem_i (
    .clk(intf.clk),
    .rst(intf.rst),
    .mem_access_addr(intf.imem_access_addr),
    .mem_read(intf.imem_read),
    .read_data(intf.imem_read_data)
  );
  
  // data memory instance
  d_mem #(
    .START_ADDRESS(16'hF000),
    .DEPTH(MEM_DEPTH)
  ) dmem_i(
    .clk(intf.clk),
    .rst(intf.rst),
    .mem_access_addr(intf.dmem_access_addr),
    .byte_sel(intf.dmem_byte_sel),
    .write_en(intf.dmem_write_en),
    .write_data(intf.dmem_write_data),
    .mem_read(intf.dmem_read),
    .read_data(intf.dmem_read_data)
  );

  test_reg #( // memory mapped test register
    .START_ADDRESS(16'hFFFF)
  ) test_reg_i(
    .clk(intf.clk),
    .rst(intf.rst),
    .access_addr(intf.dmem_access_addr),
    .write_en(intf.dmem_write_en),
    .write_data(intf.dmem_write_data),
    .read_data(intf.dmem_read_data),
    .read(intf.dmem_read)
  );

  // Dump waveform
  initial begin
    $dumpfile("tb_cpu.vcd");
    $dumpvars(0, tb_cpu);

    if(test != "") begin
      $display("Running test: %s", test);
    end else begin
        $display("No test specified");
    end
  end

  // Test execution
  initial begin
    if(test != "") begin
        if(test == "dpops") begin
           dpops = new(intf);
           dpops.run_test();
        end else if (test == "lsops") begin
           lsops = new(intf);
           lsops.run_test();
        end else if (test == "conops") begin
           conops = new(intf);
           conops.run_test();
        end else begin
          $display("Unknown test: %s", test);
        end
    end
    #10 $finish; // Finish simulation
  end

endmodule
