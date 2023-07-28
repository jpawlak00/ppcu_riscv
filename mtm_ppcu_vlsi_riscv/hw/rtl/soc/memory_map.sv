/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

package memory_map;

const logic [31:0] BOOT_ROM_BASE_ADDRESS = 32'h0000_0000,
                   BOOT_ROM_END_ADDRESS = 32'h0000_3fff,

                   CODE_RAM_BASE_ADDRESS = 32'h0001_0000,
                   CODE_RAM_END_ADDRESS = 32'h0001_3fff,

                   DATA_RAM_BASE_ADDRESS = 32'h4000_0000,
                   DATA_RAM_END_ADDRESS = 32'h4000_3fff,

                   GPIO_BASE_ADDRESS = 32'hc000_0000,
                   GPIO_END_ADDRESS = 32'hc000_0fff,

                   UART_BASE_ADDRESS = 32'hc000_1000,
                   UART_END_ADDRESS = 32'hc000_1fff;
endpackage
