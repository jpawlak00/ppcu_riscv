/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module rf (
    input logic         clk,
    input logic         rst_n,

    input logic [4:0]   rs1,
    input logic [4:0]   rs2,
    input logic [4:0]   rd,

    output logic [31:0] rdata1,
    output logic [31:0] rdata2,
    input logic         we,
    input logic [31:0]  wdata
);


/**
 * Local variables and signals
 */

logic [31:0] [31:0] mem;


/**
 * Signals assignments
 */

assign rdata1 = (rs1 == 0) ? 32'b0 : mem[rs1];
assign rdata2 = (rs2 == 0) ? 32'b0 : mem[rs2];


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem <= {{32{32'b0}}};
    end else begin
        if (we && rd != 5'b0)
            mem[rd] <= wdata;
    end
end

endmodule
