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

  // Variable to store APB read results
  logic [31:0] read_data;

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
    .spi_sdi0 (spi_sdi0),
    .spi_sdi1 (spi_sdi1),
    .spi_sdi2 (spi_sdi2),
    .spi_sdi3 (spi_sdi3)
  );

  // --- Hardware Loopback for RX Testing ---
  assign spi_sdi0 = spi_sdo0;
  assign spi_sdi1 = spi_sdo0;
  assign spi_sdi2 = spi_sdo2;
  assign spi_sdi3 = spi_sdo3;

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

  // Simple APB Read Task
  task apb_read(input logic [11:0] addr, output logic [31:0] data);
    @(posedge clk);
    paddr   = addr;
    pwrite  = 1'b0; // Read operation
    psel    = 1'b1;
    penable = 1'b0;
    
    @(posedge clk);
    penable = 1'b1; // Access phase
    
    @(posedge clk);
    while (!pready) @(posedge clk);
    
    data    = prdata; // Capture the incoming read data
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

    // --- TX TEST ---
    // 1. Configure Clock Divider (Offset 0x04)
    $display("Configuring Clock Divider...");
    apb_write(12'h004, 32'h0000_0002); 
    
    // 2. Configure Transfer Lengths (Offset 0x10)
    $display("Configuring SPI Lengths (32 bits data)...");
    apb_write(12'h010, 32'h0020_0000); 

    // 3. Load the TX FIFO (Offset 0x18)
    $display("Loading TX FIFO with 0xDEADBEEF...");
    apb_write(12'h018, 32'hDEAD_BEEF); 
    
    // 4. Trigger the Quad-Write Transfer (Offset 0x00)
    $display("Triggering QSPI Write on CS0...");
    apb_write(12'h000, 32'h0000_0008); 

    $display("Waiting for transmission...");
    #5000; 

    // --- NEW RX LOOPBACK TEST ---
    $display("--- Starting RX Loopback Test ---");

    // Set TX Length to 32 (0x0020) AND RX Length to 32 (0x0020)
    $display("Configuring SPI Lengths for TX and RX...");
    apb_write(12'h010, 32'h0020_0020);
    
    $display("Loading TX FIFO with 0xCAFEBABE...");
    apb_write(12'h018, 32'hCAFE_BABE); 
    
    // Trigger Standard Full-Duplex SPI Transfer (Bit [0] = spi_txrx)
    // This forces the module to transmit and receive at the exact same time
    $display("Triggering Full-Duplex TX/RX on CS0...");
    apb_write(12'h000, 32'h0000_0003); 

    $display("Waiting for loopback transmission...");
    #5000; 

    // Read the RX FIFO (Offset 0x20 in the PULP SPI IP)
    $display("Reading RX FIFO via APB...");
    apb_read(12'h020, read_data); 
    
    if (read_data == 32'hCAFE_BABE) begin
        $display("SUCCESS: RX FIFO Loopback passed! Data matched.");
    end else begin
        $display("ERROR: RX FIFO mismatch. Expected 0xCAFEBABE, got 0x%h", read_data);
    end

    $display("--- Test Complete ---");
    $finish;
  end

  // Dump waveforms
  initial begin
    $shm_open("qspi_block.shm");
    $shm_probe(apb_qspi_tb, "AS");
  end

endmodule