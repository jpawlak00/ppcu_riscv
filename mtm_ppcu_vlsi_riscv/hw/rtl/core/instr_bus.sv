/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

interface instr_bus;

logic [31:0] addr, rdata;
logic        req, gnt, rvalid;

modport master (
    output req,
    output addr,
    input  gnt,
    input  rvalid,
    input  rdata
);

modport slave (
    output gnt,
    output rvalid,
    output rdata,
    input  req,
    input  addr
);

endinterface
