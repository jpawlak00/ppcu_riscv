/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module ifu (
    input logic         clk,
    input logic         rst_n,

    input logic         stall,
    input logic         branch,
    input logic         relative_jump,
    input logic         absolute_jump,

    output logic [31:0] pc,
    output logic        ibus_rvalid,
    output logic [31:0] ibus_rdata,
    input logic [31:0]  rf_rdata,
    input logic [31:0]  imm,

    instr_bus.master    ibus
);


/**
 * User defined types and constants
 */

typedef enum logic [1:0] {
    INITIALIZATION,
    LINEAR_FETCHING,
    NON_LINEAR_FETCH,
    NON_LINEAR_FETCH_PROPAGATION
} state_t;


/**
 * Local variables and signals
 */

state_t      state, state_nxt;
logic [31:0] pc_fetch, pc_fetch_nxt, pc_decode, pc_decode_nxt, ibus_rdata_nxt;
logic        ibus_rvalid_nxt;


/**
 * Signals assignments
 */

assign pc = pc_decode;

assign ibus.req = 1'b1;
assign ibus.addr = pc_fetch_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= INITIALIZATION;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    INITIALIZATION: begin
        state_nxt = LINEAR_FETCHING;
    end
    LINEAR_FETCHING: begin
        if (branch || relative_jump || absolute_jump)
            state_nxt = NON_LINEAR_FETCH;
    end
    NON_LINEAR_FETCH: begin
        if (ibus.rvalid)
            state_nxt = NON_LINEAR_FETCH_PROPAGATION;
    end
    NON_LINEAR_FETCH_PROPAGATION: begin
        state_nxt = LINEAR_FETCHING;
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc_fetch <= 32'b0;
        pc_decode <= 32'b0;
        ibus_rvalid <= 1'b0;
        ibus_rdata <= 32'b0;
    end else begin
        pc_fetch <= pc_fetch_nxt;
        pc_decode <= pc_decode_nxt;
        ibus_rvalid <= ibus_rvalid_nxt;
        ibus_rdata <= ibus_rdata_nxt;
    end
end

always_comb begin
    pc_fetch_nxt = pc_fetch;
    pc_decode_nxt = pc_decode;
    ibus_rvalid_nxt = 1'b0;
    ibus_rdata_nxt = ibus_rdata;

    case (state)
    INITIALIZATION: begin
        pc_fetch_nxt = 32'b0;
    end
    LINEAR_FETCHING: begin
        if (ibus.rvalid) begin
            pc_fetch_nxt = pc_fetch + 4;
            pc_decode_nxt = pc_fetch;
            ibus_rvalid_nxt = 1'b1;
            ibus_rdata_nxt = ibus.rdata;
        end

        if (stall) begin
            pc_fetch_nxt = pc_fetch;
            pc_decode_nxt = pc_decode;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (branch) begin
            pc_fetch_nxt = pc_decode + imm;
            pc_decode_nxt = pc_decode;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (relative_jump) begin
            pc_fetch_nxt = pc_decode + imm;
            pc_decode_nxt = pc_decode;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (absolute_jump) begin
            pc_fetch_nxt = (rf_rdata + imm) & 32'hffff_fffe;
            pc_decode_nxt = pc_decode;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end
    end
    NON_LINEAR_FETCH: ;
    NON_LINEAR_FETCH_PROPAGATION: begin
        pc_fetch_nxt = pc_fetch + 4;
        pc_decode_nxt = pc_fetch;
        ibus_rvalid_nxt = 1'b1;
        ibus_rdata_nxt = ibus.rdata;
    end
    endcase
end

endmodule
