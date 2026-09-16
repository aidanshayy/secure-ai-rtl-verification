`timescale 1ns/1ps

module uart_smoke_tb;
  localparam int ADDR_WIDTH = 5;
  localparam int DATA_WIDTH = 32;

  logic clk = 1'b0;
  always #5 clk = ~clk;

  logic rst = 1'b1;
  logic [ADDR_WIDTH-1:0] wb_adr = '0;
  logic [DATA_WIDTH-1:0] wb_dat_i = '0;
  wire [DATA_WIDTH-1:0] wb_dat_o;
  logic wb_we = 1'b0;
  logic wb_stb = 1'b0;
  logic wb_cyc = 1'b0;
  logic [3:0] wb_sel = '0;
  wire wb_ack;
  wire irq;
  wire tx;
  wire rx;
  wire rts;
  wire dtr;

  assign rx = tx;

  uart_top dut (
    .wb_clk_i(clk), .wb_rst_i(rst), .wb_adr_i(wb_adr),
    .wb_dat_i(wb_dat_i), .wb_dat_o(wb_dat_o), .wb_we_i(wb_we),
    .wb_stb_i(wb_stb), .wb_cyc_i(wb_cyc), .wb_ack_o(wb_ack),
    .wb_sel_i(wb_sel), .int_o(irq), .stx_pad_o(tx), .srx_pad_i(rx),
    .rts_pad_o(rts), .cts_pad_i(1'b1), .dtr_pad_o(dtr),
    .dsr_pad_i(1'b1), .ri_pad_i(1'b1), .dcd_pad_i(1'b1)
  );

  task automatic wb_write(input logic [ADDR_WIDTH-1:0] addr,
                          input logic [DATA_WIDTH-1:0] data,
                          input logic [3:0] sel);
    @(negedge clk);
    wb_adr = addr; wb_dat_i = data; wb_sel = sel; wb_we = 1'b1;
    wb_cyc = 1'b1; wb_stb = 1'b1;
    do @(posedge clk); while (!wb_ack);
    @(negedge clk);
    wb_cyc = 1'b0; wb_stb = 1'b0; wb_we = 1'b0; wb_sel = '0;
    repeat (4) @(posedge clk);
  endtask

  task automatic wb_read(input logic [ADDR_WIDTH-1:0] addr,
                         input logic [3:0] sel,
                         output logic [DATA_WIDTH-1:0] data);
    @(negedge clk);
    wb_adr = addr; wb_sel = sel; wb_we = 1'b0;
    wb_cyc = 1'b1; wb_stb = 1'b1;
    do @(posedge clk); while (!wb_ack);
    data = wb_dat_o;
    @(negedge clk);
    wb_cyc = 1'b0; wb_stb = 1'b0; wb_sel = '0;
    repeat (4) @(posedge clk);
  endtask

  logic [DATA_WIDTH-1:0] read_data;
  initial begin
    repeat (3) @(posedge clk);
    rst = 1'b0;

    // Enable FIFO, select 8-N-1, and use a small divisor for a short test.
    wb_write(5'd0, 32'h0000_0100, 4'b0010);
    wb_write(5'd0, 32'h0000_0083, 4'b0001);
    wb_write(5'd0, 32'h0200_0000, 4'b1000);
    wb_write(5'd0, 32'h0000_0000, 4'b0100);
    wb_write(5'd0, 32'h0000_0003, 4'b0001);
    wb_write(5'd0,  32'h5a00_0000, 4'b1000);

    repeat (2500) @(posedge clk);
    wb_read(5'd4, 4'b0100, read_data);
    if (!read_data[16]) $fatal(1, "UART did not receive loopback data; LSR=%h", read_data);
    wb_read(5'd0, 4'b1000, read_data);
    if (read_data[31:24] !== 8'h5a) $fatal(1, "UART loopback mismatch: got %h", read_data[31:24]);

    $display("UART Verilator smoke test passed: received 0x%02x", read_data[31:24]);
    $finish;
  end
endmodule
