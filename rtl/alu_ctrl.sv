// File: alu_ctrl.sv
// Author: Md. Jannatul Nayem

module alu_ctrl(
  input  logic [1:0] alu_op,
  input  logic [3:0] opcode,
  input  logic [2:0] sec_opcode,
  output logic [4:0] ctrl_out
);

  always_comb begin

    ctrl_out = 5'h10;
    
    if (alu_op == 2'd0) begin /* alu operation*/

      case (opcode) 
	/* decode primary opcode*/
        4'd2 : ctrl_out = 5'd0;
        4'd3 : ctrl_out = 5'd1;
        4'd4 : ctrl_out = 5'd2;
        4'd5 : ctrl_out = 5'd3;
        4'd6 : ctrl_out = 5'd4;
        4'd7 : ctrl_out = 5'd5;
        4'd8 : ctrl_out = 5'd6;
        4'd9 : ctrl_out = 5'd7;

        4'd15 : begin 
          case (sec_opcode) 
	    /* decode secondary opcode*/
            3'd0 : ctrl_out = 5'd8;
            3'd1 : ctrl_out = 5'd9;
            3'd2 : ctrl_out = 5'd10;
            3'd3 : ctrl_out = 5'd11;
            3'd4 : ctrl_out = 5'd12;
            3'd5 : ctrl_out = 5'd13;
            3'd6 : ctrl_out = 5'd14;
            3'd7 : ctrl_out = 5'd15;
          endcase
        end

      endcase
    end else if (alu_op == 2'd1) begin
      ctrl_out = 5'd1;
    end else if (alu_op == 2'd2) begin
      ctrl_out = 5'd0;
    end

  end // always_comb

endmodule

