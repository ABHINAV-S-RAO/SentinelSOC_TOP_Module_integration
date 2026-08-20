`timescale 1ns/1ps

module apb_qspi_tb;

  // Clock and Reset (100MHz target)
  logic clk;
  logic rstn;
  
  initial clk = 0;
  always #5 clk = ~clk; 

  // APB Bus Signals
  logic [11:0] paddr;
  logic [31:0] pwdata;
  logic        pwrite;
  logic        psel;
  logic        penable;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  // SPI/QSPI External Pins
  logic [1:0] events_o;
  logic       spi_clk;
  logic       spi_csn0, spi_csn1, spi_csn2, spi_csn3;
  logic [1:0] spi_mode;
  logic       spi_sdo0, spi_sdo1, spi_sdo2, spi_sdo3;
  logic       spi_sdi0, spi_sdi1, spi_sdi2, spi_sdi3;

  // Instantiate the isolated QSPI RTL
  apb_spi_master u_qspi (
    .HCLK     (clk),
    .HRESETn  (rstn),
    .PADDR    (paddr),
    .PWDATA   (pwdata),
    .PWRITE   (pwrite),
    .PSEL     (psel),
    .PENABLE  (penable),
    .PRDATA   (prdata),
    .PREADY   (pready),
    .PSLVERR  (pslverr),
    .events_o (events_o),
    .spi_clk  (spi_clk),
    .spi_csn0 (spi_csn0),
    .spi_csn1 (spi_csn1),
    .spi_csn2 (spi_csn2),
    .spi_csn3 (spi_csn3),
    .spi_mode (spi_mode),
    .spi_sdo0 (spi_sdo0),
    .spi_sdo1 (spi_sdo1),
    .spi_sdo2 (spi_sdo2),
    .spi_sdo3 (spi_sdo3),
    .spi_sdi0 (spi_sdi0), // Tie inputs low for now
    .spi_sdi1 (spi_sdi1),
    .spi_sdi2 (spi_sdi2),
    .spi_sdi3 (spi_sdi3)
  );

  // Tie off floating inputs
  assign spi_sdi0 = 1'b0;
  assign spi_sdi1 = 1'b0;
  assign spi_sdi2 = 1'b0;
  assign spi_sdi3 = 1'b0;

  // Simple APB Write Task
  task apb_write(input logic [11:0] addr, input logic [31:0] data);
    @(posedge clk);
    paddr   = addr;
    pwdata  = data;
    pwrite  = 1'b1;
    psel    = 1'b1;
    penable = 1'b0;
    
    @(posedge clk);
    penable = 1'b1; // Access phase
    
    @(posedge clk);
    while (!pready) @(posedge clk);
    
    psel    = 1'b0;
    penable = 1'b0;
  endtask

    // Test Sequence
    initial begin
    $display("--- Starting Isolated QSPI Block Test ---");
    
    // Initialize
    rstn = 0;
    paddr = 0; pwdata = 0; pwrite = 0; psel = 0; penable = 0;
    
    #50;
    rstn = 1;
    #50;

    // 1. Configure Clock Divider (Offset 0x04)
    // Divide 100MHz clock down so we can easily see it in the waveform
    $display("Configuring Clock Divider...");
    apb_write(12'h004, 32'h0000_0002); 
    
    // 2. Configure Transfer Lengths (Offset 0x10)
    // Format: [31:16] Data Len | [15:14] 0 | [13:8] Addr Len | [7:6] 0 | [5:0] Cmd Len
    // We will send 32 bits of data (0x0020), 0 addr, 0 cmd.
    $display("Configuring SPI Lengths (32 bits data)...");
    apb_write(12'h010, 32'h0020_0000); 

    // 3. Load the TX FIFO (Offset 0x18)
    // Writing a recognizable hex pattern: 0xDEADBEEF
    $display("Loading TX FIFO with 0xDEADBEEF...");
    apb_write(12'h018, 32'hDEAD_BEEF); 
    
    // 4. Trigger the Quad-Write Transfer (Offset 0x00)
    // Bit [3] = spi_qwr (Quad Write Enable)
    // Bits [11:8] = spi_csreg (Chip Select 0)
    $display("Triggering QSPI Write on CS0...");
    apb_write(12'h000, 32'h0000_0008); 

    $display("Waiting for transmission...");
    #5000; 

    $display("--- Test Complete ---");
    $finish;
  end

  // Dump waveforms
  initial begin
    $shm_open("qspi_block.shm");
    $shm_probe(apb_qspi_tb, "AS");
  end

endmodule