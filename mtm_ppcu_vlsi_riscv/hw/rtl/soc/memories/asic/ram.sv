/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module ram (
    input logic         clk,

    output logic [31:0] rdata,
    input logic         req,
    input logic [31:0]  addr,
    input logic         we,
    input logic [3:0]   be,
    input logic [31:0]  wdata
);


/**
 * Local variables and signals
 */

logic [31:0] bweb;


/**
 * Signals assignments
 */

assign bweb[31:24] = {8{~be[3]}};
assign bweb[23:16] = {8{~be[2]}};
assign bweb[15:8] = {8{~be[1]}};
assign bweb[7:0] = {8{~be[0]}};


/**
 * Submodules placement
 */

/* +define+UNIT_DELAY needed for functional simulation. */

TS1N40LPB4096X32M4M u_TS1N40LPB4096X32M4M (
    .Q(rdata),          /* Data output */
    .CLK(clk),          /* Clock input */
    .CEB(~req),         /* Chip enable (active low) */
    .WEB(~we),          /* Write enable (active low) */
    .A(addr[13:2]),     /* Address input */
    .D(wdata),          /* Data input */
    .BWEB(bweb),        /* Bit write enable (active low) */
    .RTSEL(2'b01),      /* Read cycle timing selection */
    .WTSEL(2'b01)       /* Write cycle timing selection */
);

endmodule
