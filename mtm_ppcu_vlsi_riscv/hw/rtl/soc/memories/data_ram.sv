/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module data_ram (
    input logic    clk,
    input logic    rst_n,

    data_bus.slave dbus
);


/**
 * Signals assignments
 */

assign dbus.gnt = dbus.req;


/**
 * Submodules placement
 */

ram u_ram (
    .clk,

    .rdata(dbus.rdata),
    .req(dbus.req),
    .addr(dbus.addr),
    .we(dbus.we),
    .be(dbus.be),
    .wdata(dbus.wdata)
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.gnt;
end

endmodule
