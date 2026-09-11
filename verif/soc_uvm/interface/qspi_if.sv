`ifndef QSPI_IF_SV
`define QSPI_IF_SV

interface qspi_if;
  logic       spi_clk;
  logic       spi_csn0;
  logic [1:0] spi_mode;
  logic       spi_sdo0, spi_sdo1, spi_sdo2, spi_sdo3;
  logic       spi_sdi0, spi_sdi1, spi_sdi2, spi_sdi3;
endinterface

`endif