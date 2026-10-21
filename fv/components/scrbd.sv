import defs::*;

class scrbd;

  virtual cpu_intf intf;
  mailbox mbx;
  trnxt trn;

  int err_cnt, total;

  logic pending_commit;
  logic [15:0] exp_pc_next;
  logic exp_reg_write;
  logic exp_dmem_write;
  logic [15:0] exp_dmem_addr;
  logic [15:0] exp_dmem_wdata;
  logic [1:0]  exp_dmem_bsel;

  function automatic logic is_alu_op(input logic [3:0] op);
    return (op > 4'd1) && ((op < 4'd10) || (op == 4'd15));
  endfunction

  function automatic logic [15:0] alu_model(
    input logic [3:0] op,
    input logic [2:0] sec_op,
    input logic [15:0] rs1,
    input logic [15:0] rs2,
    input logic [2:0] flags_in
  );
    logic [16:0] tmp;

    tmp = 17'd0;

    case (op)
      4'd2: begin // ADD
        tmp = rs1 + rs2;
        return tmp[15:0];
      end
      4'd3: return rs1 - rs2;         // SUB
      4'd4: return ~rs1;              // INV
      4'd5: return rs1 << 1;          // LSL
      4'd6: return rs1 >> 1;          // LSR
      4'd7: return rs1 & rs2;         // AND
      4'd8: return rs1 | rs2;         // OR
      4'd9: return $signed(rs1) < $signed(rs2); // SLT
      4'd15: begin
        case (sec_op)
          3'd0: return rs1 ^ rs2;     // XOR
          3'd1: begin                 // ADC
            tmp = rs1 + rs2 + flags_in[2];
            return tmp[15:0];
          end
          3'd2: begin                 // SBB
            tmp = rs1 - rs2 - flags_in[2];
            return tmp[15:0];
          end
          3'd3: return rs1 + 16'd1;   // INC
          3'd4: return rs1 - 16'd1;   // DEC
          3'd5: return -rs1;          // NEG
          3'd6: return 16'd0;         // CLC
          3'd7: return 16'd0;         // STC
          default: return 16'd0;
        endcase
      end
      default: return 16'd0;
    endcase
  endfunction

  function automatic logic [2:0] flags_model(
    input logic [3:0] op,
    input logic [2:0] sec_op,
    input logic [15:0] rs1,
    input logic [15:0] rs2,
    input logic [2:0] flags_in
  );
    logic [16:0] tmp;
    logic [15:0] rd;
    logic carry_f;

    rd = alu_model(op, sec_op, rs1, rs2, flags_in);
    carry_f = 1'b0;
    tmp = 17'd0;

    case (op)
      4'd2: begin
        tmp = rs1 + rs2;
        carry_f = tmp[16];
      end
      4'd15: begin
        case (sec_op)
          3'd1: begin
            tmp = rs1 + rs2 + flags_in[2];
            carry_f = tmp[16];
          end
          3'd2: begin
            tmp = rs1 - rs2 - flags_in[2];
            carry_f = tmp[16];
          end
          3'd6: carry_f = 1'b0; // CLC
          3'd7: carry_f = 1'b1; // STC
          default: carry_f = 1'b0;
        endcase
      end
      default: carry_f = 1'b0;
    endcase

    return {carry_f, rd[15], (rd == 16'd0)};
  endfunction

  task automatic compare_bit(
    input string tag, 
    input logic got, 
    input logic exp
  );
    if (got !== exp) begin
      err_cnt++;
      $error("[%s] mismatch @%0t: got=%0b exp=%0b", tag, $time, got, exp);
    end
  endtask

  task automatic compare_u16(
    input string tag, 
    input logic [15:0] got, 
    input logic [15:0] exp
  );
    if (got !== exp) begin
      err_cnt++;
      $error("[%s] mismatch @%0t: got=0x%04h exp=0x%04h", tag, $time, got, exp);
    end
  endtask

  task automatic compare_u3(
    input string tag, 
    input logic [2:0] got, 
    input logic [2:0] exp
  );
    if (got !== exp) begin
      err_cnt++;
      $error("[%s] mismatch @%0t: got=0x%0h exp=0x%0h", tag, $time, got, exp);
    end
  endtask

  function new(virtual cpu_intf intf, mailbox mbx);
    $display("Scoreboard instance created at time %0t", $time);
    this.intf = intf;
    this.mbx = mbx;
    this.err_cnt = 0;
    this.total = 0;
    this.pending_commit = 1'b0;

    this.exp_pc_next = 16'd0;
    this.exp_reg_write = 1'b0;
    this.exp_dmem_write = 1'b0;
    this.exp_dmem_addr = 16'd0;
    this.exp_dmem_wdata = 16'd0;
    this.exp_dmem_bsel = 2'd0;
  endfunction

  task check(); // Main scoreboard checking task

    logic [3:0] op;
    logic [2:0] sec_op;
    logic [5:0] imm_mc; 
    logic [11:0] imm_j;
    logic [15:0] exp_alu_rd;
    logic [2:0] exp_flags;

    forever begin
      mbx.get(trn);
      $display("Scoreboard received transaction at time %0t", $time);

      op = trn.debug_fetched[15:12];
      sec_op = trn.debug_fetched[2:0];
      imm_mc = trn.debug_fetched[5:0];
      imm_j = trn.debug_fetched[11:0];

      // Check commit-stage effects one cycle after STORAGE
      if (pending_commit && trn.debug_state == SETUP) begin
        compare_u16("PC update", trn.debug_pc, exp_pc_next);
        compare_bit("Reg write enable", trn.debug_reg_write_en, exp_reg_write);
        compare_bit("Dmem write enable", trn.dmem_write_en, exp_dmem_write);

        if (exp_dmem_write) begin
          compare_u16("Dmem address", trn.dmem_access_addr, exp_dmem_addr);
          compare_u16("Dmem write data", trn.dmem_write_data, exp_dmem_wdata);
          if (trn.dmem_byte_sel !== exp_dmem_bsel) begin
            err_cnt++;
            $error("[Dmem byte_sel] mismatch @%0t: got=0x%0h exp=0x%0h",
              $time, trn.dmem_byte_sel, exp_dmem_bsel);
          end
        end

        pending_commit = 1'b0;
      end

      // Check EXECUTE results for ALU-class instructions
      if (trn.debug_state == EXECUTE && is_alu_op(op)) begin
        exp_alu_rd = alu_model(op, sec_op, trn.debug_rs1_data, trn.debug_rs2_data, trn.debug_flags);
        exp_flags = flags_model(op, sec_op, trn.debug_rs1_data, trn.debug_rs2_data, trn.debug_flags);

        compare_u16("ALU result->rd_data", trn.debug_rd_data, exp_alu_rd);
        compare_u3("ALU flags", trn.debug_flags, exp_flags);
      end

      // Decode STORAGE behavior and defer observable checks to next SETUP
      if (trn.debug_state == STORAGE) begin
        exp_pc_next = trn.debug_pc + 16'd2;
        exp_reg_write = 1'b0;
        exp_dmem_write = 1'b0;
        exp_dmem_addr = 16'd0;
        exp_dmem_wdata = 16'd0;
        exp_dmem_bsel = 2'd0;

        if (op == 4'd1) begin // STORE
          exp_dmem_write = 1'b1;
          exp_dmem_addr = trn.debug_rs1_data + imm_mc;
          exp_dmem_wdata = trn.debug_rs2_data;
          exp_dmem_bsel = 2'd3;
        end else if (op == 4'd0) begin // LOAD
          exp_reg_write = 1'b1;
        end else if (op > 4'd1 && op < 4'd15) begin
          if (op > 4'd9 && op < 4'd15) begin
            case (op)
              4'd10: exp_pc_next = {trn.debug_pc[15:13], imm_j << 1};

              4'd11: exp_pc_next = (trn.debug_rs1_data == trn.debug_rs2_data) ?
                (trn.debug_pc + 16'd2 + (imm_mc << 1)) : (trn.debug_pc + 16'd2);
              
              4'd12: exp_pc_next = (trn.debug_rs1_data != trn.debug_rs2_data) ?
                (trn.debug_pc + 16'd2 + (imm_mc << 1)) : (trn.debug_pc + 16'd2);
              
              4'd13: exp_pc_next = ($signed(trn.debug_rs1_data) < $signed(trn.debug_rs2_data)) ?
                (trn.debug_pc + 16'd2 + (imm_mc << 1)) : (trn.debug_pc + 16'd2);
              
              4'd14: exp_pc_next = ($signed(trn.debug_rs1_data) > $signed(trn.debug_rs2_data)) ?
                (trn.debug_pc + 16'd2 + (imm_mc << 1)) : (trn.debug_pc + 16'd2);
              
              default: exp_pc_next = trn.debug_pc + 16'd2;
            endcase
          end else begin
            exp_reg_write = 1'b1;
          end
        end
        pending_commit = 1'b1;
      end
      total++;
    end
  endtask

  task report(); // Report scoreboard status
    $display("\033[38;5;208mScoreboard report at time %0t\033[0m", $time);
    $display("\033[38;5;208mErrors %0d, total transactions %0d\033[0m", err_cnt, total);
  endtask

endclass : scrbd