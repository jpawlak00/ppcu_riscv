/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module code_ram (
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  dbus,
    instr_bus.slave ibus
);


/**
 * Local variables and signals
 */

logic [31:0] addr, rdata, wdata;
logic        req, we;
logic [3:0]  be;


/**
 * Signals assignments
 */

assign dbus.rdata = rdata;
assign ibus.rdata = rdata;


/**
 * Submodules placement
 */

ram u_ram (
    .clk,

    .rdata,
    .req,
    .addr,
    .we,
    .be,
    .wdata
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rvalid <= 1'b0;
        ibus.rvalid <= 1'b0;
    end else begin
        dbus.rvalid <= dbus.gnt;
        ibus.rvalid <= ibus.gnt;
    end
end

always_comb begin
    req = 1'b0;
    addr = 32'b0;
    we = 1'b0;
    be = 4'b0;
    wdata = 32'b0;
    dbus.gnt = 1'b0;
    ibus.gnt = 1'b0;

    if (dbus.req) begin
        req = 1'b1;
        addr = dbus.addr;
        we = dbus.we;
        be = dbus.be;
        wdata = dbus.wdata;
        dbus.gnt = 1'b1;
    end else if (ibus.req) begin
        req = 1'b1;
        addr = ibus.addr;
        ibus.gnt = 1'b1;
    end
end

endmodule
