// Library - PPCU_VLSI_RISCV, Cell - pads_in, View - schematic
// LAST TIME SAVED: Apr  6 13:28:29 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns 
`ifdef KMIE_IMPLEMENT_ASIC

module pads_in ( btn_core, clk_core, rst_n_core, spi_miso_core,
     uart_sin_core, btn, clk, rst_n, spi_miso, uart_sin );

output  clk_core, rst_n_core, spi_miso_core, uart_sin_core;

input  clk, rst_n, spi_miso, uart_sin;

output [3:0]  btn_core;

input [3:0]  btn;

//------------------------------------------------------------------------------
// TODO: replace input pad names with the correct ones
//------------------------------------------------------------------------------

PDIDGZ u_btn_3_ ( .C(btn_core[3]), .PAD(btn[3]));
PDIDGZ u_btn_2_ ( .C(btn_core[2]), .PAD(btn[2]));
PDIDGZ u_btn_1_ ( .C(btn_core[1]), .PAD(btn[1]));
PDIDGZ u_btn_0_ ( .C(btn_core[0]), .PAD(btn[0]));
PDIDGZ u_clk ( .C(clk_core), .PAD(clk));
PDIDGZ u_rst_n ( .C(rst_n_core), .PAD(rst_n));
PDIDGZ u_spi_miso ( .C(spi_miso_core), .PAD(spi_miso));
PDIDGZ u_uart_sin ( .C(uart_sin_core), .PAD(uart_sin));

endmodule

`endif
