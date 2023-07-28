/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module ram #(
    DEPTH = 4096
) (
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

localparam ADDR_MSB = $clog2(DEPTH) + 1;

logic [31:0] mem [DEPTH];


/**
 * Module internal logic
 */

always_ff @(posedge clk) begin
    if (req) begin
        if (we) begin
            if (be[3])
                mem[addr[ADDR_MSB:2]][31:24] <= wdata[31:24];
            if (be[2])
                mem[addr[ADDR_MSB:2]][23:16] <= wdata[23:16];
            if (be[1])
                mem[addr[ADDR_MSB:2]][15:8] <= wdata[15:8];
            if (be[0])
                mem[addr[ADDR_MSB:2]][7:0] <= wdata[7:0];
        end

        rdata <= mem[addr[ADDR_MSB:2]];
    end
end

endmodule
