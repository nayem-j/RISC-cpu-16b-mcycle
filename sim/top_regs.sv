
module top_regs();

    logic        clk;
    logic        rst;
    logic [2:0]  read_addr1;
    logic [2:0]  read_addr2;
    logic [2:0]  write_addr;
    logic        write_en;
    logic [15:0] write_data;
    logic [15:0] read_data1;
    logic [15:0] read_data2;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg_file uut (
        .clk(clk),
        .rst(rst),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_en(write_en),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        // stimulus for the register file
        rst = 1;
        write_en = 0;
        #10;
        rst = 0;
        write_en = 1;
        write_addr = 3'b001;
        write_data = 16'hABCD;
        #10;
        write_addr = 3'b010;
        write_data = 16'h1234;
        #10;
        write_en = 0;
        write_addr = 3'b001;
        write_data = 16'hFFFF;
        #10;
        read_addr1 = 3'b001;
        read_addr2 = 3'b010;
        #10;
        $finish;
    end

    initial begin
        $dumpfile("top_regs.vcd");
        $dumpvars(0, top_regs);
    end

endmodule