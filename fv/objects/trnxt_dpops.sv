
class trnxt_dpops extends trnxt;
  constraint c_prim_op_encoding {
    imem_read_data[15:12] inside {[4'd2:4'd9], 4'd15};
  }
endclass : trnxt_dpops
