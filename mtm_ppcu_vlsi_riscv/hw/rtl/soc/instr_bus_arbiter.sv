/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module instr_bus_arbiter
    import memory_map::*;
(
    input logic      clk,
    input logic      rst_n,

    instr_bus.slave  core_ibus,

    instr_bus.master boot_rom_ibus,
    instr_bus.master code_ram_ibus
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    INVALID,
    BOOT_ROM,
    CODE_RAM
} slave_t;


/**
 * Local variables and signals
 */

slave_t requested_slave, responding_slave;


/**
 * Tasks and functions definitions
 */

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_ibus.req |-> is_address_valid(core_ibus.addr)) else
    $warning("incorrect address requested: 0x%x", core_ibus.addr);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        responding_slave <= INVALID;
    else
        responding_slave <= requested_slave;
end

always_comb begin
    case (core_ibus.addr) inside
    [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]:   requested_slave = BOOT_ROM;
    [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]:   requested_slave = CODE_RAM;
    default:                                        requested_slave = INVALID;
    endcase
end

always_comb begin
    case (requested_slave)
    BOOT_ROM: begin
        core_ibus.gnt = boot_rom_ibus.gnt;
        boot_rom_ibus.addr = core_ibus.addr;
        boot_rom_ibus.req = core_ibus.req;

        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    CODE_RAM: begin
        core_ibus.gnt = code_ram_ibus.gnt;
        code_ram_ibus.addr = core_ibus.addr;
        code_ram_ibus.req = core_ibus.req;

        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
    end
    INVALID: begin
        core_ibus.gnt = 1'b0;
        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    default: begin
        core_ibus.gnt = 1'b0;
        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    endcase
end

always_comb begin
    case (responding_slave)
    BOOT_ROM: begin
        core_ibus.rvalid = boot_rom_ibus.rvalid;
        core_ibus.rdata = boot_rom_ibus.rdata;
    end
    CODE_RAM: begin
        core_ibus.rvalid = code_ram_ibus.rvalid;
        core_ibus.rdata = code_ram_ibus.rdata;
    end
    default: begin
        core_ibus.rvalid = 1'b0;
        core_ibus.rdata = 32'b0;
    end
    endcase
end

endmodule
