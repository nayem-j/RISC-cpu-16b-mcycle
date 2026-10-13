
module top_soc ();

  bit clk;
  logic rst;

  initial begin
    forever #5 clk = ~clk;
  end

  soc #(
    .MEM_DEPTH(32)
  ) u_soc (
    .clk(clk),
    .rst(rst)
  );

  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
    
    repeat (200) @(posedge clk);
    $finish;
  end

  initial begin
    $dumpfile("top_soc.vcd");
    $dumpvars(0, top_soc);
  end

endmodule
