/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

interface data_bus;

logic [31:0] addr, wdata, rdata;
logic [3:0]  be;
logic        req, we, gnt, rvalid;

modport master (
    output req,
    output we,
    output be,
    output addr,
    output wdata,
    input  gnt,
    input  rvalid,
    input  rdata
);

modport slave (
    output gnt,
    output rvalid,
    output rdata,
    input  req,
    input  we,
    input  be,
    input  addr,
    input  wdata
);

endinterface
