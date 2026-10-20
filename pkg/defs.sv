// File: defs.sv
// Author: Md. Jannatul Nayem

package defs;
  
  typedef enum logic [1:0] {
    SETUP,   // IN SETUP STATE
    FETCH,   // FETCH + DECODE
    EXECUTE, // EXECUTE / LOAD
    STORAGE  // WRITE TO MEM OR REG 
             // + PC UPDATE
  } state_t;
  
  // typedef enum logic [5:0] {
  //   LOAD,
  //   STORE,

  //   ADD,
  //   SUB,
  //   INV,
  //   LSL,
  //   LSR,
  //   AND,
  //   OR, 
  //   SLT,

  //   JUMP,  
  //   BEQ,  
  //   BNE,  
  //   BLT,  
  //   BGT,

  //   XOR,
  //   ADC,
  //   SBB,
  //   INC,
  //   DEC,
  //   NEG,
  //   CLC,
  //   STC,
    
  //   NOP
  // } op_t;
  
  // typedef struct {
  //   op_t         op;
  //   logic [2:0]  rs1;
  //   logic [2:0]  rs2;
  //   logic [2:0]  rd;
  //   logic [11:0] imm;
  // } instr_t;
  
  // typedef struct {
  //   logic carry_f;
  //   logic sign_f;
  //   logic zero_f;
  // } flags_t;

endpackage : defs
