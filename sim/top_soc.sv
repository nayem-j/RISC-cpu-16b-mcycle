
module top_soc ();

  bit clk;
  logic rst;

  initial begin
    forever #5 clk = ~clk;
  end

  soc #(
    .MEM_DEPTH(32)
  ) soc_i (
    .clk(clk),
    .rst(rst)
  );

  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
    
    while(1) begin
      @(posedge clk);
      if (soc_i.dmem_access_addr == 16'hFFFF &&
          soc_i.dmem_write_en && soc_i.dmem_write_data[15]) begin
        $display("Simulation finished at time %0t with exit code %0h", $time, soc_i.dmem_write_data[3:0]);
        $finish;
      end
    end
  end

  initial begin
    $dumpfile("top_soc.vcd");
    $dumpvars(0, top_soc);
  end

endmodule
