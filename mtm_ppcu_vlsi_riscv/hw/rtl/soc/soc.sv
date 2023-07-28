/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module soc (
    input logic         clk,
    input logic         rst_n,

    output logic [31:0] gpio_dout,
    input logic [31:0]  gpio_din,

    output logic        uart_sout,
    input logic         uart_sin
);


/**
 * Local variables and signals
 */

data_bus  core_dbus ();
data_bus  boot_rom_dbus ();
data_bus  code_ram_dbus ();
data_bus  data_ram_dbus ();
data_bus  gpio_dbus ();
data_bus  uart_dbus ();

instr_bus core_ibus ();
instr_bus boot_rom_ibus ();
instr_bus code_ram_ibus ();


/**
 * Submodules placement
 */

core u_core (
    .clk,
    .rst_n,

    .ibus(core_ibus),
    .dbus(core_dbus)
);

data_bus_arbiter u_data_bus_arbiter (
    .clk,
    .rst_n,

    .core_dbus,

    .boot_rom_dbus,
    .code_ram_dbus,
    .data_ram_dbus,
    .gpio_dbus,
    .uart_dbus
);

instr_bus_arbiter u_instr_bus_arbiter (
    .clk,
    .rst_n,

    .core_ibus,

    .boot_rom_ibus,
    .code_ram_ibus
);

boot_rom u_boot_rom (
    .clk,
    .rst_n,

    .dbus(boot_rom_dbus),
    .ibus(boot_rom_ibus)
);

code_ram u_code_ram (
    .clk,
    .rst_n,

    .dbus(code_ram_dbus),
    .ibus(code_ram_ibus)
);

data_ram u_data_ram (
    .clk,
    .rst_n,

    .dbus(data_ram_dbus)
);

gpio u_gpio (
    .clk,
    .rst_n,

    .dbus(gpio_dbus),

    .dout(gpio_dout),
    .din(gpio_din)
);

uart u_uart (
    .clk,
    .rst_n,

    .dbus(uart_dbus),

    .sout(uart_sout),
    .sin(uart_sin)
);

endmodule
