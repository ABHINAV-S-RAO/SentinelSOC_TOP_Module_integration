`timescale 1ns/1ps

module apb_uart_tb;

  // Clock and Reset
  logic clk;
  logic rstn;
  
  initial clk = 0;
  always #10 clk = ~clk; // 50MHz clock

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
    $display("--- Starting Isolated UART Block Test ---");
    
    // Initialize
    rstn = 0;
    rx_i = 1; // Idle high
    paddr = 0; pwdata = 0; pwrite = 0; psel = 0; penable = 0;
    
    #50;
    rstn = 1;
    #50;

    // 1. Configure UART: Line Control Register (LCR offset 3)
    // Write 8'h03 to set 8-bit word length, 1 stop bit, no parity
    $display("Configuring LCR for 8-bit data...");
    apb_write(12'h003, 32'h0000_0003);
    
    // 2. Transmit Data: Transmit Holding Register (THR offset 0)
    // Write character 'A' (0x41)
    $display("Writing 'A' (0x41) to THR...");
    apb_write(12'h000, 32'h0000_0041);

    // 3. Wait and observe TX line
    $display("Waiting for transmission...");
    #20000; 

    $display("--- Test Complete ---");
    $finish;
  end

  // Dump waveforms
  initial begin
    $shm_open("uart_block.shm");
    $shm_probe(apb_uart_tb, "AS");
  end

endmodule