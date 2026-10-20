
class gnrtr;
  
  mailbox mbox;
  trnxt trn;

  function new(mailbox mbox);
    $display("Generator instance created at time %0t", $time);
    this.mbox = mbox;
  endfunction

  virtual task gen();
  endtask

endclass : gnrtr
