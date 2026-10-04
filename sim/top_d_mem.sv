
module top_d_mem();

    parameter DEPTH = 256; // Example depth, adjust as needed

    logic                     clk;
    logic                     rst;
    logic [$clog2(DEPTH):0]   mem_access_addr;
    logic [1:0]               byte_sel;
    logic                     write_en;
    logic [15:0]              write_data;
    logic                     mem_read;
    logic [15:0]              read_data;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    d_mem #(
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .mem_access_addr(mem_access_addr),
        .byte_sel(byte_sel),
        .write_en(write_en),
        .write_data(write_data),
        .mem_read(mem_read),
        .read_data(read_data)
    );

    initial begin
        rst = 1;
        mem_access_addr = 0;
        byte_sel = 0;
        write_en = 0;
        write_data = 0;
        mem_read = 0;
        #10;
        rst = 0;
        // Stimulus
        mem_access_addr = 4;
        byte_sel = 2'b11;
        write_en = 1;
        write_data = 16'hABCD;
        mem_read = 0;
        #10;
        write_en = 0;
        mem_read = 1;
        #10;
        // Additional stimulus example
        mem_access_addr = 8;
        byte_sel = 2'b01;
        write_en = 1;
        write_data = 16'h1234;
        mem_read = 0;
        #10;
        write_en = 0;
        mem_read = 1;
        #10;
        // End of stimulus
        $finish;
    end

    initial begin
        $dumpfile("top_d_mem.vcd");
        $dumpvars(0, top_d_mem);
    end

endmodule