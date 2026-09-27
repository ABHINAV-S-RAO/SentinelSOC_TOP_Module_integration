// qspi_flash_model.sv -- minimal SPI flash stub (CSN tie-off model)
// The debugger TB doesn't exercise QSPI. This module exists only so
// basic_soc_top's spi_* ports have something to elaborate against.
// It ignores all inputs and drives sdi as 0.
`timescale 1ns/1ps
module qspi_flash_model (
  input  logic       spi_clk_i,
  input  logic [3:0] spi_csn_i,
  input  logic [1:0] spi_mode_i,
  input  logic [3:0] spi_sdo_i,
  output logic [3:0] spi_sdi_o
);
  assign spi_sdi_o = 4'h0;
endmodule