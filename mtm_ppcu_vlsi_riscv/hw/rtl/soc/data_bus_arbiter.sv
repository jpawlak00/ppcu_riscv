/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module data_bus_arbiter
    import memory_map::*;
(
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  core_dbus,

    data_bus.master boot_rom_dbus,
    data_bus.master code_ram_dbus,
    data_bus.master data_ram_dbus,

    data_bus.master gpio_dbus,
    data_bus.master uart_dbus
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    WAITING_FOR_GRANT,
    WAITING_FOR_RESPONSE
} state_t;


/**
 * Local variables and signals
 */

state_t      state, state_nxt;
logic [31:0] requested_addr, requested_addr_nxt;


/**
 * Tasks and functions definitions
 */

`define attach_core_data_bus_to_slave(bus) \
    bus.req = core_dbus.req; \
    bus.we = core_dbus.we; \
    bus.be = core_dbus.be; \
    bus.addr = core_dbus.addr; \
    bus.wdata = core_dbus.wdata

`define attach_zeros_to_slave_data_bus(bus) \
    bus.req = 1'b0; \
    bus.we = 1'b0; \
    bus.be = 4'b0; \
    bus.addr = 32'b0; \
    bus.wdata = 32'b0

`define attach_slave_data_bus_to_core(bus) \
    core_dbus.gnt = bus.gnt; \
    core_dbus.rvalid = bus.rvalid; \
    core_dbus.rdata = bus.rdata

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS],
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS],
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS],
        [UART_BASE_ADDRESS:UART_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_dbus.req |-> is_address_valid(core_dbus.addr)) else
    $warning("incorrect address requested: 0x%x", core_dbus.addr);


/**
 * Module internal logic
 */

/* state control */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    IDLE: begin
        if (core_dbus.req)
            state_nxt = core_dbus.gnt ? WAITING_FOR_RESPONSE : WAITING_FOR_GRANT;
    end
    WAITING_FOR_GRANT: begin
        if (core_dbus.gnt)
            state_nxt = WAITING_FOR_RESPONSE;
    end
    WAITING_FOR_RESPONSE: begin
        if (core_dbus.rvalid)
            state_nxt = IDLE;
    end
    endcase
end

/* core input signals demultiplexing */

always_comb begin
    `attach_zeros_to_slave_data_bus(boot_rom_dbus);
    `attach_zeros_to_slave_data_bus(code_ram_dbus);
    `attach_zeros_to_slave_data_bus(data_ram_dbus);
    `attach_zeros_to_slave_data_bus(gpio_dbus);
    `attach_zeros_to_slave_data_bus(uart_dbus);

    case (state)
    IDLE,
    WAITING_FOR_GRANT: begin
        if (core_dbus.req) begin
            case (core_dbus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(boot_rom_dbus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(code_ram_dbus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(data_ram_dbus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(gpio_dbus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(uart_dbus);
            end
            endcase
        end
    end
    WAITING_FOR_RESPONSE: ;
    endcase
end

/* core output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        requested_addr <= 32'b0;
    else
        requested_addr <= requested_addr_nxt;
end

always_comb begin
    requested_addr_nxt = requested_addr;
    core_dbus.gnt = 1'b0;
    core_dbus.rvalid = 1'b0;
    core_dbus.rdata = 32'b0;

    case (state)
    IDLE: begin
        if (core_dbus.req) begin
            core_dbus.gnt = 1'b1;
            requested_addr_nxt = core_dbus.addr;

            case (core_dbus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(boot_rom_dbus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(code_ram_dbus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(data_ram_dbus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(gpio_dbus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(uart_dbus);
            end
            endcase
        end
    end
    WAITING_FOR_GRANT: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_dbus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_dbus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_dbus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_dbus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_dbus);
        end
        endcase
    end
    WAITING_FOR_RESPONSE: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_dbus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_dbus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_dbus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_dbus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_dbus);
        end
        default: begin
            core_dbus.rvalid = 1'b1;
        end
        endcase
    end
    endcase
end

endmodule
