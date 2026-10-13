# RISC-style 16-bit CPU

This repository implements a small 16-bit RISC-style CPU in SystemVerilog, together with a simple SoC wrapper, register file, ALU, and memory subsystem for simulation in Vivado XSIM.

The design is intentionally compact and educational: it models the core pieces of a simple CPU datapath, instruction decoding, memory access, and state-based control flow without aiming to be a production processor.

## Features

- 16-bit datapath and registers
- 8-entry general-purpose register file
- Simple arithmetic, logic, shift, compare, and branch operations
- State-based control sequencing across fetch, execute, and store phases
- Instruction memory and data memory with byte-level banking
- SoC-level integration for simulation
- Vivado `xvlog` / `xelab` / `xsim` flow via `Makefile`

## Architecture overview

The top-level design is composed of the following modules:

- `rtl/cpu_16b_mcycle.sv` — main CPU datapath and control logic
- `rtl/soc.sv` — CPU connected to instruction and data memory
- `rtl/reg_file.sv` — general-purpose register bank
- `rtl/alu.sv` — arithmetic and logic unit
- `rtl/alu_ctrl.sv` — ALU operation selection and decoding
- `rtl/i_mem.sv` / `rtl/d_mem.sv` — memory interfaces
- `rtl/i_mem_8_X.sv` / `rtl/d_mem_8_X.sv` — byte-addressable memory banks
- `sim/top_soc.sv` — simulation top module

The CPU is controlled by a small state machine:

- `SETUP`
- `FETCH`
- `EXECUTE`
- `STORAGE`

This sequencing lets the CPU fetch instructions, decode and compute, then write back to registers or memory in a deterministic order.

## Register bank

The register file is implemented in `rtl/reg_file.sv`.

Key details:

- 8 registers total
- each register is 16 bits wide
- read port 1 address: 3 bits
- read port 2 address: 3 bits
- write address: 3 bits
- write enable: `write_en`
- data written on the clock edge when `write_en` is asserted

The implementation is:

```systemverilog
logic [15:0] regs [7:0];
```

So the register bank behaves like a classic small register file with two read ports and one write port.

## ALU

The ALU is implemented in `rtl/alu.sv`.

It accepts:

- `rs1` and `rs2` as 16-bit operands
- a 4-bit `ctrl` signal selected by the ALU controller
- outputs a 16-bit result `rd`
- 3 flag bits: `carry_f`, `sign_f`, and `zero_f`

The flag bus is:

```systemverilog
assign flags = {carry_f, sign_f, zero_f};
```

The supported operations include:

- arithmetic: `ADD`, `SUB`, `ADC`, `SBB`, `INC`, `DEC`, `NEG`
- logic: `INV`, `AND`, `OR`, `XOR`
- shifts: `LSL`, `LSR`
- compare: `SLT`
- flag control: `CLC`, `STC`

The ALU control mapping is produced by `rtl/alu_ctrl.sv`, which decodes the instruction opcode and secondary opcode into the proper ALU operation.

## Memory organization

Memory is implemented as byte-addressable banks and then assembled into 16-bit words.

### Instruction memory

- `rtl/i_mem.sv` instantiates two 8-bit banks:
  - `i_mem_b0`
  - `i_mem_b1`
- each bank uses `i_mem_8_X.sv`
- the full word is reconstructed as a 16-bit output

### Data memory

- `rtl/d_mem.sv` also instantiates two 8-bit banks:
  - `d_mem_b0`
  - `d_mem_b1`
- each bank uses `d_mem_8_X.sv`
- byte writes are controlled by `byte_sel`

This is a simple banked-memory organization:

- low byte from one bank
- high byte from the second bank
- the CPU reads or writes a 16-bit word by combining the two banks

The banked memory modules read from files such as:

- `i_mem_b0.mem`
- `i_mem_b1.mem`
- `d_mem_b0.mem`
- `d_mem_b1.mem`

The memory modules use the lower address bits to keep the byte lane aligned, effectively forming a word-oriented memory out of two byte memories.

## Instruction set and operations

The instruction definitions are declared in `pkg/defs.sv` and include:

- memory access: `LOAD`, `STORE`
- arithmetic: `ADD`, `SUB`, `ADC`, `SBB`, `INC`, `DEC`, `NEG`
- bitwise/logical: `INV`, `AND`, `OR`, `XOR`, `CLC`, `STC`
- shifts: `LSL`, `LSR`
- comparisons: `SLT`, `BEQ`, `BNE`, `BLT`, `BGT`
- control flow: `JUMP`
- no-op: `NOP`

The CPU extracts fields such as opcodes, register addresses, and immediate values from the 16-bit instruction word and uses them in the fetch/execute/store sequence.

## Control flow

The control path in `rtl/cpu_16b_mcycle.sv` is implemented directly as a state-based finite-state machine in HDL.

The states are:

- `SETUP`: initialize memory interface and reset control signals
- `FETCH`: read the next instruction and set up the next operation
- `EXECUTE`: perform ALU or memory operation depending on opcode
- `STORAGE`: commit the result, write memory/register, and update the PC

This makes the CPU easy to reason about in HDL while still reflecting a classic CPU execution flow.

## Repository layout

```text
.
├── Makefile
├── README.md
├── files.f
├── LICENSE
├── pkg/
│   └── defs.sv
├── rtl/
│   ├── alu.sv
│   ├── alu_ctrl.sv
│   ├── cpu_16b_mcycle.sv
│   ├── d_mem.sv
│   ├── d_mem_8_X.sv
│   ├── i_mem.sv
│   ├── i_mem_8_X.sv
│   ├── reg_file.sv
│   └── soc.sv
├── sim/
│   └── top_soc.sv
├── d_mem_b0.mem
├── d_mem_b1.mem
├── i_mem_b0.mem
├── i_mem_b1.mem
└── .gitignore (if present in your checkout)
```

## Simulation and build flow

This repository uses the Vivado simulator toolchain. The build is configured through `Makefile` and the source list in `files.f`.

### Required toolchain

- Xilinx Vivado / XSIM
- `xvlog`
- `xelab`
- `xsim`

### Typical commands

From the repository root:

```bash
make compile
make TOP=top_soc elaborate
make TOP=top_soc run
make TOP=top_soc gui
make clean
```

The correct simulator entry point for this project is `top_soc`, not `tb_top`.

```bash
make TOP=top_soc run
```

This command was verified in this repository and completed successfully with exit code 0.

## Example run

```bash
cd RISC-cpu-16b-mcycle
make TOP=top_soc run
```

This launches the SoC testbench, drives the clock and reset, executes the initialized program image, and exits after the fixed simulation time.

## Notes

- This project is intentionally compact and educational rather than production-oriented.
- The design is best suited for learning CPU datapath structure, control sequencing, and simulation workflows.
- A waveform file is generated during simulation (`top_soc.vcd`) and can be inspected with waveform tools.

## License

This project is released under the terms of the Apache V2.0 License. See `LICENSE` for details.

## Contributing

Improvements to the CPU, decode logic, documentation, or testbench quality are welcome.
