
class trnxt_conops extends trnxt;
  constraint c_prim_op_encoding { 
    imem_read_data[15:12] inside {[4'd10:4'd14]}; 
  }
endclass : trnxt_conops
