// Register map + encodings (CONFIRMED against apb_gpio.sv, PAD_NUM=32). Included inside GpioEnvPkg.
localparam bit [31:0] GPIO_BASE      = 32'h1060_0000;
localparam bit [31:0] GPIO_PADDIR    = 32'h00;
localparam bit [31:0] GPIO_GPIOEN    = 32'h04;
localparam bit [31:0] GPIO_PADIN     = 32'h08;
localparam bit [31:0] GPIO_PADOUT    = 32'h0C;
localparam bit [31:0] GPIO_PADOUTSET = 32'h10;  // reads as 0
localparam bit [31:0] GPIO_PADOUTCLR = 32'h14;  // reads as 0
localparam bit [31:0] GPIO_INTEN     = 32'h18;
localparam bit [31:0] GPIO_INTTYPE0  = 32'h1C;  // pins 0-15,  2 bits/pin packed
localparam bit [31:0] GPIO_INTTYPE1  = 32'h20;  // pins 16-31, 2 bits/pin packed
localparam bit [31:0] GPIO_INTSTATUS = 32'h24;  // clear-on-read
localparam bit [31:0] GPIO_PADCFG0   = 32'h28;  // 4 bits/pin, pins 0-7
localparam bit [31:0] GPIO_PADCFG1   = 32'h2C;
localparam bit [31:0] GPIO_PADCFG2   = 32'h30;
localparam bit [31:0] GPIO_PADCFG3   = 32'h34;
// 0x38..0x6C = pins 32-63 bank: not implemented for PAD_NUM=32 -> write ignored, read 0
localparam bit [31:0] GPIO_UPPER_FIRST = 32'h38;
localparam bit [31:0] GPIO_UPPER_LAST  = 32'h6C;

localparam bit [1:0] GPIO_INT_FALL = 2'b00;
localparam bit [1:0] GPIO_INT_RISE = 2'b01;
localparam bit [1:0] GPIO_INT_BOTH = 2'b10;
localparam bit [1:0] GPIO_INT_NONE = 2'b11;     // matches no event in RTL