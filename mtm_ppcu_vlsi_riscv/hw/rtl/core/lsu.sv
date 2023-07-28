/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module lsu
    import core_pkg::*;
(
    input logic         clk,
    input logic         rst_n,

    output logic        rvalid,
    output logic [31:0] rdata,
    input lsu_op_t      op,
    input logic [31:0]  addr,
    input logic [31:0]  wdata,

    data_bus.master     dbus
);


/**
 * User defined types and constants
 */

typedef enum logic [1:0] {
    IDLE,
    WAITING_FOR_GRANT,
    WAITING_FOR_RESPONSE
} state_t;


/**
 * Local variables and signals
 */

state_t state, state_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    IDLE: begin
        if (op != LSU_NONE_OP) begin
            if (dbus.gnt)
                state_nxt = WAITING_FOR_RESPONSE;
            else
                state_nxt = WAITING_FOR_GRANT;
        end
    end
    WAITING_FOR_GRANT: begin
        if (dbus.gnt)
            state_nxt = WAITING_FOR_RESPONSE;
    end
    WAITING_FOR_RESPONSE: begin
        if (dbus.rvalid)
            state_nxt = IDLE;
    end
    endcase
end

always_comb begin
    rvalid = (state == WAITING_FOR_RESPONSE) && dbus.rvalid;
end

always_comb begin
    rdata = 32'h0;

    case (op)
    LSU_LOAD_BYTE: begin
        case (addr[1:0])
        2'h0:   rdata = {{24{dbus.rdata[7]}}, dbus.rdata[7:0]};
        2'h1:   rdata = {{24{dbus.rdata[15]}}, dbus.rdata[15:8]};
        2'h2:   rdata = {{24{dbus.rdata[23]}}, dbus.rdata[23:16]};
        2'h3:   rdata = {{24{dbus.rdata[31]}}, dbus.rdata[31:24]};
        endcase
    end
    LSU_LOAD_BYTE_UNSIGNED: begin
        case (addr[1:0])
        2'h0:   rdata = {24'b0, dbus.rdata[7:0]};
        2'h1:   rdata = {24'b0, dbus.rdata[15:8]};
        2'h2:   rdata = {24'b0, dbus.rdata[23:16]};
        2'h3:   rdata = {24'b0, dbus.rdata[31:24]};
        endcase
    end
    LSU_LOAD_HALF_WORD: begin
        case (addr[1:0])
        2'h0:   rdata = {{16{dbus.rdata[15]}}, dbus.rdata[15:0]};
        2'h2:   rdata = {{16{dbus.rdata[31]}}, dbus.rdata[31:16]};
        endcase
    end
    LSU_LOAD_HALF_WORD_UNSIGNED: begin
        case (addr[1:0])
        2'h0:   rdata = {16'b0, dbus.rdata[15:0]};
        2'h2:   rdata = {16'b0, dbus.rdata[31:16]};
        endcase
    end
    LSU_LOAD_WORD: begin
        case (addr[1:0])
        2'h0:   rdata = dbus.rdata;
        endcase
    end
    endcase
end

always_comb begin
    dbus.req = (state == IDLE && op != LSU_NONE_OP) || (state == WAITING_FOR_GRANT);
end

always_comb begin
    dbus.we = op inside {LSU_STORE_BYTE, LSU_STORE_HALF_WORD, LSU_STORE_WORD};
end

always_comb begin
    dbus.be = 4'h0;

    case (op)
    LSU_LOAD_BYTE, LSU_LOAD_BYTE_UNSIGNED, LSU_STORE_BYTE: begin
        case (addr[1:0])
        2'h0:   dbus.be = 4'h1;
        2'h1:   dbus.be = 4'h2;
        2'h2:   dbus.be = 4'h4;
        2'h3:   dbus.be = 4'h8;
        endcase
    end
    LSU_LOAD_HALF_WORD, LSU_LOAD_HALF_WORD_UNSIGNED, LSU_STORE_HALF_WORD: begin
        case (addr[1:0])
        2'h0:   dbus.be = 4'h3;
        2'h2:   dbus.be = 4'hc;
        endcase
    end
    LSU_LOAD_WORD, LSU_STORE_WORD: begin
        case (addr[1:0])
        2'h0:   dbus.be = 4'hf;
        endcase
    end
    endcase
end

always_comb begin
    dbus.addr = addr & 32'hffff_fffc;
end

always_comb begin
    dbus.wdata = 32'b0;

    case (op)
    LSU_STORE_BYTE: begin
        case (addr[1:0])
        2'h0:   dbus.wdata = {24'b0, wdata[7:0]};
        2'h1:   dbus.wdata = {16'b0, wdata[7:0], 8'b0};
        2'h2:   dbus.wdata = {8'b0, wdata[7:0], 16'b0};
        2'h3:   dbus.wdata = {wdata[7:0], 24'b0};
        endcase
    end
    LSU_STORE_HALF_WORD: begin
        case (addr[1:0])
        2'h0:   dbus.wdata = {16'b0, wdata[15:0]};
        2'h2:   dbus.wdata = {wdata[15:0], 16'b0};
        endcase
    end
    LSU_STORE_WORD: begin
        case (addr[1:0])
        2'h0:   dbus.wdata = wdata;
        endcase
    end
    endcase
end

endmodule
