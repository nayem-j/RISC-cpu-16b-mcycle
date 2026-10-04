
module top_alu_ctrl();

    logic [1:0] alu_op;
    logic [3:0] opcode;
    logic [2:0] sec_opcode;
    logic [4:0] ctrl_out;

    alu_ctrl uut (
        .alu_op(alu_op),
        .opcode(opcode),
        .sec_opcode(sec_opcode),
        .ctrl_out(ctrl_out)
    );

    initial begin
        // stimulus for the ALU control
        alu_op = 2'b00;
        opcode = 4'b0000;
        sec_opcode = 3'b000;
        #10;
        alu_op = 2'b01;
        opcode = 4'b0001;
        sec_opcode = 3'b001;
        #10;
        alu_op = 2'b10;
        opcode = 4'b0010;
        sec_opcode = 3'b010;
        #10;
        alu_op = 2'b11;
        opcode = 4'b0011;
        sec_opcode = 3'b011;
        #10;
        alu_op = 2'b00;
        opcode = 4'b1111;
        sec_opcode = 3'b011;
        #10;
        $finish;
    end

    initial begin
        $dumpfile("top_alu_ctrl.vcd");
        $dumpvars(0, top_alu_ctrl);
    end

endmodule