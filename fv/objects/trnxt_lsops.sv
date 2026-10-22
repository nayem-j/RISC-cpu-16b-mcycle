
class trnxt_lsops extends trnxt;
    constraint c_prim_op_encoding {
      imem_read_data[15:12] inside {4'd0, 4'd1}; 
    }
endclass : trnxt_lsops
