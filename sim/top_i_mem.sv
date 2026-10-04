
module top_i_mem();
    parameter DEPTH = 256; // Example depth, adjust as needed
    logic                     clk;
    logic                     rst;
    logic [$clog2(DEPTH):0]   mem_access_addr;
    logic                     mem_read;
    logic [15:0]              read_data;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    i_mem #(
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .mem_access_addr(mem_access_addr),
        .mem_read(mem_read),
        .read_data(read_data)
    );

    initial begin
        rst = 1;
        mem_access_addr = 0;
        mem_read = 0;
        #10;
        rst = 0;
        // Stimulus
        mem_access_addr = 4;
        mem_read = 1;
        #10;
        // Additional stimulus example
        mem_access_addr = 8;
        mem_read = 1;
        #10;
        // End of stimulus
        $finish;
    end

    initial begin
        $dumpfile("top_i_mem.vcd");
        $dumpvars(0, top_i_mem);
    end

endmodule
