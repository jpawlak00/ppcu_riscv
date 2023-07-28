// Library - PPCU_VLSI_RISCV, Cell - pads_out, View - schematic
// LAST TIME SAVED: Apr  6 13:28:29 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns
`ifdef KMIE_IMPLEMENT_ASIC

module pads_out ( boot_sequence_done, led, spi_mosi, spi_sck, spi_ss,
    uart_sout, boot_sequence_done_core, led_core, spi_mosi_core,
    spi_sck_core, spi_ss_core, uart_sout_core );

output       boot_sequence_done, spi_mosi, spi_sck, spi_ss, uart_sout;

input boot_sequence_done_core, spi_mosi_core, spi_sck_core,
spi_ss_core, uart_sout_core;

output [3:0] led;

input  [3:0] led_core;

//------------------------------------------------------------------------------
// TODO: replace cell names to the correct ones
//------------------------------------------------------------------------------

PDO24CDG u_led_3_ ( .PAD(led[3]), .I(led_core[3]));
PDO24CDG u_led_2_ ( .PAD(led[2]), .I(led_core[2]));
PDO24CDG u_led_1_ ( .PAD(led[1]), .I(led_core[1]));
PDO24CDG u_led_0_ ( .PAD(led[0]), .I(led_core[0]));
PDO24CDG u_spi_mosi ( .PAD(spi_mosi), .I(spi_mosi_core));
PDO24CDG u_spi_sck ( .PAD(spi_sck), .I(spi_sck_core));
PDO24CDG u_spi_ss ( .PAD(spi_ss), .I(spi_ss_core));
PDO24CDG u_uart_sout ( .PAD(uart_sout), .I(uart_sout_core));
PDO24CDG u_boot_sequence_done ( .PAD(boot_sequence_done),
    .I(boot_sequence_done_core));

endmodule

`endif
