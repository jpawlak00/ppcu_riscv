/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module boot_rom (
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  dbus,
    instr_bus.slave ibus
);


/**
 * Local variables and signals
 */

logic [31:0] addr, rdata;


/**
 * Submodules placement
 */

boot_mem u_boot_mem (
    .rdata,
    .addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rvalid <= 1'b0;
        dbus.rdata <= 32'b0;
        ibus.rvalid <= 1'b0;
        ibus.rdata <= 32'b0;
    end else begin
        dbus.rvalid <= dbus.gnt;
        dbus.rdata <= rdata;
        ibus.rvalid <= ibus.gnt;
        ibus.rdata <= rdata;
    end
end

always_comb begin
    addr = 32'b0;
    dbus.gnt = 1'b0;
    ibus.gnt = 1'b0;

    if (dbus.req) begin
        addr = dbus.addr;
        dbus.gnt = 1'b1;
    end else if (ibus.req) begin
        addr = ibus.addr;
        ibus.gnt = 1'b1;
    end
end

endmodule
