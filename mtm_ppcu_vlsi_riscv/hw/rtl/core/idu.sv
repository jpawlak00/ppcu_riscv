/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module idu
    import core_pkg::*;
(
    input logic         ibus_rvalid,
    input logic [31:0]  ibus_rdata,

    output logic        instr_valid,
    output instr_t      instr,
    output logic [31:0] imm,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd
);


/**
 * Signals assignments
 */

assign instr_valid = ibus_rvalid;
assign rs1 = ibus_rdata[19:15];
assign rs2 = ibus_rdata[24:20];
assign rd = ibus_rdata[11:7];


/**
 * Tasks and functions definitions
 */

function logic is_r_type(instr_t instr);
    return instr inside {ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND};
endfunction

function logic is_i_type(instr_t instr);
    return instr inside {
            JALR, LB, LH, LW, LBU, LHU, ADDI,
            SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        };
endfunction

function logic is_s_type(instr_t instr);
    return instr inside {SB, SH, SW};
endfunction

function logic is_b_type(instr_t instr);
    return instr inside {BEQ, BNE, BLT, BGE, BLTU, BGEU};
endfunction

function logic is_u_type(instr_t instr);
    return instr inside {LUI, AUIPC};
endfunction

function logic is_j_type(instr_t instr);
    return instr inside {JAL};
endfunction


/**
 * Module internal logic
 */

/* instruction decoding */
always_comb begin
    case (ibus_rdata) inside
    32'b????_????_????_????_????_????_?011_0111:    instr = LUI;
    32'b????_????_????_????_????_????_?001_0111:    instr = AUIPC;
    32'b????_????_????_????_????_????_?110_1111:    instr = JAL;
    32'b????_????_????_????_?000_????_?110_0111:    instr = JALR;
    32'b????_????_????_????_?000_????_?110_0011:    instr = BEQ;
    32'b????_????_????_????_?001_????_?110_0011:    instr = BNE;
    32'b????_????_????_????_?100_????_?110_0011:    instr = BLT;
    32'b????_????_????_????_?101_????_?110_0011:    instr = BGE;
    32'b????_????_????_????_?110_????_?110_0011:    instr = BLTU;
    32'b????_????_????_????_?111_????_?110_0011:    instr = BGEU;
    32'b????_????_????_????_?000_????_?000_0011:    instr = LB;
    32'b????_????_????_????_?001_????_?000_0011:    instr = LH;
    32'b????_????_????_????_?010_????_?000_0011:    instr = LW;
    32'b????_????_????_????_?100_????_?000_0011:    instr = LBU;
    32'b????_????_????_????_?101_????_?000_0011:    instr = LHU;
    32'b????_????_????_????_?000_????_?010_0011:    instr = SB;
    32'b????_????_????_????_?001_????_?010_0011:    instr = SH;
    32'b????_????_????_????_?010_????_?010_0011:    instr = SW;
    32'b????_????_????_????_?000_????_?001_0011:    instr = ADDI;
    32'b????_????_????_????_?010_????_?001_0011:    instr = SLTI;
    32'b????_????_????_????_?011_????_?001_0011:    instr = SLTIU;
    32'b????_????_????_????_?100_????_?001_0011:    instr = XORI;
    32'b????_????_????_????_?110_????_?001_0011:    instr = ORI;
    32'b????_????_????_????_?111_????_?001_0011:    instr = ANDI;
    32'b0000_000?_????_????_?001_????_?001_0011:    instr = SLLI;
    32'b0000_000?_????_????_?101_????_?001_0011:    instr = SRLI;
    32'b0100_000?_????_????_?101_????_?001_0011:    instr = SRAI;
    32'b0000_000?_????_????_?000_????_?011_0011:    instr = ADD;
    32'b0100_000?_????_????_?000_????_?011_0011:    instr = SUB;
    32'b0000_000?_????_????_?001_????_?011_0011:    instr = SLL;
    32'b0000_000?_????_????_?010_????_?011_0011:    instr = SLT;
    32'b0000_000?_????_????_?011_????_?011_0011:    instr = SLTU;
    32'b0000_000?_????_????_?100_????_?011_0011:    instr = XOR;
    32'b0000_000?_????_????_?101_????_?011_0011:    instr = SRL;
    32'b0100_000?_????_????_?101_????_?011_0011:    instr = SRA;
    32'b0000_000?_????_????_?110_????_?011_0011:    instr = OR;
    32'b0000_000?_????_????_?111_????_?011_0011:    instr = AND;
    default:                                        instr = INVALID;
    endcase
end

/* immediate decoding */

always_comb begin
    if (is_r_type(instr))
        imm = 32'b0;
    else if (is_i_type(instr))
        imm = {{20{ibus_rdata[31]}}, ibus_rdata[31:20]};
    else if (is_s_type(instr))
        imm = {{20{ibus_rdata[31]}}, ibus_rdata[31:25], ibus_rdata[11:7]};
    else if (is_b_type(instr))
        imm = {{19{ibus_rdata[31]}}, ibus_rdata[31], ibus_rdata[7], ibus_rdata[30:25], ibus_rdata[11:8], 1'b0};
    else if (is_u_type(instr))
        imm = {ibus_rdata[31:12], 12'b0};
    else if (is_j_type(instr))
        imm = {{12{ibus_rdata[31]}}, ibus_rdata[19:12], ibus_rdata[20], ibus_rdata[30:21], 1'b0};
    else
        imm = 32'b0;
end

endmodule
