`timescale 1ns/1ps

module apb_uart_tb;

  // Clock and Reset
  logic clk;
  logic rstn;
  
  initial clk = 0;
  // 100MHz clock (10ns period -> toggle every 5ns)
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

  // UART external pins
  logic rx_i;
  logic tx_o;
  logic event_o;

  // Instantiate the isolated UART RTL
  apb_uart_sv u_uart (
    .CLK     (clk),
    .RSTN    (rstn),
    .PADDR   (paddr),
    .PWDATA  (pwdata),
    .PWRITE  (pwrite),
    .PSEL    (psel),
    .PENABLE (penable),
    .PRDATA  (prdata),
    .PREADY  (pready),
    .PSLVERR (pslverr),
    .rx_i    (rx_i),
    .tx_o    (tx_o),
    .event_o (event_o)
  );

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
    $display("--- Starting Isolated UART Block Test (100MHz) ---");
    
    // Initialize
    rstn = 0;
    rx_i = 1; // Idle high
    paddr = 0; pwdata = 0; pwrite = 0; psel = 0; penable = 0;
    
    #50;
    rstn = 1;
    #50;

    // 1. Configure UART Baud Rate (DLAB = 1)
    $display("Configuring Baud Rate Divisor...");
    apb_write(12'h003, 32'h0000_0083); // LCR = 8'h83 -> DLAB=1, 8N1
    
    // 100MHz adjusted Divisor (Decimal 26 -> 0x001A)
    apb_write(12'h000, 32'h0000_001A); // DLL = divisor low byte
    apb_write(12'h001, 32'h0000_0000); // DLM = divisor high byte

    // 2. Lock Divisor and setup data format (DLAB = 0)
    $display("Configuring LCR for 8-bit data...");
    apb_write(12'h003, 32'h0000_0003); // LCR = 8'h03 -> DLAB=0, 8N1
    
    // 3. Transmit Data
    $display("Writing 'A' (0x41) to THR...");
    apb_write(12'h000, 32'h0000_0041);

    // 4. Wait long enough for the slow serial transmission
    $display("Waiting for transmission...");
    #200000; 

    $display("--- Test Complete ---");
    $finish;
  end

  // Dump waveforms
  initial begin
    $shm_open("uart_block.shm");
    $shm_probe(apb_uart_tb, "AS");
  end

endmodule