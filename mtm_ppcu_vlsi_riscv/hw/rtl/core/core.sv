/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module core
    import core_pkg::*;
(
    input logic      clk,
    input logic      rst_n,

    instr_bus.master ibus,
    data_bus.master  dbus
);


/**
 * Local variables and signals
 */

logic        ifu_stall, ifu_branch, ifu_relative_jump, ifu_absolute_jump, ibus_rvalid;

instr_t      instr;
logic [31:0] imm, pc, ibus_rdata;
logic [4:0]  rs1, rs2, rd;
logic        instr_valid;

alu_op_t     alu_op;
alu_a_src_t  alu_a_src;
alu_b_src_t  alu_b_src;
logic [31:0] alu_a, alu_b, alu_y;
logic        alu_eq, alu_lt;

logic [31:0] rf_rdata1, rf_rdata2, rf_wdata;
rf_rd_src_t  rf_rd_src;
logic        rf_we;

lsu_op_t     lsu_op;
logic [31:0] lsu_rdata;
logic        lsu_rvalid;


/**
 * Submodules placement
 */

ifu u_ifu (
    .clk,
    .rst_n,

    .stall(ifu_stall),
    .branch(ifu_branch),
    .relative_jump(ifu_relative_jump),
    .absolute_jump(ifu_absolute_jump),

    .pc,
    .ibus_rvalid,
    .ibus_rdata,
    .rf_rdata(rf_rdata1),
    .imm,

    .ibus
);

idu u_idu (
    .ibus_rvalid,
    .ibus_rdata,

    .instr_valid,
    .instr,
    .imm,
    .rs1,
    .rs2,
    .rd
);

cu u_cu (
    .clk,
    .rst_n,

    .instr_valid,
    .instr,

    .ifu_stall,
    .ifu_branch,
    .ifu_relative_jump,
    .ifu_absolute_jump,

    .rf_we,
    .rf_rd_src,

    .alu_op,
    .alu_a_src,
    .alu_b_src,
    .alu_eq,
    .alu_lt,

    .lsu_op,
    .lsu_rvalid
);

rf u_rf (
    .clk,
    .rst_n,

    .rs1,
    .rs2,
    .rd,

    .rdata1(rf_rdata1),
    .rdata2(rf_rdata2),
    .we(rf_we),
    .wdata(rf_wdata)
);

alu u_alu (
    .op(alu_op),

    .eq(alu_eq),
    .lt(alu_lt),

    .y(alu_y),
    .a(alu_a),
    .b(alu_b)
);

lsu u_lsu (
    .clk,
    .rst_n,

    .rvalid(lsu_rvalid),
    .rdata(lsu_rdata),
    .op(lsu_op),
    .addr(alu_y),
    .wdata(rf_rdata2),

    .dbus
);


/**
 * Module internal logic
 */

always_comb begin
    case (alu_a_src)
    ALU_A_PC:       alu_a = pc;
    ALU_A_RF:       alu_a = rf_rdata1;
    endcase
end

always_comb begin
    case (alu_b_src)
    ALU_B_IMM:      alu_b = imm;
    ALU_B_RF:       alu_b = rf_rdata2;
    ALU_B_CONST_4:  alu_b = 32'h0000_0004;
    default:        alu_b = 32'b0;
    endcase
end

always_comb begin
    case (rf_rd_src)
    RF_RD_ALU:  rf_wdata = alu_y;
    RF_RD_LSU:  rf_wdata = lsu_rdata;
    RF_RD_IMM:  rf_wdata = imm;
    default:    rf_wdata = 32'b0;
    endcase
end

endmodule
