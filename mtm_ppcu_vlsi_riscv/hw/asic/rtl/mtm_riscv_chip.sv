/**
 * Copyright (C) 2021  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

`timescale 1ns / 1ns
`ifdef KMIE_IMPLEMENT_ASIC

module mtm_riscv_chip (
    input logic        clk,
    input logic        rst_n,

    output logic [3:0] gpio_dout,
    input logic [3:0]  gpio_din,

    output logic       uart_sout,
    input logic        uart_sin
);


/**
 * Local variables and signals
 */

logic        soc_clk, soc_rst_n;
logic [31:0] soc_gpio_dout, soc_gpio_din;
logic        soc_uart_sout, soc_uart_sin;


/**
 * Submodules placement
 */

soc u_soc (
    .clk(soc_clk),
    .rst_n(soc_rst_n),

    .gpio_dout(soc_gpio_dout),
    .gpio_din(soc_gpio_din),

    .uart_sout(soc_uart_sout),
    .uart_sin(soc_uart_sin)
);

pads_out u_pads_out (
    .boot_sequence_done(),
    .led(gpio_dout[3:0]),
    .spi_mosi(),
    .spi_sck(),
    .spi_ss(),
    .uart_sout(uart_sout),
    .boot_sequence_done_core(1'b0),
    .led_core(soc_gpio_dout[3:0]),
    .spi_mosi_core(1'b0),
    .spi_sck_core(1'b0),
    .spi_ss_core(1'b0),
    .uart_sout_core(soc_uart_sout)
);

pads_in u_pads_in (
    .btn_core(soc_gpio_din[3:0]),
    .clk_core(soc_clk),
    .rst_n_core(soc_rst_n),
    .spi_miso_core(),
    .uart_sin_core(soc_uart_sin),
    .btn(gpio_din[3:0]),
    .clk(clk),
    .rst_n(rst_n),
    .spi_miso(),
    .uart_sin(uart_sin)
);

pads_pwr u_pads_pwr ();

endmodule

`endif
