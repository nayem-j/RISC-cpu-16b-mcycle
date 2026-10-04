// File: alu.sv
// Author: Md. Jannatul Nayem

module alu(
  input  logic [15:0] rs1,
  input  logic [15:0] rs2,
  input  logic [3:0]  ctrl,
  output logic [15:0] rd,
  output logic [7:0]  flags
);

  logic carry_f,sign_f,zero_f;
  
  assign flags[2:0] = {carry_f,sign_f,zero_f};
  /*bits [7:3] are reserved*/

  always_comb begin
    rd = 16'd0;
    carry_f = 1'b0;

    case (ctrl) begin
      4'd0  : {carry_f,rd} = rs1 + rs2;           /*ADD*/
      4'd1  : rd           = rs1 - rs2;           /*SUB*/
      4'd2  : rd           = ~rs1;                /*INVERT*/
      4'd3  : rd           = rs1 << 1;            /*LSL*/
      4'd4  : rd           = rs1 >> 1;            /*LSR*/
      4'd5  : rd           = rs1 & rs2;           /*AND*/
      4'd6  : rd           = rs1 | rs2;           /*OR*/
      4'd7  : rd           = $signed(rs1) < $signed(rs2);   
                                                  /*SLT*/
      4'd8  : rd           = rs1 ^ rs2;           /*XOR*/
      4'd9  : {carry_f,rd} = rs1 + rs2 + carry_f; /*ADC*/
      4'd10 : {carry_f,rd} = rs1 - rs2 - carry_f; /*SBB*/
      4'd11 : rd           = rs1 + 1;             /*INC*/
      4'd12 : rd           = rs1 - 1;             /*DEC*/
      4'd13 : rd           = -rs1;                /*NEG*/
      4'd14 : carry_f      = 1'b0;                /*CLC*/
      4'd15 : carry_f      = 1'b1;                /*STC*/
    endcase

  end

  assign sign_f = rd[15];
  assign zero_f = (rd == 16'd0);

endmodule

