
class driver;

  virtual cpu_intf intf;
  mailbox gnr_drv;
  trnxt trn;
  semaphore sem;

  int timeout = 0;

  function new(virtual cpu_intf intf, mailbox gnr_drv, semaphore sem);
    $display("Driver instance created at time %0t", $time);
    this.intf = intf;
    this.gnr_drv = gnr_drv;
    this.sem = sem;
  endfunction

  virtual task reset(input int cycles);
    intf.rst <= 1;
    repeat(cycles) @(posedge intf.clk);
    intf.rst <= 0;
    sem.put(1); // release
  endtask

  virtual task drive();
    forever begin
      trn = new(); // create a new transaction object
      gnr_drv.get(trn);
      sem.get(1); // acquire before driving response
      @(posedge intf.clk);

      if (intf.imem_read) begin // only respond if requested
        intf.imem_read_data <= trn.imem_read_data;
        $display("Driver sent imem_read_data=0x%04h at time %0t", 
          trn.imem_read_data, $time);
      end
      if (intf.dmem_read) begin // respond only if requested
        intf.dmem_read_data <= trn.dmem_read_data;
        $display("Driver sent dmem_read_data=0x%04h at time %0t", 
          trn.dmem_read_data, $time);
      end
      sem.put(1); // release
    end // forever loop
  endtask

endclass : driver
