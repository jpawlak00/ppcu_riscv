/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module cu
    import core_pkg::*;
(
    input logic        clk,
    input logic        rst_n,

    input logic        instr_valid,
    input instr_t      instr,

    output logic       ifu_branch,
    output logic       ifu_relative_jump,
    output logic       ifu_absolute_jump,
    output logic       ifu_stall,

    output logic       rf_we,
    output rf_rd_src_t rf_rd_src,

    output alu_op_t    alu_op,
    output alu_a_src_t alu_a_src,
    output alu_b_src_t alu_b_src,
    input logic        alu_eq,
    input logic        alu_lt,

    output lsu_op_t    lsu_op,
    input logic        lsu_rvalid
);


/**
 * User defined types and constants
 */

typedef enum logic {
    LSU_IDLE,
    LSU_ACTIVE
} lsu_state_t;


/**
 * Local variables and signals
 */

lsu_state_t lsu_state, lsu_state_nxt;


/**
 * Module internal logic
 */

always_comb begin
    case (instr)
    ADD, ADDI, LB, LH, LW, LBU, LHU, SB, SH, SW, JAL, JALR, AUIPC:  alu_op = ALU_OP_ADD;
    SLT, SLTI, BLT, BGE:                                            alu_op = ALU_OP_SLT;
    SLTU, SLTIU, BLTU, BGEU:                                        alu_op = ALU_OP_SLTU;
    AND, ANDI:                                                      alu_op = ALU_OP_AND;
    OR, ORI:                                                        alu_op = ALU_OP_OR;
    XOR, XORI:                                                      alu_op = ALU_OP_XOR;
    SLL, SLLI:                                                      alu_op = ALU_OP_SLL;
    SRL, SRLI:                                                      alu_op = ALU_OP_SRL;
    SUB, BEQ, BNE:                                                  alu_op = ALU_OP_SUB;
    SRA, SRAI:                                                      alu_op = ALU_OP_SRA;
    default:                                                        alu_op = ALU_OP_INVALID;
    endcase
end

always_comb begin
    if (instr inside {AUIPC, JAL, JALR})
        alu_a_src = ALU_A_PC;
    else
        alu_a_src = ALU_A_RF;
end

always_comb begin
    if (instr inside {AUIPC, LB, LH, LW, LBU, LHU, SB, SH, SW,
        ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI})
        alu_b_src = ALU_B_IMM;
    else if (instr inside {JAL, JALR})
        alu_b_src = ALU_B_CONST_4;
    else
        alu_b_src = ALU_B_RF;
end

always_comb begin
    if (instr inside {
        LUI, AUIPC, ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND})
        rf_we = 1'b1;
    else if (instr inside {LB, LH, LW, LBU, LHU} && lsu_rvalid)
        rf_we = 1'b1;
    else if (instr inside {JAL, JALR} && instr_valid)
        rf_we = 1'b1;
    else
        rf_we = 1'b0;
end

always_comb begin
    if (instr inside {LB, LH, LW, LBU, LHU})
        rf_rd_src = RF_RD_LSU;
    else if (instr == LUI)
        rf_rd_src = RF_RD_IMM;
    else
        rf_rd_src = RF_RD_ALU;
end

always_comb begin
    if ((instr == BEQ && alu_eq) ||
        (instr == BNE && !alu_eq) ||
        (instr inside {BGE, BGEU} && !alu_lt) ||
        (instr inside {BLT, BLTU} && alu_lt))
        ifu_branch = 1'b1;
    else
        ifu_branch = 1'b0;
end

always_comb begin
    if (instr == JAL)
        ifu_relative_jump = 1'b1;
    else
        ifu_relative_jump = 1'b0;
end

always_comb begin
    if (instr == JALR)
        ifu_absolute_jump = 1'b1;
    else
        ifu_absolute_jump = 1'b0;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        lsu_state <= LSU_IDLE;
    else
        lsu_state <= lsu_state_nxt;
end

always_comb begin
    lsu_state_nxt = lsu_state;

    case (lsu_state)
    LSU_IDLE: begin
        if (instr_valid && instr inside {LB, LH, LW, LBU, LHU, SB, SH, SW})
            lsu_state_nxt = LSU_ACTIVE;
    end
    LSU_ACTIVE: begin
        if (lsu_rvalid)
            lsu_state_nxt = LSU_IDLE;
    end
    endcase
end

always_comb begin
    lsu_op = LSU_NONE_OP;
    ifu_stall = 1'b0;

    case (lsu_state)
    LSU_IDLE: begin
        if (instr_valid && instr inside {LB, LH, LW, LBU, LHU, SB, SH, SW}) begin
            ifu_stall = 1'b1;

            case (instr)
            LB:     lsu_op = LSU_LOAD_BYTE;
            LBU:    lsu_op = LSU_LOAD_BYTE_UNSIGNED;
            LH:     lsu_op = LSU_LOAD_HALF_WORD;
            LHU:    lsu_op = LSU_LOAD_HALF_WORD_UNSIGNED;
            LW:     lsu_op = LSU_LOAD_WORD;
            SB:     lsu_op = LSU_STORE_BYTE;
            SH:     lsu_op = LSU_STORE_HALF_WORD;
            SW:     lsu_op = LSU_STORE_WORD;
            endcase
        end
    end
    LSU_ACTIVE: begin
        ifu_stall = ~lsu_rvalid;

        case (instr)
        LB:     lsu_op = LSU_LOAD_BYTE;
        LBU:    lsu_op = LSU_LOAD_BYTE_UNSIGNED;
        LH:     lsu_op = LSU_LOAD_HALF_WORD;
        LHU:    lsu_op = LSU_LOAD_HALF_WORD_UNSIGNED;
        LW:     lsu_op = LSU_LOAD_WORD;
        SB:     lsu_op = LSU_STORE_BYTE;
        SH:     lsu_op = LSU_STORE_HALF_WORD;
        SW:     lsu_op = LSU_STORE_WORD;
        endcase
    end
    endcase
end

endmodule
