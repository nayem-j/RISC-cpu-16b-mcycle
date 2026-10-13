// File: cpu_16b_mcycle.sv
// Author: Md. Jannatul Nayem

module cpu_16b_mcycle #(
  parameter                          MEM_DEPTH = 1024
)
(
  // clock and reset
  input  logic                       clk,
  input  logic                       rst,

  // memory interfaces
  output logic [$clog2(MEM_DEPTH):0] imem_access_addr,
  output logic                       imem_read,
  input  logic [15:0]                imem_read_data,

  output logic [$clog2(MEM_DEPTH):0] dmem_access_addr,
  output logic [1:0]                 dmem_byte_sel,
  output logic                       dmem_write_en,
  output logic [15:0]                dmem_write_data,
  output logic                       dmem_read,
  input  logic [15:0]                dmem_read_data
);

typedef enum logic [1:0] {
  SETUP,   // IN SETUP STATE
  FETCH,   // FETCH + DECODE
  EXECUTE, // EXECUTE / LOAD
  STORAGE  // WRITE TO MEM OR REG + PC UPDATE
} state_t;

state_t     st, st_next;

reg  [15:0] pc;
reg  [15:0] fetched;
wire [3:0]  op;
wire [2:0]  sec_op;
wire [5:0]  imm_mc;
wire [11:0] imm_j;

wire [4:0]  alu_ctrl;
reg  [1:0]  alu_op;
wire [15:0] alu_result;
wire [2:0]  alu_flags;
reg  [2:0]  flags;

wire [2:0]  rs1_addr, rs2_addr;
wire [2:0]  rd_addr;
wire [15:0] rs1_data, rs2_data;
reg  [15:0] rd_data;
reg         reg_write_en;

assign op       = fetched[15:12];
assign sec_op   = fetched[2:0];
assign imm_mc   = fetched[5:0];
assign imm_j    = fetched[11:0];
assign rs1_addr = fetched[11:9];
assign rs2_addr = fetched[8:6];
assign rd_addr  = (op == 4'd0 && alu_op == 2'd2) ?
  rs2_addr : fetched[5:3];

// state register
always_ff @(posedge clk) 
begin

  if (rst) begin
    st <= SETUP;
  end else begin
    st <= st_next;
  end

end

// next state decoder
always_comb 
begin

  st_next = st;

  case (st)

    SETUP: begin
      st_next = FETCH;
    end

    FETCH: begin
      st_next = EXECUTE;
    end

    EXECUTE: begin
      st_next = STORAGE;
    end

    STORAGE: begin
      st_next = SETUP;
    end

    default: st_next = st;
  endcase

end

always_ff @(posedge clk) 
begin

  if(rst) begin
    pc               <= 16'd0;
    fetched          <= 16'd0;

    imem_access_addr <= 0;
    imem_read        <= 1'b0;
    dmem_access_addr <= 0;
    dmem_byte_sel    <= 2'd0;
    dmem_write_en    <= 1'b0;
    dmem_write_data  <= 16'd0;
    dmem_read        <= 1'b0;
    
    alu_op           <= 2'd0;
    rd_data          <= 16'd0;
    flags            <= 3'd0;

    reg_write_en     <= 1'b0;
  end

  else if (st == SETUP) begin
    imem_access_addr <= pc;
    imem_read        <= 1'b1;
    reg_write_en     <= 1'b0;
  end // ~SETUP

  else if (st == FETCH) begin
    
    fetched <= imem_read_data;
    if((op > 4'd9 && op < 4'd15) || op < 4'd2) begin
      if(op == 4'd0) begin
        dmem_access_addr <= rs1_data + imm_mc;
        dmem_read        <= op == 4'd1;
        dmem_write_en    <= op == 4'd0;
        alu_op           <= 2'd2;
      end
      else if (op == 4'd1) alu_op <= 2'd1;
      else alu_op <= 2'd3;
    end
    else begin
      alu_op  <= 2'd0;
    end
  end // ~FETCH

  else if (st == EXECUTE) begin
    if((op > 4'd9 && op < 4'd15) || op < 4'd2) begin
      if(op == 4'd0) begin
        rd_data   <= dmem_read_data;
        dmem_read <= 1'b1; /* May've kept 0*/
      end
    end
    else begin
      rd_data <= alu_result;
      flags   <= alu_flags;
    end
  end // ~EXECUTE

  else if (st == STORAGE) begin

    if(op == 4'd1) begin
      dmem_access_addr <= rs1_data + imm_mc;
      dmem_byte_sel    <= 2'd3;
      dmem_write_en    <= 1'b1;
      dmem_write_data  <= rs2_data;
      dmem_read        <= 1'b0;

    end else if (op == 4'd0) begin
      reg_write_en     <= 1'b1;

    end else if (op > 4'd1 && op < 4'd15) begin
      if(op > 4'd9 && op < 4'd15) begin
        case (op)
          4'd10: begin /* JUMP*/
            pc <= {pc[15:13], imm_j << 1};
          end
          4'd11: begin /* BEQ */      
            pc <= rs1_data == rs2_data ? 
                pc + 16'd2 + (imm_mc << 1) : pc + 16'd2;
          end
          4'd12: begin /* BNE*/
            pc <= rs1_data != rs2_data ? 
                pc + 16'd2 + (imm_mc << 1) : pc + 16'd2;
          end
          4'd13: begin /* BLT*/
            pc <= $signed(rs1_data) < $signed(rs2_data) ? 
                pc + 16'd2 + (imm_mc << 1) : pc + 16'd2;
          end
          4'd14: begin /* BGT*/
            pc <= $signed(rs1_data) > $signed(rs2_data) ? 
                pc + 16'd2 + (imm_mc << 1) : pc + 16'd2;
          end
          default: pc <= pc + 16'd2;
        endcase
      end else reg_write_en <= 1'b1;
    end

    pc <= pc + 16'd2;
  end // ~STORAGE

end


// ALU controller instance
alu_ctrl alu_ctr_i(
  .alu_op(alu_op),
  .opcode(op),
  .sec_opcode(sec_op),
  .ctrl_out(alu_ctrl)
);


// ALU instance
alu alu_i (
  .rs1(rs1_data),
  .rs2(rs2_data),
  .ctrl(alu_ctrl[3:0]),
  .rd(alu_result),
  .flags(alu_flags)
);

// register file instance
reg_file regs_i (
  .clk(clk),
  .rst(rst),
  .read_addr1(rs1_addr),
  .read_addr2(rs2_addr),
  .write_addr(rd_addr),
  .write_en(reg_write_en),
  .write_data(rd_data),
  .read_data1(rs1_data),
  .read_data2(rs2_data)
);

endmodule
