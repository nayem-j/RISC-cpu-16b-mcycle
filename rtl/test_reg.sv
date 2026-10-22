
module test_reg #(
  parameter            START_ADDRESS = 16'hFFFF
) 
(
  input  logic         clk,
  input  logic         rst,
  input  logic [15:0]  access_addr,
  input  logic         write_en,
  input  logic [15:0]  write_data,
  input  logic         read,
  output logic [15:0]  read_data
);

  // Internal register to hold the test value
  logic [15:0] test_value;

  // Read logic
  assign read_data = (access_addr == START_ADDRESS && read) ?
   test_value : 16'h0000;

  // Write logic
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      test_value <= 16'h0000;
    end else if (access_addr == START_ADDRESS && write_en) begin
      test_value <= write_data;
    end
  end

endmodule
