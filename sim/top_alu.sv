
module top_alu();

    logic [15:0] rs1;
    logic [15:0] rs2;
    logic [3:0]  ctrl;
    logic [15:0] rd;
    logic [2:0]  flags;

    alu uut (
        .rs1(rs1),
        .rs2(rs2),
        .ctrl(ctrl),
        .rd(rd),
        .flags(flags)
    );

    initial begin
        // stimulus for the ALU
        rs1 = 16'h0001;
        rs2 = 16'h0002;
        ctrl = 4'b0000; // ADD operation
        #10;
        rs1 = 16'h0003;
        rs2 = 16'h0004;
        ctrl = 4'b0001; // SUB operation
        #10;
        rs1 = 16'h0005;
        rs2 = 16'h0006;
        ctrl = 4'b0010; // INVERT operation
        #10;
        rs1 = 16'h0007;
        rs2 = 16'h0008;
        ctrl = 4'b0011; // LSHIFT operation
        #10;
        // More stimulus for the ALU
        rs1 = 16'h0009;
        rs2 = 16'h000A;
        ctrl = 4'b0100; // RSHIFT operation
        #10;
        rs1 = 16'h000B;
        rs2 = 16'h000C;
        ctrl = 4'b0101; // AND operation
        #10;
        rs1 = 16'h000D;
        rs2 = 16'h000E;
        ctrl = 4'b0110; // OR operation
        #10;
        rs1 = 16'h000F;
        rs2 = 16'h0010;
        ctrl = 4'b0111; // SLT operation
        #10;
        rs1 = 16'h0011;
        rs2 = 16'h0012;
        ctrl = 4'b1000; // XOR operation
        #10;
        rs1 = 16'h0013;
        rs2 = 16'h0014;
        ctrl = 4'b1001; // ADC operation
        #10;
        rs1 = 16'h0015;
        rs2 = 16'h0016;
        ctrl = 4'b1010; // SBB operation
        #10;
        rs1 = 16'h0017;
        rs2 = 16'h0018;
        ctrl = 4'b1011; // INCREMENT operation
        #10;
        rs1 = 16'h0019;
        rs2 = 16'h001A;
        ctrl = 4'b1100; // DECREMENT operation
        #10;
        rs1 = 16'h001B;
        rs2 = 16'h001C;
        ctrl = 4'b1101; // NEGATE operation
        #10;
        rs1 = 16'h001D;
        rs2 = 16'h001E;
        ctrl = 4'b1110; // CLC operation
        #10;
        rs1 = 16'h001F;
        rs2 = 16'h0020;
        ctrl = 4'b1111; // STC operation
        #10;

        $finish;
    end

    initial begin
        $dumpfile("top_alu.vcd");
        $dumpvars(0, top_alu);
    end

endmodule
