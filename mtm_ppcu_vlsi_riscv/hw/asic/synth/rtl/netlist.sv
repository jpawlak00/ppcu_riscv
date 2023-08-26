`define KMIE_IMPLEMENT_ASIC
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

package core_pkg;


/**
 * User defined types
 */

typedef enum logic [16:0] {
    LUI = 17'b0000000_000_0110111,
    AUIPC = 17'b0000000_000_0010111,
    JAL = 17'b0000000_000_1101111,
    JALR = 17'b0000000_000_1100111,
    BEQ = 17'b0000000_000_1100011,
    BNE = 17'b0000000_001_1100011,
    BLT = 17'b0000000_100_1100011,
    BGE = 17'b0000000_101_1100011,
    BLTU = 17'b0000000_110_1100011,
    BGEU = 17'b0000000_111_1100011,
    LB = 17'b0000000_000_0000011,
    LH = 17'b0000000_001_0000011,
    LW = 17'b0000000_010_0000011,
    LBU = 17'b0000000_100_0000011,
    LHU = 17'b0000000_101_0000011,
    SB = 17'b0000000_000_0100011,
    SH = 17'b0000000_001_0100011,
    SW = 17'b0000000_010_0100011,
    ADDI = 17'b0000000_000_0010011,
    SLTI = 17'b0000000_010_0010011,
    SLTIU = 17'b0000000_011_0010011,
    XORI = 17'b0000000_100_0010011,
    ORI = 17'b0000000_110_0010011,
    ANDI = 17'b0000000_111_0010011,
    SLLI = 17'b0000000_001_0010011,
    SRLI = 17'b0000000_101_0010011,
    SRAI = 17'b0100000_101_0010011,
    ADD = 17'b0000000_000_0110011,
    SUB = 17'b0100000_000_0110011,
    SLL = 17'b0000000_001_0110011,
    SLT = 17'b0000000_010_0110011,
    SLTU = 17'b0000000_011_0110011,
    XOR = 17'b0000000_100_0110011,
    SRL = 17'b0000000_101_0110011,
    SRA = 17'b0100000_101_0110011,
    OR = 17'b0000000_110_0110011,
    AND = 17'b0000000_111_0110011,
    INVALID = 17'b1111111_111_1111111
} instr_t;

typedef enum logic [3:0] {
    ALU_OP_ADD,
    ALU_OP_SLT,
    ALU_OP_SLTU,
    ALU_OP_AND,
    ALU_OP_OR,
    ALU_OP_XOR,
    ALU_OP_SLL,
    ALU_OP_SRL,
    ALU_OP_SUB,
    ALU_OP_SRA,
    ALU_OP_INVALID
} alu_op_t;

typedef enum logic {
    ALU_A_RF,
    ALU_A_PC
} alu_a_src_t;

typedef enum logic [1:0] {
    ALU_B_RF,
    ALU_B_IMM,
    ALU_B_CONST_4
} alu_b_src_t;

typedef enum logic [1:0] {
    RF_RD_ALU,
    RF_RD_LSU,
    RF_RD_IMM
} rf_rd_src_t;

typedef enum logic [3:0] {
    LSU_LOAD_BYTE,
    LSU_LOAD_BYTE_UNSIGNED,
    LSU_LOAD_HALF_WORD,
    LSU_LOAD_HALF_WORD_UNSIGNED,
    LSU_LOAD_WORD,
    LSU_STORE_BYTE,
    LSU_STORE_HALF_WORD,
    LSU_STORE_WORD,
    LSU_NONE_OP
} lsu_op_t;

endpackage
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
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module alu
    import core_pkg::*;
(
    input alu_op_t      op,

    output logic        eq,
    output logic        lt,

    output logic [31:0] y,
    input logic [31:0]  a,
    input logic [31:0]  b
);


/**
 * Module internal logic
 */

always_comb begin
    case (op)
    ALU_OP_ADD:     y = a + b;
    ALU_OP_SLT:     y = {31'b0, $signed(a) < $signed(b)};
    ALU_OP_SLTU:    y = {31'b0, a < b};
    ALU_OP_AND:     y = a & b;
    ALU_OP_OR:      y = a | b;
    ALU_OP_XOR:     y = a ^ b;
    ALU_OP_SLL:     y = a << b[4:0];
    ALU_OP_SRL:     y = a >> b[4:0];
    ALU_OP_SUB:     y = a - b;
    ALU_OP_SRA:     y = a >>> b[4:0];
    default:        y = 32'b0;
    endcase
end

always_comb begin
    eq = (op == ALU_OP_SUB) && (y == 0);
    lt = (op inside {ALU_OP_SLT, ALU_OP_SLTU}) && (y == 1);
end

endmodule
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
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

package gpio_csr;


/**
 * Memory map
 */

const logic [11:0] GPIO_ODR_OFFSET = 12'h000,   /* output data register */
                   GPIO_IDR_OFFSET = 12'h004;   /* input data register */


/**
 * User defined types
 */

typedef struct packed {
    logic [31:0] idr;
    logic [31:0] odr;
} gpio_csr_t;

endpackage
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module gpio
    import gpio_csr::*;
(
    input logic         clk,
    input logic         rst_n,

    data_bus.slave      dbus,

    output logic [31:0] dout,
    input logic [31:0]  din
);


/**
 * Local variables and signals
 */

gpio_csr_t csr, csr_nxt;


/**
 * Signals assignments
 */

assign dout = csr.odr;


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {GPIO_ODR_OFFSET, GPIO_IDR_OFFSET};
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return dbus.req && dbus.we && dbus.addr[11:0] == offset;
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) dbus.req |-> is_offset_valid(dbus.addr[11:0])) else
    $warning("incorrect offset requested: 0x%x", dbus.addr[11:0]);


/**
 * Module internal logic
 */

always_comb begin
    dbus.gnt = dbus.req;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.gnt;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        csr <= '0;
    else
        csr <= csr_nxt;
end

always_comb begin
    csr_nxt = csr;

    if (dbus.req && dbus.we) begin
        case (dbus.addr[11:0])
        GPIO_ODR_OFFSET:    csr_nxt.odr = dbus.wdata;
        GPIO_IDR_OFFSET:    csr_nxt.idr = dbus.wdata;
        endcase
    end

    csr_nxt.idr = din;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rdata <= 32'b0;
    end else begin
        if (dbus.req) begin
            case (dbus.addr[11:0])
            GPIO_ODR_OFFSET:    dbus.rdata <= csr.odr;
            GPIO_IDR_OFFSET:    dbus.rdata <= csr.idr;
            endcase
        end
    end
end

endmodule
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
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module boot_mem (
    output logic [31:0] rdata,
    input logic [31:0]  addr
);


/**
 * Module internal logic
 */

always_comb begin
    case (addr[13:2])
           0:    rdata = 32'h00000093;
           1:    rdata = 32'h00000113;
           2:    rdata = 32'h00000193;
           3:    rdata = 32'h00000213;
           4:    rdata = 32'h00000293;
           5:    rdata = 32'h00000313;
           6:    rdata = 32'h00000393;
           7:    rdata = 32'h00000413;
           8:    rdata = 32'h00000493;
           9:    rdata = 32'h00000513;
          10:    rdata = 32'h00000593;
          11:    rdata = 32'h00000613;
          12:    rdata = 32'h00000693;
          13:    rdata = 32'h00000713;
          14:    rdata = 32'h00000793;
          15:    rdata = 32'h00000813;
          16:    rdata = 32'h00000893;
          17:    rdata = 32'h00000913;
          18:    rdata = 32'h00000993;
          19:    rdata = 32'h00000a13;
          20:    rdata = 32'h00000a93;
          21:    rdata = 32'h00000b13;
          22:    rdata = 32'h00000b93;
          23:    rdata = 32'h00000c13;
          24:    rdata = 32'h00000c93;
          25:    rdata = 32'h00000d13;
          26:    rdata = 32'h00000d93;
          27:    rdata = 32'h00000e13;
          28:    rdata = 32'h00000e93;
          29:    rdata = 32'h00000f13;
          30:    rdata = 32'h00000f93;
          31:    rdata = 32'h40004117;
          32:    rdata = 32'hf8410113;
          33:    rdata = 32'h40000297;
          34:    rdata = 32'hf7c28293;
          35:    rdata = 32'h40000317;
          36:    rdata = 32'hf8430313;
          37:    rdata = 32'h0062d863;
          38:    rdata = 32'h0002a023;
          39:    rdata = 32'h00428293;
          40:    rdata = 32'hfe535ce3;
          41:    rdata = 32'h61000293;
          42:    rdata = 32'h40000317;
          43:    rdata = 32'hf5830313;
          44:    rdata = 32'h40000397;
          45:    rdata = 32'hf5038393;
          46:    rdata = 32'h00735c63;
          47:    rdata = 32'h0002ae03;
          48:    rdata = 32'h01c32023;
          49:    rdata = 32'h00428293;
          50:    rdata = 32'h00430313;
          51:    rdata = 32'hfe7348e3;
          52:    rdata = 32'h59c00293;
          53:    rdata = 32'h5a800313;
          54:    rdata = 32'h0062da63;
          55:    rdata = 32'h0002a783;
          56:    rdata = 32'h000780e7;
          57:    rdata = 32'h00428293;
          58:    rdata = 32'hfe62cae3;
          59:    rdata = 32'h00000513;
          60:    rdata = 32'h00000593;
          61:    rdata = 32'h358000ef;
          62:    rdata = 32'h00b52023;
          63:    rdata = 32'h00c52223;
          64:    rdata = 32'h00008067;
          65:    rdata = 32'hffc5f793;
          66:    rdata = 32'h00052583;
          67:    rdata = 32'h00f585b3;
          68:    rdata = 32'h0005a503;
          69:    rdata = 32'h00008067;
          70:    rdata = 32'hffc5f793;
          71:    rdata = 32'h00052583;
          72:    rdata = 32'h00f585b3;
          73:    rdata = 32'h00c5a023;
          74:    rdata = 32'h00008067;
          75:    rdata = 32'h00452503;
          76:    rdata = 32'h00008067;
          77:    rdata = 32'h00b52023;
          78:    rdata = 32'h00008067;
          79:    rdata = 32'h00052783;
          80:    rdata = 32'h00b7a023;
          81:    rdata = 32'h00008067;
          82:    rdata = 32'h00052783;
          83:    rdata = 32'h0047a503;
          84:    rdata = 32'h00008067;
          85:    rdata = 32'h00052503;
          86:    rdata = 32'h00060713;
          87:    rdata = 32'h00100693;
          88:    rdata = 32'h00058613;
          89:    rdata = 32'h00000593;
          90:    rdata = 32'h29c0006f;
          91:    rdata = 32'h00052503;
          92:    rdata = 32'hff010113;
          93:    rdata = 32'h00058613;
          94:    rdata = 32'h00100693;
          95:    rdata = 32'h00400593;
          96:    rdata = 32'h00112623;
          97:    rdata = 32'h268000ef;
          98:    rdata = 32'h00c12083;
          99:    rdata = 32'h00a03533;
         100:    rdata = 32'h01010113;
         101:    rdata = 32'h00008067;
         102:    rdata = 32'h00052503;
         103:    rdata = 32'h00058613;
         104:    rdata = 32'h00100693;
         105:    rdata = 32'h00000593;
         106:    rdata = 32'h2880006f;
         107:    rdata = 32'hff010113;
         108:    rdata = 32'h00812423;
         109:    rdata = 32'h00050413;
         110:    rdata = 32'h00b42023;
         111:    rdata = 32'h00058513;
         112:    rdata = 32'h00c00713;
         113:    rdata = 32'h0ff00693;
         114:    rdata = 32'h00000613;
         115:    rdata = 32'h01000593;
         116:    rdata = 32'h00112623;
         117:    rdata = 32'h230000ef;
         118:    rdata = 32'h00042503;
         119:    rdata = 32'h00812403;
         120:    rdata = 32'h00c12083;
         121:    rdata = 32'h00100713;
         122:    rdata = 32'h00100693;
         123:    rdata = 32'h00000613;
         124:    rdata = 32'h00000593;
         125:    rdata = 32'h01010113;
         126:    rdata = 32'h20c0006f;
         127:    rdata = 32'h00052503;
         128:    rdata = 32'hff010113;
         129:    rdata = 32'h00100693;
         130:    rdata = 32'h00000613;
         131:    rdata = 32'h00400593;
         132:    rdata = 32'h00112623;
         133:    rdata = 32'h1d8000ef;
         134:    rdata = 32'h00c12083;
         135:    rdata = 32'h00a03533;
         136:    rdata = 32'h01010113;
         137:    rdata = 32'h00008067;
         138:    rdata = 32'h00052503;
         139:    rdata = 32'hff010113;
         140:    rdata = 32'h0ff00693;
         141:    rdata = 32'h00000613;
         142:    rdata = 32'h00c00593;
         143:    rdata = 32'h00112623;
         144:    rdata = 32'h1ac000ef;
         145:    rdata = 32'h00c12083;
         146:    rdata = 32'h0ff57513;
         147:    rdata = 32'h01010113;
         148:    rdata = 32'h00008067;
         149:    rdata = 32'hff010113;
         150:    rdata = 32'h00812423;
         151:    rdata = 32'h00112623;
         152:    rdata = 32'h00050413;
         153:    rdata = 32'h00040513;
         154:    rdata = 32'hf95ff0ef;
         155:    rdata = 32'hfe050ce3;
         156:    rdata = 32'h00040513;
         157:    rdata = 32'h00812403;
         158:    rdata = 32'h00c12083;
         159:    rdata = 32'h01010113;
         160:    rdata = 32'hfa9ff06f;
         161:    rdata = 32'hfe010113;
         162:    rdata = 32'h00812c23;
         163:    rdata = 32'h00912a23;
         164:    rdata = 32'h01212823;
         165:    rdata = 32'h01312623;
         166:    rdata = 32'h01512223;
         167:    rdata = 32'h01612023;
         168:    rdata = 32'h00112e23;
         169:    rdata = 32'h01412423;
         170:    rdata = 32'h00050493;
         171:    rdata = 32'h00058913;
         172:    rdata = 32'h00060993;
         173:    rdata = 32'h00000413;
         174:    rdata = 32'h00a00a93;
         175:    rdata = 32'h00800b13;
         176:    rdata = 32'h07345263;
         177:    rdata = 32'h00048513;
         178:    rdata = 32'h00890a33;
         179:    rdata = 32'hf89ff0ef;
         180:    rdata = 32'h00aa0023;
         181:    rdata = 32'h03551a63;
         182:    rdata = 32'h000a0023;
         183:    rdata = 32'h00000513;
         184:    rdata = 32'h01c12083;
         185:    rdata = 32'h01812403;
         186:    rdata = 32'h01412483;
         187:    rdata = 32'h01012903;
         188:    rdata = 32'h00c12983;
         189:    rdata = 32'h00812a03;
         190:    rdata = 32'h00412a83;
         191:    rdata = 32'h00012b03;
         192:    rdata = 32'h02010113;
         193:    rdata = 32'h00008067;
         194:    rdata = 32'h01651663;
         195:    rdata = 32'h00040863;
         196:    rdata = 32'hffe40413;
         197:    rdata = 32'h00140413;
         198:    rdata = 32'hfa9ff06f;
         199:    rdata = 32'hfff00413;
         200:    rdata = 32'hff5ff06f;
         201:    rdata = 32'h00100513;
         202:    rdata = 32'hfb9ff06f;
         203:    rdata = 32'h00052503;
         204:    rdata = 32'hff010113;
         205:    rdata = 32'h00100693;
         206:    rdata = 32'h00100613;
         207:    rdata = 32'h00400593;
         208:    rdata = 32'h00112623;
         209:    rdata = 32'h0a8000ef;
         210:    rdata = 32'h00c12083;
         211:    rdata = 32'h00a03533;
         212:    rdata = 32'h01010113;
         213:    rdata = 32'h00008067;
         214:    rdata = 32'h00052503;
         215:    rdata = 32'h00058713;
         216:    rdata = 32'h0ff00693;
         217:    rdata = 32'h00000613;
         218:    rdata = 32'h00800593;
         219:    rdata = 32'h0980006f;
         220:    rdata = 32'hfe010113;
         221:    rdata = 32'h00812c23;
         222:    rdata = 32'h00112e23;
         223:    rdata = 32'h00050413;
         224:    rdata = 32'h00040513;
         225:    rdata = 32'h00b12623;
         226:    rdata = 32'hfa5ff0ef;
         227:    rdata = 32'h00c12583;
         228:    rdata = 32'hfe0518e3;
         229:    rdata = 32'h00040513;
         230:    rdata = 32'h01812403;
         231:    rdata = 32'h01c12083;
         232:    rdata = 32'h02010113;
         233:    rdata = 32'hfb5ff06f;
         234:    rdata = 32'hff010113;
         235:    rdata = 32'h00812423;
         236:    rdata = 32'h00912223;
         237:    rdata = 32'h00112623;
         238:    rdata = 32'h00050493;
         239:    rdata = 32'h00058413;
         240:    rdata = 32'h00044583;
         241:    rdata = 32'h00058a63;
         242:    rdata = 32'h00048513;
         243:    rdata = 32'h00140413;
         244:    rdata = 32'hfa1ff0ef;
         245:    rdata = 32'hfedff06f;
         246:    rdata = 32'h00c12083;
         247:    rdata = 32'h00812403;
         248:    rdata = 32'h00412483;
         249:    rdata = 32'h01010113;
         250:    rdata = 32'h00008067;
         251:    rdata = 32'hffc5f593;
         252:    rdata = 32'h00b50533;
         253:    rdata = 32'h00052783;
         254:    rdata = 32'h00c7d7b3;
         255:    rdata = 32'h00d7f533;
         256:    rdata = 32'h00008067;
         257:    rdata = 32'hffc5f593;
         258:    rdata = 32'h00b50533;
         259:    rdata = 32'h00052583;
         260:    rdata = 32'h00c697b3;
         261:    rdata = 32'hfff7c793;
         262:    rdata = 32'h00e6f6b3;
         263:    rdata = 32'h00b7f7b3;
         264:    rdata = 32'h00c696b3;
         265:    rdata = 32'h00f6e6b3;
         266:    rdata = 32'h00d52023;
         267:    rdata = 32'h00008067;
         268:    rdata = 32'hffc5f593;
         269:    rdata = 32'h00b50533;
         270:    rdata = 32'h00052783;
         271:    rdata = 32'h00c696b3;
         272:    rdata = 32'h00f6c6b3;
         273:    rdata = 32'h00d52023;
         274:    rdata = 32'h00008067;
         275:    rdata = 32'hfd010113;
         276:    rdata = 32'h00000597;
         277:    rdata = 32'h15858593;
         278:    rdata = 32'h40000517;
         279:    rdata = 32'hbb450513;
         280:    rdata = 32'h02112623;
         281:    rdata = 32'h02812423;
         282:    rdata = 32'h02912223;
         283:    rdata = 32'h03212023;
         284:    rdata = 32'h01312e23;
         285:    rdata = 32'h01412c23;
         286:    rdata = 32'hf31ff0ef;
         287:    rdata = 32'h00300593;
         288:    rdata = 32'h40000517;
         289:    rdata = 32'hb8850513;
         290:    rdata = 32'hce5ff0ef;
         291:    rdata = 32'h00000597;
         292:    rdata = 32'h13858593;
         293:    rdata = 32'h08051463;
         294:    rdata = 32'h00000597;
         295:    rdata = 32'h14458593;
         296:    rdata = 32'h40000517;
         297:    rdata = 32'hb6c50513;
         298:    rdata = 32'hf01ff0ef;
         299:    rdata = 32'h00000413;
         300:    rdata = 32'h40000917;
         301:    rdata = 32'hb5090913;
         302:    rdata = 32'h40000997;
         303:    rdata = 32'hb5498993;
         304:    rdata = 32'h00400a13;
         305:    rdata = 32'h00090513;
         306:    rdata = 32'hc65ff0ef;
         307:    rdata = 32'h04a47463;
         308:    rdata = 32'h00000493;
         309:    rdata = 32'h00098513;
         310:    rdata = 32'hd25ff0ef;
         311:    rdata = 32'hfe050ce3;
         312:    rdata = 32'h00098513;
         313:    rdata = 32'hd45ff0ef;
         314:    rdata = 32'h00c10793;
         315:    rdata = 32'h009787b3;
         316:    rdata = 32'h00a78023;
         317:    rdata = 32'h00148493;
         318:    rdata = 32'hfd449ee3;
         319:    rdata = 32'h00c12603;
         320:    rdata = 32'h00040593;
         321:    rdata = 32'h00090513;
         322:    rdata = 32'hc11ff0ef;
         323:    rdata = 32'h00440413;
         324:    rdata = 32'hfb5ff06f;
         325:    rdata = 32'h00000597;
         326:    rdata = 32'h0e058593;
         327:    rdata = 32'h40000517;
         328:    rdata = 32'haf050513;
         329:    rdata = 32'he85ff0ef;
         330:    rdata = 32'h2d90f06f;
         331:    rdata = 32'h02c12083;
         332:    rdata = 32'h02812403;
         333:    rdata = 32'h02412483;
         334:    rdata = 32'h02012903;
         335:    rdata = 32'h01c12983;
         336:    rdata = 32'h01812a03;
         337:    rdata = 32'h00000513;
         338:    rdata = 32'h03010113;
         339:    rdata = 32'h00008067;
         340:    rdata = 32'h40000797;
         341:    rdata = 32'hab078793;
         342:    rdata = 32'h00010737;
         343:    rdata = 32'h00e7a023;
         344:    rdata = 32'h00004737;
         345:    rdata = 32'h00e7a223;
         346:    rdata = 32'h00008067;
         347:    rdata = 32'hc00007b7;
         348:    rdata = 32'h40000717;
         349:    rdata = 32'ha8f72c23;
         350:    rdata = 32'h00008067;
         351:    rdata = 32'hc00015b7;
         352:    rdata = 32'h40000517;
         353:    rdata = 32'ha8c50513;
         354:    rdata = 32'hc25ff06f;
         355:    rdata = 32'h00000000;
         356:    rdata = 32'h00000000;
         357:    rdata = 32'h00000000;
         358:    rdata = 32'h00000000;
         359:    rdata = 32'h00000550;
         360:    rdata = 32'h0000056c;
         361:    rdata = 32'h0000057c;
         362:    rdata = 32'h4f464e49;
         363:    rdata = 32'h6f62203a;
         364:    rdata = 32'h6f6c746f;
         365:    rdata = 32'h72656461;
         366:    rdata = 32'h61747320;
         367:    rdata = 32'h64657472;
         368:    rdata = 32'h0000000a;
         369:    rdata = 32'h4f464e49;
         370:    rdata = 32'h6f63203a;
         371:    rdata = 32'h6f6c6564;
         372:    rdata = 32'h73206461;
         373:    rdata = 32'h7070696b;
         374:    rdata = 32'h000a6465;
         375:    rdata = 32'h4f464e49;
         376:    rdata = 32'h6f63203a;
         377:    rdata = 32'h6f6c6564;
         378:    rdata = 32'h73206461;
         379:    rdata = 32'h74726174;
         380:    rdata = 32'h000a6465;
         381:    rdata = 32'h4f464e49;
         382:    rdata = 32'h6f63203a;
         383:    rdata = 32'h6f6c6564;
         384:    rdata = 32'h66206461;
         385:    rdata = 32'h73696e69;
         386:    rdata = 32'h0a646568;
         387:    rdata = 32'h00000000;
         388:    rdata = 32'h00000000;
         389:    rdata = 32'h00000000;
         390:    rdata = 32'h00000000;
         391:    rdata = 32'h00000000;
         392:    rdata = 32'h00000000;
         393:    rdata = 32'h00000000;
         394:    rdata = 32'h00000000;
         395:    rdata = 32'h00000000;
         396:    rdata = 32'h00000000;
         397:    rdata = 32'h00000000;
         398:    rdata = 32'h00000000;
         399:    rdata = 32'h00000000;
         400:    rdata = 32'h00000000;
         401:    rdata = 32'h00000000;
         402:    rdata = 32'h00000000;
         403:    rdata = 32'h00000000;
         404:    rdata = 32'h00000000;
         405:    rdata = 32'h00000000;
         406:    rdata = 32'h00000000;
         407:    rdata = 32'h00000000;
         408:    rdata = 32'h00000000;
         409:    rdata = 32'h00000000;
         410:    rdata = 32'h00000000;
         411:    rdata = 32'h00000000;
         412:    rdata = 32'h00000000;
         413:    rdata = 32'h00000000;
         414:    rdata = 32'h00000000;
         415:    rdata = 32'h00000000;
         416:    rdata = 32'h00000000;
         417:    rdata = 32'h00000000;
         418:    rdata = 32'h00000000;
         419:    rdata = 32'h00000000;
         420:    rdata = 32'h00000000;
         421:    rdata = 32'h00000000;
         422:    rdata = 32'h00000000;
         423:    rdata = 32'h00000000;
         424:    rdata = 32'h00000000;
         425:    rdata = 32'h00000000;
         426:    rdata = 32'h00000000;
         427:    rdata = 32'h00000000;
         428:    rdata = 32'h00000000;
         429:    rdata = 32'h00000000;
         430:    rdata = 32'h00000000;
         431:    rdata = 32'h00000000;
         432:    rdata = 32'h00000000;
         433:    rdata = 32'h00000000;
         434:    rdata = 32'h00000000;
         435:    rdata = 32'h00000000;
         436:    rdata = 32'h00000000;
         437:    rdata = 32'h00000000;
         438:    rdata = 32'h00000000;
         439:    rdata = 32'h00000000;
         440:    rdata = 32'h00000000;
         441:    rdata = 32'h00000000;
         442:    rdata = 32'h00000000;
         443:    rdata = 32'h00000000;
         444:    rdata = 32'h00000000;
         445:    rdata = 32'h00000000;
         446:    rdata = 32'h00000000;
         447:    rdata = 32'h00000000;
         448:    rdata = 32'h00000000;
         449:    rdata = 32'h00000000;
         450:    rdata = 32'h00000000;
         451:    rdata = 32'h00000000;
         452:    rdata = 32'h00000000;
         453:    rdata = 32'h00000000;
         454:    rdata = 32'h00000000;
         455:    rdata = 32'h00000000;
         456:    rdata = 32'h00000000;
         457:    rdata = 32'h00000000;
         458:    rdata = 32'h00000000;
         459:    rdata = 32'h00000000;
         460:    rdata = 32'h00000000;
         461:    rdata = 32'h00000000;
         462:    rdata = 32'h00000000;
         463:    rdata = 32'h00000000;
         464:    rdata = 32'h00000000;
         465:    rdata = 32'h00000000;
         466:    rdata = 32'h00000000;
         467:    rdata = 32'h00000000;
         468:    rdata = 32'h00000000;
         469:    rdata = 32'h00000000;
         470:    rdata = 32'h00000000;
         471:    rdata = 32'h00000000;
         472:    rdata = 32'h00000000;
         473:    rdata = 32'h00000000;
         474:    rdata = 32'h00000000;
         475:    rdata = 32'h00000000;
         476:    rdata = 32'h00000000;
         477:    rdata = 32'h00000000;
         478:    rdata = 32'h00000000;
         479:    rdata = 32'h00000000;
         480:    rdata = 32'h00000000;
         481:    rdata = 32'h00000000;
         482:    rdata = 32'h00000000;
         483:    rdata = 32'h00000000;
         484:    rdata = 32'h00000000;
         485:    rdata = 32'h00000000;
         486:    rdata = 32'h00000000;
         487:    rdata = 32'h00000000;
         488:    rdata = 32'h00000000;
         489:    rdata = 32'h00000000;
         490:    rdata = 32'h00000000;
         491:    rdata = 32'h00000000;
         492:    rdata = 32'h00000000;
         493:    rdata = 32'h00000000;
         494:    rdata = 32'h00000000;
         495:    rdata = 32'h00000000;
         496:    rdata = 32'h00000000;
         497:    rdata = 32'h00000000;
         498:    rdata = 32'h00000000;
         499:    rdata = 32'h00000000;
         500:    rdata = 32'h00000000;
         501:    rdata = 32'h00000000;
         502:    rdata = 32'h00000000;
         503:    rdata = 32'h00000000;
         504:    rdata = 32'h00000000;
         505:    rdata = 32'h00000000;
         506:    rdata = 32'h00000000;
         507:    rdata = 32'h00000000;
         508:    rdata = 32'h00000000;
         509:    rdata = 32'h00000000;
         510:    rdata = 32'h00000000;
         511:    rdata = 32'h00000000;
         512:    rdata = 32'h00000000;
         513:    rdata = 32'h00000000;
         514:    rdata = 32'h00000000;
         515:    rdata = 32'h00000000;
         516:    rdata = 32'h00000000;
         517:    rdata = 32'h00000000;
         518:    rdata = 32'h00000000;
         519:    rdata = 32'h00000000;
         520:    rdata = 32'h00000000;
         521:    rdata = 32'h00000000;
         522:    rdata = 32'h00000000;
         523:    rdata = 32'h00000000;
         524:    rdata = 32'h00000000;
         525:    rdata = 32'h00000000;
         526:    rdata = 32'h00000000;
         527:    rdata = 32'h00000000;
         528:    rdata = 32'h00000000;
         529:    rdata = 32'h00000000;
         530:    rdata = 32'h00000000;
         531:    rdata = 32'h00000000;
         532:    rdata = 32'h00000000;
         533:    rdata = 32'h00000000;
         534:    rdata = 32'h00000000;
         535:    rdata = 32'h00000000;
         536:    rdata = 32'h00000000;
         537:    rdata = 32'h00000000;
         538:    rdata = 32'h00000000;
         539:    rdata = 32'h00000000;
         540:    rdata = 32'h00000000;
         541:    rdata = 32'h00000000;
         542:    rdata = 32'h00000000;
         543:    rdata = 32'h00000000;
         544:    rdata = 32'h00000000;
         545:    rdata = 32'h00000000;
         546:    rdata = 32'h00000000;
         547:    rdata = 32'h00000000;
         548:    rdata = 32'h00000000;
         549:    rdata = 32'h00000000;
         550:    rdata = 32'h00000000;
         551:    rdata = 32'h00000000;
         552:    rdata = 32'h00000000;
         553:    rdata = 32'h00000000;
         554:    rdata = 32'h00000000;
         555:    rdata = 32'h00000000;
         556:    rdata = 32'h00000000;
         557:    rdata = 32'h00000000;
         558:    rdata = 32'h00000000;
         559:    rdata = 32'h00000000;
         560:    rdata = 32'h00000000;
         561:    rdata = 32'h00000000;
         562:    rdata = 32'h00000000;
         563:    rdata = 32'h00000000;
         564:    rdata = 32'h00000000;
         565:    rdata = 32'h00000000;
         566:    rdata = 32'h00000000;
         567:    rdata = 32'h00000000;
         568:    rdata = 32'h00000000;
         569:    rdata = 32'h00000000;
         570:    rdata = 32'h00000000;
         571:    rdata = 32'h00000000;
         572:    rdata = 32'h00000000;
         573:    rdata = 32'h00000000;
         574:    rdata = 32'h00000000;
         575:    rdata = 32'h00000000;
         576:    rdata = 32'h00000000;
         577:    rdata = 32'h00000000;
         578:    rdata = 32'h00000000;
         579:    rdata = 32'h00000000;
         580:    rdata = 32'h00000000;
         581:    rdata = 32'h00000000;
         582:    rdata = 32'h00000000;
         583:    rdata = 32'h00000000;
         584:    rdata = 32'h00000000;
         585:    rdata = 32'h00000000;
         586:    rdata = 32'h00000000;
         587:    rdata = 32'h00000000;
         588:    rdata = 32'h00000000;
         589:    rdata = 32'h00000000;
         590:    rdata = 32'h00000000;
         591:    rdata = 32'h00000000;
         592:    rdata = 32'h00000000;
         593:    rdata = 32'h00000000;
         594:    rdata = 32'h00000000;
         595:    rdata = 32'h00000000;
         596:    rdata = 32'h00000000;
         597:    rdata = 32'h00000000;
         598:    rdata = 32'h00000000;
         599:    rdata = 32'h00000000;
         600:    rdata = 32'h00000000;
         601:    rdata = 32'h00000000;
         602:    rdata = 32'h00000000;
         603:    rdata = 32'h00000000;
         604:    rdata = 32'h00000000;
         605:    rdata = 32'h00000000;
         606:    rdata = 32'h00000000;
         607:    rdata = 32'h00000000;
         608:    rdata = 32'h00000000;
         609:    rdata = 32'h00000000;
         610:    rdata = 32'h00000000;
         611:    rdata = 32'h00000000;
         612:    rdata = 32'h00000000;
         613:    rdata = 32'h00000000;
         614:    rdata = 32'h00000000;
         615:    rdata = 32'h00000000;
         616:    rdata = 32'h00000000;
         617:    rdata = 32'h00000000;
         618:    rdata = 32'h00000000;
         619:    rdata = 32'h00000000;
         620:    rdata = 32'h00000000;
         621:    rdata = 32'h00000000;
         622:    rdata = 32'h00000000;
         623:    rdata = 32'h00000000;
         624:    rdata = 32'h00000000;
         625:    rdata = 32'h00000000;
         626:    rdata = 32'h00000000;
         627:    rdata = 32'h00000000;
         628:    rdata = 32'h00000000;
         629:    rdata = 32'h00000000;
         630:    rdata = 32'h00000000;
         631:    rdata = 32'h00000000;
         632:    rdata = 32'h00000000;
         633:    rdata = 32'h00000000;
         634:    rdata = 32'h00000000;
         635:    rdata = 32'h00000000;
         636:    rdata = 32'h00000000;
         637:    rdata = 32'h00000000;
         638:    rdata = 32'h00000000;
         639:    rdata = 32'h00000000;
         640:    rdata = 32'h00000000;
         641:    rdata = 32'h00000000;
         642:    rdata = 32'h00000000;
         643:    rdata = 32'h00000000;
         644:    rdata = 32'h00000000;
         645:    rdata = 32'h00000000;
         646:    rdata = 32'h00000000;
         647:    rdata = 32'h00000000;
         648:    rdata = 32'h00000000;
         649:    rdata = 32'h00000000;
         650:    rdata = 32'h00000000;
         651:    rdata = 32'h00000000;
         652:    rdata = 32'h00000000;
         653:    rdata = 32'h00000000;
         654:    rdata = 32'h00000000;
         655:    rdata = 32'h00000000;
         656:    rdata = 32'h00000000;
         657:    rdata = 32'h00000000;
         658:    rdata = 32'h00000000;
         659:    rdata = 32'h00000000;
         660:    rdata = 32'h00000000;
         661:    rdata = 32'h00000000;
         662:    rdata = 32'h00000000;
         663:    rdata = 32'h00000000;
         664:    rdata = 32'h00000000;
         665:    rdata = 32'h00000000;
         666:    rdata = 32'h00000000;
         667:    rdata = 32'h00000000;
         668:    rdata = 32'h00000000;
         669:    rdata = 32'h00000000;
         670:    rdata = 32'h00000000;
         671:    rdata = 32'h00000000;
         672:    rdata = 32'h00000000;
         673:    rdata = 32'h00000000;
         674:    rdata = 32'h00000000;
         675:    rdata = 32'h00000000;
         676:    rdata = 32'h00000000;
         677:    rdata = 32'h00000000;
         678:    rdata = 32'h00000000;
         679:    rdata = 32'h00000000;
         680:    rdata = 32'h00000000;
         681:    rdata = 32'h00000000;
         682:    rdata = 32'h00000000;
         683:    rdata = 32'h00000000;
         684:    rdata = 32'h00000000;
         685:    rdata = 32'h00000000;
         686:    rdata = 32'h00000000;
         687:    rdata = 32'h00000000;
         688:    rdata = 32'h00000000;
         689:    rdata = 32'h00000000;
         690:    rdata = 32'h00000000;
         691:    rdata = 32'h00000000;
         692:    rdata = 32'h00000000;
         693:    rdata = 32'h00000000;
         694:    rdata = 32'h00000000;
         695:    rdata = 32'h00000000;
         696:    rdata = 32'h00000000;
         697:    rdata = 32'h00000000;
         698:    rdata = 32'h00000000;
         699:    rdata = 32'h00000000;
         700:    rdata = 32'h00000000;
         701:    rdata = 32'h00000000;
         702:    rdata = 32'h00000000;
         703:    rdata = 32'h00000000;
         704:    rdata = 32'h00000000;
         705:    rdata = 32'h00000000;
         706:    rdata = 32'h00000000;
         707:    rdata = 32'h00000000;
         708:    rdata = 32'h00000000;
         709:    rdata = 32'h00000000;
         710:    rdata = 32'h00000000;
         711:    rdata = 32'h00000000;
         712:    rdata = 32'h00000000;
         713:    rdata = 32'h00000000;
         714:    rdata = 32'h00000000;
         715:    rdata = 32'h00000000;
         716:    rdata = 32'h00000000;
         717:    rdata = 32'h00000000;
         718:    rdata = 32'h00000000;
         719:    rdata = 32'h00000000;
         720:    rdata = 32'h00000000;
         721:    rdata = 32'h00000000;
         722:    rdata = 32'h00000000;
         723:    rdata = 32'h00000000;
         724:    rdata = 32'h00000000;
         725:    rdata = 32'h00000000;
         726:    rdata = 32'h00000000;
         727:    rdata = 32'h00000000;
         728:    rdata = 32'h00000000;
         729:    rdata = 32'h00000000;
         730:    rdata = 32'h00000000;
         731:    rdata = 32'h00000000;
         732:    rdata = 32'h00000000;
         733:    rdata = 32'h00000000;
         734:    rdata = 32'h00000000;
         735:    rdata = 32'h00000000;
         736:    rdata = 32'h00000000;
         737:    rdata = 32'h00000000;
         738:    rdata = 32'h00000000;
         739:    rdata = 32'h00000000;
         740:    rdata = 32'h00000000;
         741:    rdata = 32'h00000000;
         742:    rdata = 32'h00000000;
         743:    rdata = 32'h00000000;
         744:    rdata = 32'h00000000;
         745:    rdata = 32'h00000000;
         746:    rdata = 32'h00000000;
         747:    rdata = 32'h00000000;
         748:    rdata = 32'h00000000;
         749:    rdata = 32'h00000000;
         750:    rdata = 32'h00000000;
         751:    rdata = 32'h00000000;
         752:    rdata = 32'h00000000;
         753:    rdata = 32'h00000000;
         754:    rdata = 32'h00000000;
         755:    rdata = 32'h00000000;
         756:    rdata = 32'h00000000;
         757:    rdata = 32'h00000000;
         758:    rdata = 32'h00000000;
         759:    rdata = 32'h00000000;
         760:    rdata = 32'h00000000;
         761:    rdata = 32'h00000000;
         762:    rdata = 32'h00000000;
         763:    rdata = 32'h00000000;
         764:    rdata = 32'h00000000;
         765:    rdata = 32'h00000000;
         766:    rdata = 32'h00000000;
         767:    rdata = 32'h00000000;
         768:    rdata = 32'h00000000;
         769:    rdata = 32'h00000000;
         770:    rdata = 32'h00000000;
         771:    rdata = 32'h00000000;
         772:    rdata = 32'h00000000;
         773:    rdata = 32'h00000000;
         774:    rdata = 32'h00000000;
         775:    rdata = 32'h00000000;
         776:    rdata = 32'h00000000;
         777:    rdata = 32'h00000000;
         778:    rdata = 32'h00000000;
         779:    rdata = 32'h00000000;
         780:    rdata = 32'h00000000;
         781:    rdata = 32'h00000000;
         782:    rdata = 32'h00000000;
         783:    rdata = 32'h00000000;
         784:    rdata = 32'h00000000;
         785:    rdata = 32'h00000000;
         786:    rdata = 32'h00000000;
         787:    rdata = 32'h00000000;
         788:    rdata = 32'h00000000;
         789:    rdata = 32'h00000000;
         790:    rdata = 32'h00000000;
         791:    rdata = 32'h00000000;
         792:    rdata = 32'h00000000;
         793:    rdata = 32'h00000000;
         794:    rdata = 32'h00000000;
         795:    rdata = 32'h00000000;
         796:    rdata = 32'h00000000;
         797:    rdata = 32'h00000000;
         798:    rdata = 32'h00000000;
         799:    rdata = 32'h00000000;
         800:    rdata = 32'h00000000;
         801:    rdata = 32'h00000000;
         802:    rdata = 32'h00000000;
         803:    rdata = 32'h00000000;
         804:    rdata = 32'h00000000;
         805:    rdata = 32'h00000000;
         806:    rdata = 32'h00000000;
         807:    rdata = 32'h00000000;
         808:    rdata = 32'h00000000;
         809:    rdata = 32'h00000000;
         810:    rdata = 32'h00000000;
         811:    rdata = 32'h00000000;
         812:    rdata = 32'h00000000;
         813:    rdata = 32'h00000000;
         814:    rdata = 32'h00000000;
         815:    rdata = 32'h00000000;
         816:    rdata = 32'h00000000;
         817:    rdata = 32'h00000000;
         818:    rdata = 32'h00000000;
         819:    rdata = 32'h00000000;
         820:    rdata = 32'h00000000;
         821:    rdata = 32'h00000000;
         822:    rdata = 32'h00000000;
         823:    rdata = 32'h00000000;
         824:    rdata = 32'h00000000;
         825:    rdata = 32'h00000000;
         826:    rdata = 32'h00000000;
         827:    rdata = 32'h00000000;
         828:    rdata = 32'h00000000;
         829:    rdata = 32'h00000000;
         830:    rdata = 32'h00000000;
         831:    rdata = 32'h00000000;
         832:    rdata = 32'h00000000;
         833:    rdata = 32'h00000000;
         834:    rdata = 32'h00000000;
         835:    rdata = 32'h00000000;
         836:    rdata = 32'h00000000;
         837:    rdata = 32'h00000000;
         838:    rdata = 32'h00000000;
         839:    rdata = 32'h00000000;
         840:    rdata = 32'h00000000;
         841:    rdata = 32'h00000000;
         842:    rdata = 32'h00000000;
         843:    rdata = 32'h00000000;
         844:    rdata = 32'h00000000;
         845:    rdata = 32'h00000000;
         846:    rdata = 32'h00000000;
         847:    rdata = 32'h00000000;
         848:    rdata = 32'h00000000;
         849:    rdata = 32'h00000000;
         850:    rdata = 32'h00000000;
         851:    rdata = 32'h00000000;
         852:    rdata = 32'h00000000;
         853:    rdata = 32'h00000000;
         854:    rdata = 32'h00000000;
         855:    rdata = 32'h00000000;
         856:    rdata = 32'h00000000;
         857:    rdata = 32'h00000000;
         858:    rdata = 32'h00000000;
         859:    rdata = 32'h00000000;
         860:    rdata = 32'h00000000;
         861:    rdata = 32'h00000000;
         862:    rdata = 32'h00000000;
         863:    rdata = 32'h00000000;
         864:    rdata = 32'h00000000;
         865:    rdata = 32'h00000000;
         866:    rdata = 32'h00000000;
         867:    rdata = 32'h00000000;
         868:    rdata = 32'h00000000;
         869:    rdata = 32'h00000000;
         870:    rdata = 32'h00000000;
         871:    rdata = 32'h00000000;
         872:    rdata = 32'h00000000;
         873:    rdata = 32'h00000000;
         874:    rdata = 32'h00000000;
         875:    rdata = 32'h00000000;
         876:    rdata = 32'h00000000;
         877:    rdata = 32'h00000000;
         878:    rdata = 32'h00000000;
         879:    rdata = 32'h00000000;
         880:    rdata = 32'h00000000;
         881:    rdata = 32'h00000000;
         882:    rdata = 32'h00000000;
         883:    rdata = 32'h00000000;
         884:    rdata = 32'h00000000;
         885:    rdata = 32'h00000000;
         886:    rdata = 32'h00000000;
         887:    rdata = 32'h00000000;
         888:    rdata = 32'h00000000;
         889:    rdata = 32'h00000000;
         890:    rdata = 32'h00000000;
         891:    rdata = 32'h00000000;
         892:    rdata = 32'h00000000;
         893:    rdata = 32'h00000000;
         894:    rdata = 32'h00000000;
         895:    rdata = 32'h00000000;
         896:    rdata = 32'h00000000;
         897:    rdata = 32'h00000000;
         898:    rdata = 32'h00000000;
         899:    rdata = 32'h00000000;
         900:    rdata = 32'h00000000;
         901:    rdata = 32'h00000000;
         902:    rdata = 32'h00000000;
         903:    rdata = 32'h00000000;
         904:    rdata = 32'h00000000;
         905:    rdata = 32'h00000000;
         906:    rdata = 32'h00000000;
         907:    rdata = 32'h00000000;
         908:    rdata = 32'h00000000;
         909:    rdata = 32'h00000000;
         910:    rdata = 32'h00000000;
         911:    rdata = 32'h00000000;
         912:    rdata = 32'h00000000;
         913:    rdata = 32'h00000000;
         914:    rdata = 32'h00000000;
         915:    rdata = 32'h00000000;
         916:    rdata = 32'h00000000;
         917:    rdata = 32'h00000000;
         918:    rdata = 32'h00000000;
         919:    rdata = 32'h00000000;
         920:    rdata = 32'h00000000;
         921:    rdata = 32'h00000000;
         922:    rdata = 32'h00000000;
         923:    rdata = 32'h00000000;
         924:    rdata = 32'h00000000;
         925:    rdata = 32'h00000000;
         926:    rdata = 32'h00000000;
         927:    rdata = 32'h00000000;
         928:    rdata = 32'h00000000;
         929:    rdata = 32'h00000000;
         930:    rdata = 32'h00000000;
         931:    rdata = 32'h00000000;
         932:    rdata = 32'h00000000;
         933:    rdata = 32'h00000000;
         934:    rdata = 32'h00000000;
         935:    rdata = 32'h00000000;
         936:    rdata = 32'h00000000;
         937:    rdata = 32'h00000000;
         938:    rdata = 32'h00000000;
         939:    rdata = 32'h00000000;
         940:    rdata = 32'h00000000;
         941:    rdata = 32'h00000000;
         942:    rdata = 32'h00000000;
         943:    rdata = 32'h00000000;
         944:    rdata = 32'h00000000;
         945:    rdata = 32'h00000000;
         946:    rdata = 32'h00000000;
         947:    rdata = 32'h00000000;
         948:    rdata = 32'h00000000;
         949:    rdata = 32'h00000000;
         950:    rdata = 32'h00000000;
         951:    rdata = 32'h00000000;
         952:    rdata = 32'h00000000;
         953:    rdata = 32'h00000000;
         954:    rdata = 32'h00000000;
         955:    rdata = 32'h00000000;
         956:    rdata = 32'h00000000;
         957:    rdata = 32'h00000000;
         958:    rdata = 32'h00000000;
         959:    rdata = 32'h00000000;
         960:    rdata = 32'h00000000;
         961:    rdata = 32'h00000000;
         962:    rdata = 32'h00000000;
         963:    rdata = 32'h00000000;
         964:    rdata = 32'h00000000;
         965:    rdata = 32'h00000000;
         966:    rdata = 32'h00000000;
         967:    rdata = 32'h00000000;
         968:    rdata = 32'h00000000;
         969:    rdata = 32'h00000000;
         970:    rdata = 32'h00000000;
         971:    rdata = 32'h00000000;
         972:    rdata = 32'h00000000;
         973:    rdata = 32'h00000000;
         974:    rdata = 32'h00000000;
         975:    rdata = 32'h00000000;
         976:    rdata = 32'h00000000;
         977:    rdata = 32'h00000000;
         978:    rdata = 32'h00000000;
         979:    rdata = 32'h00000000;
         980:    rdata = 32'h00000000;
         981:    rdata = 32'h00000000;
         982:    rdata = 32'h00000000;
         983:    rdata = 32'h00000000;
         984:    rdata = 32'h00000000;
         985:    rdata = 32'h00000000;
         986:    rdata = 32'h00000000;
         987:    rdata = 32'h00000000;
         988:    rdata = 32'h00000000;
         989:    rdata = 32'h00000000;
         990:    rdata = 32'h00000000;
         991:    rdata = 32'h00000000;
         992:    rdata = 32'h00000000;
         993:    rdata = 32'h00000000;
         994:    rdata = 32'h00000000;
         995:    rdata = 32'h00000000;
         996:    rdata = 32'h00000000;
         997:    rdata = 32'h00000000;
         998:    rdata = 32'h00000000;
         999:    rdata = 32'h00000000;
        1000:    rdata = 32'h00000000;
        1001:    rdata = 32'h00000000;
        1002:    rdata = 32'h00000000;
        1003:    rdata = 32'h00000000;
        1004:    rdata = 32'h00000000;
        1005:    rdata = 32'h00000000;
        1006:    rdata = 32'h00000000;
        1007:    rdata = 32'h00000000;
        1008:    rdata = 32'h00000000;
        1009:    rdata = 32'h00000000;
        1010:    rdata = 32'h00000000;
        1011:    rdata = 32'h00000000;
        1012:    rdata = 32'h00000000;
        1013:    rdata = 32'h00000000;
        1014:    rdata = 32'h00000000;
        1015:    rdata = 32'h00000000;
        1016:    rdata = 32'h00000000;
        1017:    rdata = 32'h00000000;
        1018:    rdata = 32'h00000000;
        1019:    rdata = 32'h00000000;
        1020:    rdata = 32'h00000000;
        1021:    rdata = 32'h00000000;
        1022:    rdata = 32'h00000000;
        1023:    rdata = 32'h00000000;
        1024:    rdata = 32'h00000000;
        1025:    rdata = 32'h00000000;
        1026:    rdata = 32'h00000000;
        1027:    rdata = 32'h00000000;
        1028:    rdata = 32'h00000000;
        1029:    rdata = 32'h00000000;
        1030:    rdata = 32'h00000000;
        1031:    rdata = 32'h00000000;
        1032:    rdata = 32'h00000000;
        1033:    rdata = 32'h00000000;
        1034:    rdata = 32'h00000000;
        1035:    rdata = 32'h00000000;
        1036:    rdata = 32'h00000000;
        1037:    rdata = 32'h00000000;
        1038:    rdata = 32'h00000000;
        1039:    rdata = 32'h00000000;
        1040:    rdata = 32'h00000000;
        1041:    rdata = 32'h00000000;
        1042:    rdata = 32'h00000000;
        1043:    rdata = 32'h00000000;
        1044:    rdata = 32'h00000000;
        1045:    rdata = 32'h00000000;
        1046:    rdata = 32'h00000000;
        1047:    rdata = 32'h00000000;
        1048:    rdata = 32'h00000000;
        1049:    rdata = 32'h00000000;
        1050:    rdata = 32'h00000000;
        1051:    rdata = 32'h00000000;
        1052:    rdata = 32'h00000000;
        1053:    rdata = 32'h00000000;
        1054:    rdata = 32'h00000000;
        1055:    rdata = 32'h00000000;
        1056:    rdata = 32'h00000000;
        1057:    rdata = 32'h00000000;
        1058:    rdata = 32'h00000000;
        1059:    rdata = 32'h00000000;
        1060:    rdata = 32'h00000000;
        1061:    rdata = 32'h00000000;
        1062:    rdata = 32'h00000000;
        1063:    rdata = 32'h00000000;
        1064:    rdata = 32'h00000000;
        1065:    rdata = 32'h00000000;
        1066:    rdata = 32'h00000000;
        1067:    rdata = 32'h00000000;
        1068:    rdata = 32'h00000000;
        1069:    rdata = 32'h00000000;
        1070:    rdata = 32'h00000000;
        1071:    rdata = 32'h00000000;
        1072:    rdata = 32'h00000000;
        1073:    rdata = 32'h00000000;
        1074:    rdata = 32'h00000000;
        1075:    rdata = 32'h00000000;
        1076:    rdata = 32'h00000000;
        1077:    rdata = 32'h00000000;
        1078:    rdata = 32'h00000000;
        1079:    rdata = 32'h00000000;
        1080:    rdata = 32'h00000000;
        1081:    rdata = 32'h00000000;
        1082:    rdata = 32'h00000000;
        1083:    rdata = 32'h00000000;
        1084:    rdata = 32'h00000000;
        1085:    rdata = 32'h00000000;
        1086:    rdata = 32'h00000000;
        1087:    rdata = 32'h00000000;
        1088:    rdata = 32'h00000000;
        1089:    rdata = 32'h00000000;
        1090:    rdata = 32'h00000000;
        1091:    rdata = 32'h00000000;
        1092:    rdata = 32'h00000000;
        1093:    rdata = 32'h00000000;
        1094:    rdata = 32'h00000000;
        1095:    rdata = 32'h00000000;
        1096:    rdata = 32'h00000000;
        1097:    rdata = 32'h00000000;
        1098:    rdata = 32'h00000000;
        1099:    rdata = 32'h00000000;
        1100:    rdata = 32'h00000000;
        1101:    rdata = 32'h00000000;
        1102:    rdata = 32'h00000000;
        1103:    rdata = 32'h00000000;
        1104:    rdata = 32'h00000000;
        1105:    rdata = 32'h00000000;
        1106:    rdata = 32'h00000000;
        1107:    rdata = 32'h00000000;
        1108:    rdata = 32'h00000000;
        1109:    rdata = 32'h00000000;
        1110:    rdata = 32'h00000000;
        1111:    rdata = 32'h00000000;
        1112:    rdata = 32'h00000000;
        1113:    rdata = 32'h00000000;
        1114:    rdata = 32'h00000000;
        1115:    rdata = 32'h00000000;
        1116:    rdata = 32'h00000000;
        1117:    rdata = 32'h00000000;
        1118:    rdata = 32'h00000000;
        1119:    rdata = 32'h00000000;
        1120:    rdata = 32'h00000000;
        1121:    rdata = 32'h00000000;
        1122:    rdata = 32'h00000000;
        1123:    rdata = 32'h00000000;
        1124:    rdata = 32'h00000000;
        1125:    rdata = 32'h00000000;
        1126:    rdata = 32'h00000000;
        1127:    rdata = 32'h00000000;
        1128:    rdata = 32'h00000000;
        1129:    rdata = 32'h00000000;
        1130:    rdata = 32'h00000000;
        1131:    rdata = 32'h00000000;
        1132:    rdata = 32'h00000000;
        1133:    rdata = 32'h00000000;
        1134:    rdata = 32'h00000000;
        1135:    rdata = 32'h00000000;
        1136:    rdata = 32'h00000000;
        1137:    rdata = 32'h00000000;
        1138:    rdata = 32'h00000000;
        1139:    rdata = 32'h00000000;
        1140:    rdata = 32'h00000000;
        1141:    rdata = 32'h00000000;
        1142:    rdata = 32'h00000000;
        1143:    rdata = 32'h00000000;
        1144:    rdata = 32'h00000000;
        1145:    rdata = 32'h00000000;
        1146:    rdata = 32'h00000000;
        1147:    rdata = 32'h00000000;
        1148:    rdata = 32'h00000000;
        1149:    rdata = 32'h00000000;
        1150:    rdata = 32'h00000000;
        1151:    rdata = 32'h00000000;
        1152:    rdata = 32'h00000000;
        1153:    rdata = 32'h00000000;
        1154:    rdata = 32'h00000000;
        1155:    rdata = 32'h00000000;
        1156:    rdata = 32'h00000000;
        1157:    rdata = 32'h00000000;
        1158:    rdata = 32'h00000000;
        1159:    rdata = 32'h00000000;
        1160:    rdata = 32'h00000000;
        1161:    rdata = 32'h00000000;
        1162:    rdata = 32'h00000000;
        1163:    rdata = 32'h00000000;
        1164:    rdata = 32'h00000000;
        1165:    rdata = 32'h00000000;
        1166:    rdata = 32'h00000000;
        1167:    rdata = 32'h00000000;
        1168:    rdata = 32'h00000000;
        1169:    rdata = 32'h00000000;
        1170:    rdata = 32'h00000000;
        1171:    rdata = 32'h00000000;
        1172:    rdata = 32'h00000000;
        1173:    rdata = 32'h00000000;
        1174:    rdata = 32'h00000000;
        1175:    rdata = 32'h00000000;
        1176:    rdata = 32'h00000000;
        1177:    rdata = 32'h00000000;
        1178:    rdata = 32'h00000000;
        1179:    rdata = 32'h00000000;
        1180:    rdata = 32'h00000000;
        1181:    rdata = 32'h00000000;
        1182:    rdata = 32'h00000000;
        1183:    rdata = 32'h00000000;
        1184:    rdata = 32'h00000000;
        1185:    rdata = 32'h00000000;
        1186:    rdata = 32'h00000000;
        1187:    rdata = 32'h00000000;
        1188:    rdata = 32'h00000000;
        1189:    rdata = 32'h00000000;
        1190:    rdata = 32'h00000000;
        1191:    rdata = 32'h00000000;
        1192:    rdata = 32'h00000000;
        1193:    rdata = 32'h00000000;
        1194:    rdata = 32'h00000000;
        1195:    rdata = 32'h00000000;
        1196:    rdata = 32'h00000000;
        1197:    rdata = 32'h00000000;
        1198:    rdata = 32'h00000000;
        1199:    rdata = 32'h00000000;
        1200:    rdata = 32'h00000000;
        1201:    rdata = 32'h00000000;
        1202:    rdata = 32'h00000000;
        1203:    rdata = 32'h00000000;
        1204:    rdata = 32'h00000000;
        1205:    rdata = 32'h00000000;
        1206:    rdata = 32'h00000000;
        1207:    rdata = 32'h00000000;
        1208:    rdata = 32'h00000000;
        1209:    rdata = 32'h00000000;
        1210:    rdata = 32'h00000000;
        1211:    rdata = 32'h00000000;
        1212:    rdata = 32'h00000000;
        1213:    rdata = 32'h00000000;
        1214:    rdata = 32'h00000000;
        1215:    rdata = 32'h00000000;
        1216:    rdata = 32'h00000000;
        1217:    rdata = 32'h00000000;
        1218:    rdata = 32'h00000000;
        1219:    rdata = 32'h00000000;
        1220:    rdata = 32'h00000000;
        1221:    rdata = 32'h00000000;
        1222:    rdata = 32'h00000000;
        1223:    rdata = 32'h00000000;
        1224:    rdata = 32'h00000000;
        1225:    rdata = 32'h00000000;
        1226:    rdata = 32'h00000000;
        1227:    rdata = 32'h00000000;
        1228:    rdata = 32'h00000000;
        1229:    rdata = 32'h00000000;
        1230:    rdata = 32'h00000000;
        1231:    rdata = 32'h00000000;
        1232:    rdata = 32'h00000000;
        1233:    rdata = 32'h00000000;
        1234:    rdata = 32'h00000000;
        1235:    rdata = 32'h00000000;
        1236:    rdata = 32'h00000000;
        1237:    rdata = 32'h00000000;
        1238:    rdata = 32'h00000000;
        1239:    rdata = 32'h00000000;
        1240:    rdata = 32'h00000000;
        1241:    rdata = 32'h00000000;
        1242:    rdata = 32'h00000000;
        1243:    rdata = 32'h00000000;
        1244:    rdata = 32'h00000000;
        1245:    rdata = 32'h00000000;
        1246:    rdata = 32'h00000000;
        1247:    rdata = 32'h00000000;
        1248:    rdata = 32'h00000000;
        1249:    rdata = 32'h00000000;
        1250:    rdata = 32'h00000000;
        1251:    rdata = 32'h00000000;
        1252:    rdata = 32'h00000000;
        1253:    rdata = 32'h00000000;
        1254:    rdata = 32'h00000000;
        1255:    rdata = 32'h00000000;
        1256:    rdata = 32'h00000000;
        1257:    rdata = 32'h00000000;
        1258:    rdata = 32'h00000000;
        1259:    rdata = 32'h00000000;
        1260:    rdata = 32'h00000000;
        1261:    rdata = 32'h00000000;
        1262:    rdata = 32'h00000000;
        1263:    rdata = 32'h00000000;
        1264:    rdata = 32'h00000000;
        1265:    rdata = 32'h00000000;
        1266:    rdata = 32'h00000000;
        1267:    rdata = 32'h00000000;
        1268:    rdata = 32'h00000000;
        1269:    rdata = 32'h00000000;
        1270:    rdata = 32'h00000000;
        1271:    rdata = 32'h00000000;
        1272:    rdata = 32'h00000000;
        1273:    rdata = 32'h00000000;
        1274:    rdata = 32'h00000000;
        1275:    rdata = 32'h00000000;
        1276:    rdata = 32'h00000000;
        1277:    rdata = 32'h00000000;
        1278:    rdata = 32'h00000000;
        1279:    rdata = 32'h00000000;
        1280:    rdata = 32'h00000000;
        1281:    rdata = 32'h00000000;
        1282:    rdata = 32'h00000000;
        1283:    rdata = 32'h00000000;
        1284:    rdata = 32'h00000000;
        1285:    rdata = 32'h00000000;
        1286:    rdata = 32'h00000000;
        1287:    rdata = 32'h00000000;
        1288:    rdata = 32'h00000000;
        1289:    rdata = 32'h00000000;
        1290:    rdata = 32'h00000000;
        1291:    rdata = 32'h00000000;
        1292:    rdata = 32'h00000000;
        1293:    rdata = 32'h00000000;
        1294:    rdata = 32'h00000000;
        1295:    rdata = 32'h00000000;
        1296:    rdata = 32'h00000000;
        1297:    rdata = 32'h00000000;
        1298:    rdata = 32'h00000000;
        1299:    rdata = 32'h00000000;
        1300:    rdata = 32'h00000000;
        1301:    rdata = 32'h00000000;
        1302:    rdata = 32'h00000000;
        1303:    rdata = 32'h00000000;
        1304:    rdata = 32'h00000000;
        1305:    rdata = 32'h00000000;
        1306:    rdata = 32'h00000000;
        1307:    rdata = 32'h00000000;
        1308:    rdata = 32'h00000000;
        1309:    rdata = 32'h00000000;
        1310:    rdata = 32'h00000000;
        1311:    rdata = 32'h00000000;
        1312:    rdata = 32'h00000000;
        1313:    rdata = 32'h00000000;
        1314:    rdata = 32'h00000000;
        1315:    rdata = 32'h00000000;
        1316:    rdata = 32'h00000000;
        1317:    rdata = 32'h00000000;
        1318:    rdata = 32'h00000000;
        1319:    rdata = 32'h00000000;
        1320:    rdata = 32'h00000000;
        1321:    rdata = 32'h00000000;
        1322:    rdata = 32'h00000000;
        1323:    rdata = 32'h00000000;
        1324:    rdata = 32'h00000000;
        1325:    rdata = 32'h00000000;
        1326:    rdata = 32'h00000000;
        1327:    rdata = 32'h00000000;
        1328:    rdata = 32'h00000000;
        1329:    rdata = 32'h00000000;
        1330:    rdata = 32'h00000000;
        1331:    rdata = 32'h00000000;
        1332:    rdata = 32'h00000000;
        1333:    rdata = 32'h00000000;
        1334:    rdata = 32'h00000000;
        1335:    rdata = 32'h00000000;
        1336:    rdata = 32'h00000000;
        1337:    rdata = 32'h00000000;
        1338:    rdata = 32'h00000000;
        1339:    rdata = 32'h00000000;
        1340:    rdata = 32'h00000000;
        1341:    rdata = 32'h00000000;
        1342:    rdata = 32'h00000000;
        1343:    rdata = 32'h00000000;
        1344:    rdata = 32'h00000000;
        1345:    rdata = 32'h00000000;
        1346:    rdata = 32'h00000000;
        1347:    rdata = 32'h00000000;
        1348:    rdata = 32'h00000000;
        1349:    rdata = 32'h00000000;
        1350:    rdata = 32'h00000000;
        1351:    rdata = 32'h00000000;
        1352:    rdata = 32'h00000000;
        1353:    rdata = 32'h00000000;
        1354:    rdata = 32'h00000000;
        1355:    rdata = 32'h00000000;
        1356:    rdata = 32'h00000000;
        1357:    rdata = 32'h00000000;
        1358:    rdata = 32'h00000000;
        1359:    rdata = 32'h00000000;
        1360:    rdata = 32'h00000000;
        1361:    rdata = 32'h00000000;
        1362:    rdata = 32'h00000000;
        1363:    rdata = 32'h00000000;
        1364:    rdata = 32'h00000000;
        1365:    rdata = 32'h00000000;
        1366:    rdata = 32'h00000000;
        1367:    rdata = 32'h00000000;
        1368:    rdata = 32'h00000000;
        1369:    rdata = 32'h00000000;
        1370:    rdata = 32'h00000000;
        1371:    rdata = 32'h00000000;
        1372:    rdata = 32'h00000000;
        1373:    rdata = 32'h00000000;
        1374:    rdata = 32'h00000000;
        1375:    rdata = 32'h00000000;
        1376:    rdata = 32'h00000000;
        1377:    rdata = 32'h00000000;
        1378:    rdata = 32'h00000000;
        1379:    rdata = 32'h00000000;
        1380:    rdata = 32'h00000000;
        1381:    rdata = 32'h00000000;
        1382:    rdata = 32'h00000000;
        1383:    rdata = 32'h00000000;
        1384:    rdata = 32'h00000000;
        1385:    rdata = 32'h00000000;
        1386:    rdata = 32'h00000000;
        1387:    rdata = 32'h00000000;
        1388:    rdata = 32'h00000000;
        1389:    rdata = 32'h00000000;
        1390:    rdata = 32'h00000000;
        1391:    rdata = 32'h00000000;
        1392:    rdata = 32'h00000000;
        1393:    rdata = 32'h00000000;
        1394:    rdata = 32'h00000000;
        1395:    rdata = 32'h00000000;
        1396:    rdata = 32'h00000000;
        1397:    rdata = 32'h00000000;
        1398:    rdata = 32'h00000000;
        1399:    rdata = 32'h00000000;
        1400:    rdata = 32'h00000000;
        1401:    rdata = 32'h00000000;
        1402:    rdata = 32'h00000000;
        1403:    rdata = 32'h00000000;
        1404:    rdata = 32'h00000000;
        1405:    rdata = 32'h00000000;
        1406:    rdata = 32'h00000000;
        1407:    rdata = 32'h00000000;
        1408:    rdata = 32'h00000000;
        1409:    rdata = 32'h00000000;
        1410:    rdata = 32'h00000000;
        1411:    rdata = 32'h00000000;
        1412:    rdata = 32'h00000000;
        1413:    rdata = 32'h00000000;
        1414:    rdata = 32'h00000000;
        1415:    rdata = 32'h00000000;
        1416:    rdata = 32'h00000000;
        1417:    rdata = 32'h00000000;
        1418:    rdata = 32'h00000000;
        1419:    rdata = 32'h00000000;
        1420:    rdata = 32'h00000000;
        1421:    rdata = 32'h00000000;
        1422:    rdata = 32'h00000000;
        1423:    rdata = 32'h00000000;
        1424:    rdata = 32'h00000000;
        1425:    rdata = 32'h00000000;
        1426:    rdata = 32'h00000000;
        1427:    rdata = 32'h00000000;
        1428:    rdata = 32'h00000000;
        1429:    rdata = 32'h00000000;
        1430:    rdata = 32'h00000000;
        1431:    rdata = 32'h00000000;
        1432:    rdata = 32'h00000000;
        1433:    rdata = 32'h00000000;
        1434:    rdata = 32'h00000000;
        1435:    rdata = 32'h00000000;
        1436:    rdata = 32'h00000000;
        1437:    rdata = 32'h00000000;
        1438:    rdata = 32'h00000000;
        1439:    rdata = 32'h00000000;
        1440:    rdata = 32'h00000000;
        1441:    rdata = 32'h00000000;
        1442:    rdata = 32'h00000000;
        1443:    rdata = 32'h00000000;
        1444:    rdata = 32'h00000000;
        1445:    rdata = 32'h00000000;
        1446:    rdata = 32'h00000000;
        1447:    rdata = 32'h00000000;
        1448:    rdata = 32'h00000000;
        1449:    rdata = 32'h00000000;
        1450:    rdata = 32'h00000000;
        1451:    rdata = 32'h00000000;
        1452:    rdata = 32'h00000000;
        1453:    rdata = 32'h00000000;
        1454:    rdata = 32'h00000000;
        1455:    rdata = 32'h00000000;
        1456:    rdata = 32'h00000000;
        1457:    rdata = 32'h00000000;
        1458:    rdata = 32'h00000000;
        1459:    rdata = 32'h00000000;
        1460:    rdata = 32'h00000000;
        1461:    rdata = 32'h00000000;
        1462:    rdata = 32'h00000000;
        1463:    rdata = 32'h00000000;
        1464:    rdata = 32'h00000000;
        1465:    rdata = 32'h00000000;
        1466:    rdata = 32'h00000000;
        1467:    rdata = 32'h00000000;
        1468:    rdata = 32'h00000000;
        1469:    rdata = 32'h00000000;
        1470:    rdata = 32'h00000000;
        1471:    rdata = 32'h00000000;
        1472:    rdata = 32'h00000000;
        1473:    rdata = 32'h00000000;
        1474:    rdata = 32'h00000000;
        1475:    rdata = 32'h00000000;
        1476:    rdata = 32'h00000000;
        1477:    rdata = 32'h00000000;
        1478:    rdata = 32'h00000000;
        1479:    rdata = 32'h00000000;
        1480:    rdata = 32'h00000000;
        1481:    rdata = 32'h00000000;
        1482:    rdata = 32'h00000000;
        1483:    rdata = 32'h00000000;
        1484:    rdata = 32'h00000000;
        1485:    rdata = 32'h00000000;
        1486:    rdata = 32'h00000000;
        1487:    rdata = 32'h00000000;
        1488:    rdata = 32'h00000000;
        1489:    rdata = 32'h00000000;
        1490:    rdata = 32'h00000000;
        1491:    rdata = 32'h00000000;
        1492:    rdata = 32'h00000000;
        1493:    rdata = 32'h00000000;
        1494:    rdata = 32'h00000000;
        1495:    rdata = 32'h00000000;
        1496:    rdata = 32'h00000000;
        1497:    rdata = 32'h00000000;
        1498:    rdata = 32'h00000000;
        1499:    rdata = 32'h00000000;
        1500:    rdata = 32'h00000000;
        1501:    rdata = 32'h00000000;
        1502:    rdata = 32'h00000000;
        1503:    rdata = 32'h00000000;
        1504:    rdata = 32'h00000000;
        1505:    rdata = 32'h00000000;
        1506:    rdata = 32'h00000000;
        1507:    rdata = 32'h00000000;
        1508:    rdata = 32'h00000000;
        1509:    rdata = 32'h00000000;
        1510:    rdata = 32'h00000000;
        1511:    rdata = 32'h00000000;
        1512:    rdata = 32'h00000000;
        1513:    rdata = 32'h00000000;
        1514:    rdata = 32'h00000000;
        1515:    rdata = 32'h00000000;
        1516:    rdata = 32'h00000000;
        1517:    rdata = 32'h00000000;
        1518:    rdata = 32'h00000000;
        1519:    rdata = 32'h00000000;
        1520:    rdata = 32'h00000000;
        1521:    rdata = 32'h00000000;
        1522:    rdata = 32'h00000000;
        1523:    rdata = 32'h00000000;
        1524:    rdata = 32'h00000000;
        1525:    rdata = 32'h00000000;
        1526:    rdata = 32'h00000000;
        1527:    rdata = 32'h00000000;
        1528:    rdata = 32'h00000000;
        1529:    rdata = 32'h00000000;
        1530:    rdata = 32'h00000000;
        1531:    rdata = 32'h00000000;
        1532:    rdata = 32'h00000000;
        1533:    rdata = 32'h00000000;
        1534:    rdata = 32'h00000000;
        1535:    rdata = 32'h00000000;
        1536:    rdata = 32'h00000000;
        1537:    rdata = 32'h00000000;
        1538:    rdata = 32'h00000000;
        1539:    rdata = 32'h00000000;
        1540:    rdata = 32'h00000000;
        1541:    rdata = 32'h00000000;
        1542:    rdata = 32'h00000000;
        1543:    rdata = 32'h00000000;
        1544:    rdata = 32'h00000000;
        1545:    rdata = 32'h00000000;
        1546:    rdata = 32'h00000000;
        1547:    rdata = 32'h00000000;
        1548:    rdata = 32'h00000000;
        1549:    rdata = 32'h00000000;
        1550:    rdata = 32'h00000000;
        1551:    rdata = 32'h00000000;
        1552:    rdata = 32'h00000000;
        1553:    rdata = 32'h00000000;
        1554:    rdata = 32'h00000000;
        1555:    rdata = 32'h00000000;
        1556:    rdata = 32'h00000000;
        1557:    rdata = 32'h00000000;
        1558:    rdata = 32'h00000000;
        1559:    rdata = 32'h00000000;
        1560:    rdata = 32'h00000000;
        1561:    rdata = 32'h00000000;
        1562:    rdata = 32'h00000000;
        1563:    rdata = 32'h00000000;
        1564:    rdata = 32'h00000000;
        1565:    rdata = 32'h00000000;
        1566:    rdata = 32'h00000000;
        1567:    rdata = 32'h00000000;
        1568:    rdata = 32'h00000000;
        1569:    rdata = 32'h00000000;
        1570:    rdata = 32'h00000000;
        1571:    rdata = 32'h00000000;
        1572:    rdata = 32'h00000000;
        1573:    rdata = 32'h00000000;
        1574:    rdata = 32'h00000000;
        1575:    rdata = 32'h00000000;
        1576:    rdata = 32'h00000000;
        1577:    rdata = 32'h00000000;
        1578:    rdata = 32'h00000000;
        1579:    rdata = 32'h00000000;
        1580:    rdata = 32'h00000000;
        1581:    rdata = 32'h00000000;
        1582:    rdata = 32'h00000000;
        1583:    rdata = 32'h00000000;
        1584:    rdata = 32'h00000000;
        1585:    rdata = 32'h00000000;
        1586:    rdata = 32'h00000000;
        1587:    rdata = 32'h00000000;
        1588:    rdata = 32'h00000000;
        1589:    rdata = 32'h00000000;
        1590:    rdata = 32'h00000000;
        1591:    rdata = 32'h00000000;
        1592:    rdata = 32'h00000000;
        1593:    rdata = 32'h00000000;
        1594:    rdata = 32'h00000000;
        1595:    rdata = 32'h00000000;
        1596:    rdata = 32'h00000000;
        1597:    rdata = 32'h00000000;
        1598:    rdata = 32'h00000000;
        1599:    rdata = 32'h00000000;
        1600:    rdata = 32'h00000000;
        1601:    rdata = 32'h00000000;
        1602:    rdata = 32'h00000000;
        1603:    rdata = 32'h00000000;
        1604:    rdata = 32'h00000000;
        1605:    rdata = 32'h00000000;
        1606:    rdata = 32'h00000000;
        1607:    rdata = 32'h00000000;
        1608:    rdata = 32'h00000000;
        1609:    rdata = 32'h00000000;
        1610:    rdata = 32'h00000000;
        1611:    rdata = 32'h00000000;
        1612:    rdata = 32'h00000000;
        1613:    rdata = 32'h00000000;
        1614:    rdata = 32'h00000000;
        1615:    rdata = 32'h00000000;
        1616:    rdata = 32'h00000000;
        1617:    rdata = 32'h00000000;
        1618:    rdata = 32'h00000000;
        1619:    rdata = 32'h00000000;
        1620:    rdata = 32'h00000000;
        1621:    rdata = 32'h00000000;
        1622:    rdata = 32'h00000000;
        1623:    rdata = 32'h00000000;
        1624:    rdata = 32'h00000000;
        1625:    rdata = 32'h00000000;
        1626:    rdata = 32'h00000000;
        1627:    rdata = 32'h00000000;
        1628:    rdata = 32'h00000000;
        1629:    rdata = 32'h00000000;
        1630:    rdata = 32'h00000000;
        1631:    rdata = 32'h00000000;
        1632:    rdata = 32'h00000000;
        1633:    rdata = 32'h00000000;
        1634:    rdata = 32'h00000000;
        1635:    rdata = 32'h00000000;
        1636:    rdata = 32'h00000000;
        1637:    rdata = 32'h00000000;
        1638:    rdata = 32'h00000000;
        1639:    rdata = 32'h00000000;
        1640:    rdata = 32'h00000000;
        1641:    rdata = 32'h00000000;
        1642:    rdata = 32'h00000000;
        1643:    rdata = 32'h00000000;
        1644:    rdata = 32'h00000000;
        1645:    rdata = 32'h00000000;
        1646:    rdata = 32'h00000000;
        1647:    rdata = 32'h00000000;
        1648:    rdata = 32'h00000000;
        1649:    rdata = 32'h00000000;
        1650:    rdata = 32'h00000000;
        1651:    rdata = 32'h00000000;
        1652:    rdata = 32'h00000000;
        1653:    rdata = 32'h00000000;
        1654:    rdata = 32'h00000000;
        1655:    rdata = 32'h00000000;
        1656:    rdata = 32'h00000000;
        1657:    rdata = 32'h00000000;
        1658:    rdata = 32'h00000000;
        1659:    rdata = 32'h00000000;
        1660:    rdata = 32'h00000000;
        1661:    rdata = 32'h00000000;
        1662:    rdata = 32'h00000000;
        1663:    rdata = 32'h00000000;
        1664:    rdata = 32'h00000000;
        1665:    rdata = 32'h00000000;
        1666:    rdata = 32'h00000000;
        1667:    rdata = 32'h00000000;
        1668:    rdata = 32'h00000000;
        1669:    rdata = 32'h00000000;
        1670:    rdata = 32'h00000000;
        1671:    rdata = 32'h00000000;
        1672:    rdata = 32'h00000000;
        1673:    rdata = 32'h00000000;
        1674:    rdata = 32'h00000000;
        1675:    rdata = 32'h00000000;
        1676:    rdata = 32'h00000000;
        1677:    rdata = 32'h00000000;
        1678:    rdata = 32'h00000000;
        1679:    rdata = 32'h00000000;
        1680:    rdata = 32'h00000000;
        1681:    rdata = 32'h00000000;
        1682:    rdata = 32'h00000000;
        1683:    rdata = 32'h00000000;
        1684:    rdata = 32'h00000000;
        1685:    rdata = 32'h00000000;
        1686:    rdata = 32'h00000000;
        1687:    rdata = 32'h00000000;
        1688:    rdata = 32'h00000000;
        1689:    rdata = 32'h00000000;
        1690:    rdata = 32'h00000000;
        1691:    rdata = 32'h00000000;
        1692:    rdata = 32'h00000000;
        1693:    rdata = 32'h00000000;
        1694:    rdata = 32'h00000000;
        1695:    rdata = 32'h00000000;
        1696:    rdata = 32'h00000000;
        1697:    rdata = 32'h00000000;
        1698:    rdata = 32'h00000000;
        1699:    rdata = 32'h00000000;
        1700:    rdata = 32'h00000000;
        1701:    rdata = 32'h00000000;
        1702:    rdata = 32'h00000000;
        1703:    rdata = 32'h00000000;
        1704:    rdata = 32'h00000000;
        1705:    rdata = 32'h00000000;
        1706:    rdata = 32'h00000000;
        1707:    rdata = 32'h00000000;
        1708:    rdata = 32'h00000000;
        1709:    rdata = 32'h00000000;
        1710:    rdata = 32'h00000000;
        1711:    rdata = 32'h00000000;
        1712:    rdata = 32'h00000000;
        1713:    rdata = 32'h00000000;
        1714:    rdata = 32'h00000000;
        1715:    rdata = 32'h00000000;
        1716:    rdata = 32'h00000000;
        1717:    rdata = 32'h00000000;
        1718:    rdata = 32'h00000000;
        1719:    rdata = 32'h00000000;
        1720:    rdata = 32'h00000000;
        1721:    rdata = 32'h00000000;
        1722:    rdata = 32'h00000000;
        1723:    rdata = 32'h00000000;
        1724:    rdata = 32'h00000000;
        1725:    rdata = 32'h00000000;
        1726:    rdata = 32'h00000000;
        1727:    rdata = 32'h00000000;
        1728:    rdata = 32'h00000000;
        1729:    rdata = 32'h00000000;
        1730:    rdata = 32'h00000000;
        1731:    rdata = 32'h00000000;
        1732:    rdata = 32'h00000000;
        1733:    rdata = 32'h00000000;
        1734:    rdata = 32'h00000000;
        1735:    rdata = 32'h00000000;
        1736:    rdata = 32'h00000000;
        1737:    rdata = 32'h00000000;
        1738:    rdata = 32'h00000000;
        1739:    rdata = 32'h00000000;
        1740:    rdata = 32'h00000000;
        1741:    rdata = 32'h00000000;
        1742:    rdata = 32'h00000000;
        1743:    rdata = 32'h00000000;
        1744:    rdata = 32'h00000000;
        1745:    rdata = 32'h00000000;
        1746:    rdata = 32'h00000000;
        1747:    rdata = 32'h00000000;
        1748:    rdata = 32'h00000000;
        1749:    rdata = 32'h00000000;
        1750:    rdata = 32'h00000000;
        1751:    rdata = 32'h00000000;
        1752:    rdata = 32'h00000000;
        1753:    rdata = 32'h00000000;
        1754:    rdata = 32'h00000000;
        1755:    rdata = 32'h00000000;
        1756:    rdata = 32'h00000000;
        1757:    rdata = 32'h00000000;
        1758:    rdata = 32'h00000000;
        1759:    rdata = 32'h00000000;
        1760:    rdata = 32'h00000000;
        1761:    rdata = 32'h00000000;
        1762:    rdata = 32'h00000000;
        1763:    rdata = 32'h00000000;
        1764:    rdata = 32'h00000000;
        1765:    rdata = 32'h00000000;
        1766:    rdata = 32'h00000000;
        1767:    rdata = 32'h00000000;
        1768:    rdata = 32'h00000000;
        1769:    rdata = 32'h00000000;
        1770:    rdata = 32'h00000000;
        1771:    rdata = 32'h00000000;
        1772:    rdata = 32'h00000000;
        1773:    rdata = 32'h00000000;
        1774:    rdata = 32'h00000000;
        1775:    rdata = 32'h00000000;
        1776:    rdata = 32'h00000000;
        1777:    rdata = 32'h00000000;
        1778:    rdata = 32'h00000000;
        1779:    rdata = 32'h00000000;
        1780:    rdata = 32'h00000000;
        1781:    rdata = 32'h00000000;
        1782:    rdata = 32'h00000000;
        1783:    rdata = 32'h00000000;
        1784:    rdata = 32'h00000000;
        1785:    rdata = 32'h00000000;
        1786:    rdata = 32'h00000000;
        1787:    rdata = 32'h00000000;
        1788:    rdata = 32'h00000000;
        1789:    rdata = 32'h00000000;
        1790:    rdata = 32'h00000000;
        1791:    rdata = 32'h00000000;
        1792:    rdata = 32'h00000000;
        1793:    rdata = 32'h00000000;
        1794:    rdata = 32'h00000000;
        1795:    rdata = 32'h00000000;
        1796:    rdata = 32'h00000000;
        1797:    rdata = 32'h00000000;
        1798:    rdata = 32'h00000000;
        1799:    rdata = 32'h00000000;
        1800:    rdata = 32'h00000000;
        1801:    rdata = 32'h00000000;
        1802:    rdata = 32'h00000000;
        1803:    rdata = 32'h00000000;
        1804:    rdata = 32'h00000000;
        1805:    rdata = 32'h00000000;
        1806:    rdata = 32'h00000000;
        1807:    rdata = 32'h00000000;
        1808:    rdata = 32'h00000000;
        1809:    rdata = 32'h00000000;
        1810:    rdata = 32'h00000000;
        1811:    rdata = 32'h00000000;
        1812:    rdata = 32'h00000000;
        1813:    rdata = 32'h00000000;
        1814:    rdata = 32'h00000000;
        1815:    rdata = 32'h00000000;
        1816:    rdata = 32'h00000000;
        1817:    rdata = 32'h00000000;
        1818:    rdata = 32'h00000000;
        1819:    rdata = 32'h00000000;
        1820:    rdata = 32'h00000000;
        1821:    rdata = 32'h00000000;
        1822:    rdata = 32'h00000000;
        1823:    rdata = 32'h00000000;
        1824:    rdata = 32'h00000000;
        1825:    rdata = 32'h00000000;
        1826:    rdata = 32'h00000000;
        1827:    rdata = 32'h00000000;
        1828:    rdata = 32'h00000000;
        1829:    rdata = 32'h00000000;
        1830:    rdata = 32'h00000000;
        1831:    rdata = 32'h00000000;
        1832:    rdata = 32'h00000000;
        1833:    rdata = 32'h00000000;
        1834:    rdata = 32'h00000000;
        1835:    rdata = 32'h00000000;
        1836:    rdata = 32'h00000000;
        1837:    rdata = 32'h00000000;
        1838:    rdata = 32'h00000000;
        1839:    rdata = 32'h00000000;
        1840:    rdata = 32'h00000000;
        1841:    rdata = 32'h00000000;
        1842:    rdata = 32'h00000000;
        1843:    rdata = 32'h00000000;
        1844:    rdata = 32'h00000000;
        1845:    rdata = 32'h00000000;
        1846:    rdata = 32'h00000000;
        1847:    rdata = 32'h00000000;
        1848:    rdata = 32'h00000000;
        1849:    rdata = 32'h00000000;
        1850:    rdata = 32'h00000000;
        1851:    rdata = 32'h00000000;
        1852:    rdata = 32'h00000000;
        1853:    rdata = 32'h00000000;
        1854:    rdata = 32'h00000000;
        1855:    rdata = 32'h00000000;
        1856:    rdata = 32'h00000000;
        1857:    rdata = 32'h00000000;
        1858:    rdata = 32'h00000000;
        1859:    rdata = 32'h00000000;
        1860:    rdata = 32'h00000000;
        1861:    rdata = 32'h00000000;
        1862:    rdata = 32'h00000000;
        1863:    rdata = 32'h00000000;
        1864:    rdata = 32'h00000000;
        1865:    rdata = 32'h00000000;
        1866:    rdata = 32'h00000000;
        1867:    rdata = 32'h00000000;
        1868:    rdata = 32'h00000000;
        1869:    rdata = 32'h00000000;
        1870:    rdata = 32'h00000000;
        1871:    rdata = 32'h00000000;
        1872:    rdata = 32'h00000000;
        1873:    rdata = 32'h00000000;
        1874:    rdata = 32'h00000000;
        1875:    rdata = 32'h00000000;
        1876:    rdata = 32'h00000000;
        1877:    rdata = 32'h00000000;
        1878:    rdata = 32'h00000000;
        1879:    rdata = 32'h00000000;
        1880:    rdata = 32'h00000000;
        1881:    rdata = 32'h00000000;
        1882:    rdata = 32'h00000000;
        1883:    rdata = 32'h00000000;
        1884:    rdata = 32'h00000000;
        1885:    rdata = 32'h00000000;
        1886:    rdata = 32'h00000000;
        1887:    rdata = 32'h00000000;
        1888:    rdata = 32'h00000000;
        1889:    rdata = 32'h00000000;
        1890:    rdata = 32'h00000000;
        1891:    rdata = 32'h00000000;
        1892:    rdata = 32'h00000000;
        1893:    rdata = 32'h00000000;
        1894:    rdata = 32'h00000000;
        1895:    rdata = 32'h00000000;
        1896:    rdata = 32'h00000000;
        1897:    rdata = 32'h00000000;
        1898:    rdata = 32'h00000000;
        1899:    rdata = 32'h00000000;
        1900:    rdata = 32'h00000000;
        1901:    rdata = 32'h00000000;
        1902:    rdata = 32'h00000000;
        1903:    rdata = 32'h00000000;
        1904:    rdata = 32'h00000000;
        1905:    rdata = 32'h00000000;
        1906:    rdata = 32'h00000000;
        1907:    rdata = 32'h00000000;
        1908:    rdata = 32'h00000000;
        1909:    rdata = 32'h00000000;
        1910:    rdata = 32'h00000000;
        1911:    rdata = 32'h00000000;
        1912:    rdata = 32'h00000000;
        1913:    rdata = 32'h00000000;
        1914:    rdata = 32'h00000000;
        1915:    rdata = 32'h00000000;
        1916:    rdata = 32'h00000000;
        1917:    rdata = 32'h00000000;
        1918:    rdata = 32'h00000000;
        1919:    rdata = 32'h00000000;
        1920:    rdata = 32'h00000000;
        1921:    rdata = 32'h00000000;
        1922:    rdata = 32'h00000000;
        1923:    rdata = 32'h00000000;
        1924:    rdata = 32'h00000000;
        1925:    rdata = 32'h00000000;
        1926:    rdata = 32'h00000000;
        1927:    rdata = 32'h00000000;
        1928:    rdata = 32'h00000000;
        1929:    rdata = 32'h00000000;
        1930:    rdata = 32'h00000000;
        1931:    rdata = 32'h00000000;
        1932:    rdata = 32'h00000000;
        1933:    rdata = 32'h00000000;
        1934:    rdata = 32'h00000000;
        1935:    rdata = 32'h00000000;
        1936:    rdata = 32'h00000000;
        1937:    rdata = 32'h00000000;
        1938:    rdata = 32'h00000000;
        1939:    rdata = 32'h00000000;
        1940:    rdata = 32'h00000000;
        1941:    rdata = 32'h00000000;
        1942:    rdata = 32'h00000000;
        1943:    rdata = 32'h00000000;
        1944:    rdata = 32'h00000000;
        1945:    rdata = 32'h00000000;
        1946:    rdata = 32'h00000000;
        1947:    rdata = 32'h00000000;
        1948:    rdata = 32'h00000000;
        1949:    rdata = 32'h00000000;
        1950:    rdata = 32'h00000000;
        1951:    rdata = 32'h00000000;
        1952:    rdata = 32'h00000000;
        1953:    rdata = 32'h00000000;
        1954:    rdata = 32'h00000000;
        1955:    rdata = 32'h00000000;
        1956:    rdata = 32'h00000000;
        1957:    rdata = 32'h00000000;
        1958:    rdata = 32'h00000000;
        1959:    rdata = 32'h00000000;
        1960:    rdata = 32'h00000000;
        1961:    rdata = 32'h00000000;
        1962:    rdata = 32'h00000000;
        1963:    rdata = 32'h00000000;
        1964:    rdata = 32'h00000000;
        1965:    rdata = 32'h00000000;
        1966:    rdata = 32'h00000000;
        1967:    rdata = 32'h00000000;
        1968:    rdata = 32'h00000000;
        1969:    rdata = 32'h00000000;
        1970:    rdata = 32'h00000000;
        1971:    rdata = 32'h00000000;
        1972:    rdata = 32'h00000000;
        1973:    rdata = 32'h00000000;
        1974:    rdata = 32'h00000000;
        1975:    rdata = 32'h00000000;
        1976:    rdata = 32'h00000000;
        1977:    rdata = 32'h00000000;
        1978:    rdata = 32'h00000000;
        1979:    rdata = 32'h00000000;
        1980:    rdata = 32'h00000000;
        1981:    rdata = 32'h00000000;
        1982:    rdata = 32'h00000000;
        1983:    rdata = 32'h00000000;
        1984:    rdata = 32'h00000000;
        1985:    rdata = 32'h00000000;
        1986:    rdata = 32'h00000000;
        1987:    rdata = 32'h00000000;
        1988:    rdata = 32'h00000000;
        1989:    rdata = 32'h00000000;
        1990:    rdata = 32'h00000000;
        1991:    rdata = 32'h00000000;
        1992:    rdata = 32'h00000000;
        1993:    rdata = 32'h00000000;
        1994:    rdata = 32'h00000000;
        1995:    rdata = 32'h00000000;
        1996:    rdata = 32'h00000000;
        1997:    rdata = 32'h00000000;
        1998:    rdata = 32'h00000000;
        1999:    rdata = 32'h00000000;
        2000:    rdata = 32'h00000000;
        2001:    rdata = 32'h00000000;
        2002:    rdata = 32'h00000000;
        2003:    rdata = 32'h00000000;
        2004:    rdata = 32'h00000000;
        2005:    rdata = 32'h00000000;
        2006:    rdata = 32'h00000000;
        2007:    rdata = 32'h00000000;
        2008:    rdata = 32'h00000000;
        2009:    rdata = 32'h00000000;
        2010:    rdata = 32'h00000000;
        2011:    rdata = 32'h00000000;
        2012:    rdata = 32'h00000000;
        2013:    rdata = 32'h00000000;
        2014:    rdata = 32'h00000000;
        2015:    rdata = 32'h00000000;
        2016:    rdata = 32'h00000000;
        2017:    rdata = 32'h00000000;
        2018:    rdata = 32'h00000000;
        2019:    rdata = 32'h00000000;
        2020:    rdata = 32'h00000000;
        2021:    rdata = 32'h00000000;
        2022:    rdata = 32'h00000000;
        2023:    rdata = 32'h00000000;
        2024:    rdata = 32'h00000000;
        2025:    rdata = 32'h00000000;
        2026:    rdata = 32'h00000000;
        2027:    rdata = 32'h00000000;
        2028:    rdata = 32'h00000000;
        2029:    rdata = 32'h00000000;
        2030:    rdata = 32'h00000000;
        2031:    rdata = 32'h00000000;
        2032:    rdata = 32'h00000000;
        2033:    rdata = 32'h00000000;
        2034:    rdata = 32'h00000000;
        2035:    rdata = 32'h00000000;
        2036:    rdata = 32'h00000000;
        2037:    rdata = 32'h00000000;
        2038:    rdata = 32'h00000000;
        2039:    rdata = 32'h00000000;
        2040:    rdata = 32'h00000000;
        2041:    rdata = 32'h00000000;
        2042:    rdata = 32'h00000000;
        2043:    rdata = 32'h00000000;
        2044:    rdata = 32'h00000000;
        2045:    rdata = 32'h00000000;
        2046:    rdata = 32'h00000000;
        2047:    rdata = 32'h00000000;
        2048:    rdata = 32'h00000000;
        2049:    rdata = 32'h00000000;
        2050:    rdata = 32'h00000000;
        2051:    rdata = 32'h00000000;
        2052:    rdata = 32'h00000000;
        2053:    rdata = 32'h00000000;
        2054:    rdata = 32'h00000000;
        2055:    rdata = 32'h00000000;
        2056:    rdata = 32'h00000000;
        2057:    rdata = 32'h00000000;
        2058:    rdata = 32'h00000000;
        2059:    rdata = 32'h00000000;
        2060:    rdata = 32'h00000000;
        2061:    rdata = 32'h00000000;
        2062:    rdata = 32'h00000000;
        2063:    rdata = 32'h00000000;
        2064:    rdata = 32'h00000000;
        2065:    rdata = 32'h00000000;
        2066:    rdata = 32'h00000000;
        2067:    rdata = 32'h00000000;
        2068:    rdata = 32'h00000000;
        2069:    rdata = 32'h00000000;
        2070:    rdata = 32'h00000000;
        2071:    rdata = 32'h00000000;
        2072:    rdata = 32'h00000000;
        2073:    rdata = 32'h00000000;
        2074:    rdata = 32'h00000000;
        2075:    rdata = 32'h00000000;
        2076:    rdata = 32'h00000000;
        2077:    rdata = 32'h00000000;
        2078:    rdata = 32'h00000000;
        2079:    rdata = 32'h00000000;
        2080:    rdata = 32'h00000000;
        2081:    rdata = 32'h00000000;
        2082:    rdata = 32'h00000000;
        2083:    rdata = 32'h00000000;
        2084:    rdata = 32'h00000000;
        2085:    rdata = 32'h00000000;
        2086:    rdata = 32'h00000000;
        2087:    rdata = 32'h00000000;
        2088:    rdata = 32'h00000000;
        2089:    rdata = 32'h00000000;
        2090:    rdata = 32'h00000000;
        2091:    rdata = 32'h00000000;
        2092:    rdata = 32'h00000000;
        2093:    rdata = 32'h00000000;
        2094:    rdata = 32'h00000000;
        2095:    rdata = 32'h00000000;
        2096:    rdata = 32'h00000000;
        2097:    rdata = 32'h00000000;
        2098:    rdata = 32'h00000000;
        2099:    rdata = 32'h00000000;
        2100:    rdata = 32'h00000000;
        2101:    rdata = 32'h00000000;
        2102:    rdata = 32'h00000000;
        2103:    rdata = 32'h00000000;
        2104:    rdata = 32'h00000000;
        2105:    rdata = 32'h00000000;
        2106:    rdata = 32'h00000000;
        2107:    rdata = 32'h00000000;
        2108:    rdata = 32'h00000000;
        2109:    rdata = 32'h00000000;
        2110:    rdata = 32'h00000000;
        2111:    rdata = 32'h00000000;
        2112:    rdata = 32'h00000000;
        2113:    rdata = 32'h00000000;
        2114:    rdata = 32'h00000000;
        2115:    rdata = 32'h00000000;
        2116:    rdata = 32'h00000000;
        2117:    rdata = 32'h00000000;
        2118:    rdata = 32'h00000000;
        2119:    rdata = 32'h00000000;
        2120:    rdata = 32'h00000000;
        2121:    rdata = 32'h00000000;
        2122:    rdata = 32'h00000000;
        2123:    rdata = 32'h00000000;
        2124:    rdata = 32'h00000000;
        2125:    rdata = 32'h00000000;
        2126:    rdata = 32'h00000000;
        2127:    rdata = 32'h00000000;
        2128:    rdata = 32'h00000000;
        2129:    rdata = 32'h00000000;
        2130:    rdata = 32'h00000000;
        2131:    rdata = 32'h00000000;
        2132:    rdata = 32'h00000000;
        2133:    rdata = 32'h00000000;
        2134:    rdata = 32'h00000000;
        2135:    rdata = 32'h00000000;
        2136:    rdata = 32'h00000000;
        2137:    rdata = 32'h00000000;
        2138:    rdata = 32'h00000000;
        2139:    rdata = 32'h00000000;
        2140:    rdata = 32'h00000000;
        2141:    rdata = 32'h00000000;
        2142:    rdata = 32'h00000000;
        2143:    rdata = 32'h00000000;
        2144:    rdata = 32'h00000000;
        2145:    rdata = 32'h00000000;
        2146:    rdata = 32'h00000000;
        2147:    rdata = 32'h00000000;
        2148:    rdata = 32'h00000000;
        2149:    rdata = 32'h00000000;
        2150:    rdata = 32'h00000000;
        2151:    rdata = 32'h00000000;
        2152:    rdata = 32'h00000000;
        2153:    rdata = 32'h00000000;
        2154:    rdata = 32'h00000000;
        2155:    rdata = 32'h00000000;
        2156:    rdata = 32'h00000000;
        2157:    rdata = 32'h00000000;
        2158:    rdata = 32'h00000000;
        2159:    rdata = 32'h00000000;
        2160:    rdata = 32'h00000000;
        2161:    rdata = 32'h00000000;
        2162:    rdata = 32'h00000000;
        2163:    rdata = 32'h00000000;
        2164:    rdata = 32'h00000000;
        2165:    rdata = 32'h00000000;
        2166:    rdata = 32'h00000000;
        2167:    rdata = 32'h00000000;
        2168:    rdata = 32'h00000000;
        2169:    rdata = 32'h00000000;
        2170:    rdata = 32'h00000000;
        2171:    rdata = 32'h00000000;
        2172:    rdata = 32'h00000000;
        2173:    rdata = 32'h00000000;
        2174:    rdata = 32'h00000000;
        2175:    rdata = 32'h00000000;
        2176:    rdata = 32'h00000000;
        2177:    rdata = 32'h00000000;
        2178:    rdata = 32'h00000000;
        2179:    rdata = 32'h00000000;
        2180:    rdata = 32'h00000000;
        2181:    rdata = 32'h00000000;
        2182:    rdata = 32'h00000000;
        2183:    rdata = 32'h00000000;
        2184:    rdata = 32'h00000000;
        2185:    rdata = 32'h00000000;
        2186:    rdata = 32'h00000000;
        2187:    rdata = 32'h00000000;
        2188:    rdata = 32'h00000000;
        2189:    rdata = 32'h00000000;
        2190:    rdata = 32'h00000000;
        2191:    rdata = 32'h00000000;
        2192:    rdata = 32'h00000000;
        2193:    rdata = 32'h00000000;
        2194:    rdata = 32'h00000000;
        2195:    rdata = 32'h00000000;
        2196:    rdata = 32'h00000000;
        2197:    rdata = 32'h00000000;
        2198:    rdata = 32'h00000000;
        2199:    rdata = 32'h00000000;
        2200:    rdata = 32'h00000000;
        2201:    rdata = 32'h00000000;
        2202:    rdata = 32'h00000000;
        2203:    rdata = 32'h00000000;
        2204:    rdata = 32'h00000000;
        2205:    rdata = 32'h00000000;
        2206:    rdata = 32'h00000000;
        2207:    rdata = 32'h00000000;
        2208:    rdata = 32'h00000000;
        2209:    rdata = 32'h00000000;
        2210:    rdata = 32'h00000000;
        2211:    rdata = 32'h00000000;
        2212:    rdata = 32'h00000000;
        2213:    rdata = 32'h00000000;
        2214:    rdata = 32'h00000000;
        2215:    rdata = 32'h00000000;
        2216:    rdata = 32'h00000000;
        2217:    rdata = 32'h00000000;
        2218:    rdata = 32'h00000000;
        2219:    rdata = 32'h00000000;
        2220:    rdata = 32'h00000000;
        2221:    rdata = 32'h00000000;
        2222:    rdata = 32'h00000000;
        2223:    rdata = 32'h00000000;
        2224:    rdata = 32'h00000000;
        2225:    rdata = 32'h00000000;
        2226:    rdata = 32'h00000000;
        2227:    rdata = 32'h00000000;
        2228:    rdata = 32'h00000000;
        2229:    rdata = 32'h00000000;
        2230:    rdata = 32'h00000000;
        2231:    rdata = 32'h00000000;
        2232:    rdata = 32'h00000000;
        2233:    rdata = 32'h00000000;
        2234:    rdata = 32'h00000000;
        2235:    rdata = 32'h00000000;
        2236:    rdata = 32'h00000000;
        2237:    rdata = 32'h00000000;
        2238:    rdata = 32'h00000000;
        2239:    rdata = 32'h00000000;
        2240:    rdata = 32'h00000000;
        2241:    rdata = 32'h00000000;
        2242:    rdata = 32'h00000000;
        2243:    rdata = 32'h00000000;
        2244:    rdata = 32'h00000000;
        2245:    rdata = 32'h00000000;
        2246:    rdata = 32'h00000000;
        2247:    rdata = 32'h00000000;
        2248:    rdata = 32'h00000000;
        2249:    rdata = 32'h00000000;
        2250:    rdata = 32'h00000000;
        2251:    rdata = 32'h00000000;
        2252:    rdata = 32'h00000000;
        2253:    rdata = 32'h00000000;
        2254:    rdata = 32'h00000000;
        2255:    rdata = 32'h00000000;
        2256:    rdata = 32'h00000000;
        2257:    rdata = 32'h00000000;
        2258:    rdata = 32'h00000000;
        2259:    rdata = 32'h00000000;
        2260:    rdata = 32'h00000000;
        2261:    rdata = 32'h00000000;
        2262:    rdata = 32'h00000000;
        2263:    rdata = 32'h00000000;
        2264:    rdata = 32'h00000000;
        2265:    rdata = 32'h00000000;
        2266:    rdata = 32'h00000000;
        2267:    rdata = 32'h00000000;
        2268:    rdata = 32'h00000000;
        2269:    rdata = 32'h00000000;
        2270:    rdata = 32'h00000000;
        2271:    rdata = 32'h00000000;
        2272:    rdata = 32'h00000000;
        2273:    rdata = 32'h00000000;
        2274:    rdata = 32'h00000000;
        2275:    rdata = 32'h00000000;
        2276:    rdata = 32'h00000000;
        2277:    rdata = 32'h00000000;
        2278:    rdata = 32'h00000000;
        2279:    rdata = 32'h00000000;
        2280:    rdata = 32'h00000000;
        2281:    rdata = 32'h00000000;
        2282:    rdata = 32'h00000000;
        2283:    rdata = 32'h00000000;
        2284:    rdata = 32'h00000000;
        2285:    rdata = 32'h00000000;
        2286:    rdata = 32'h00000000;
        2287:    rdata = 32'h00000000;
        2288:    rdata = 32'h00000000;
        2289:    rdata = 32'h00000000;
        2290:    rdata = 32'h00000000;
        2291:    rdata = 32'h00000000;
        2292:    rdata = 32'h00000000;
        2293:    rdata = 32'h00000000;
        2294:    rdata = 32'h00000000;
        2295:    rdata = 32'h00000000;
        2296:    rdata = 32'h00000000;
        2297:    rdata = 32'h00000000;
        2298:    rdata = 32'h00000000;
        2299:    rdata = 32'h00000000;
        2300:    rdata = 32'h00000000;
        2301:    rdata = 32'h00000000;
        2302:    rdata = 32'h00000000;
        2303:    rdata = 32'h00000000;
        2304:    rdata = 32'h00000000;
        2305:    rdata = 32'h00000000;
        2306:    rdata = 32'h00000000;
        2307:    rdata = 32'h00000000;
        2308:    rdata = 32'h00000000;
        2309:    rdata = 32'h00000000;
        2310:    rdata = 32'h00000000;
        2311:    rdata = 32'h00000000;
        2312:    rdata = 32'h00000000;
        2313:    rdata = 32'h00000000;
        2314:    rdata = 32'h00000000;
        2315:    rdata = 32'h00000000;
        2316:    rdata = 32'h00000000;
        2317:    rdata = 32'h00000000;
        2318:    rdata = 32'h00000000;
        2319:    rdata = 32'h00000000;
        2320:    rdata = 32'h00000000;
        2321:    rdata = 32'h00000000;
        2322:    rdata = 32'h00000000;
        2323:    rdata = 32'h00000000;
        2324:    rdata = 32'h00000000;
        2325:    rdata = 32'h00000000;
        2326:    rdata = 32'h00000000;
        2327:    rdata = 32'h00000000;
        2328:    rdata = 32'h00000000;
        2329:    rdata = 32'h00000000;
        2330:    rdata = 32'h00000000;
        2331:    rdata = 32'h00000000;
        2332:    rdata = 32'h00000000;
        2333:    rdata = 32'h00000000;
        2334:    rdata = 32'h00000000;
        2335:    rdata = 32'h00000000;
        2336:    rdata = 32'h00000000;
        2337:    rdata = 32'h00000000;
        2338:    rdata = 32'h00000000;
        2339:    rdata = 32'h00000000;
        2340:    rdata = 32'h00000000;
        2341:    rdata = 32'h00000000;
        2342:    rdata = 32'h00000000;
        2343:    rdata = 32'h00000000;
        2344:    rdata = 32'h00000000;
        2345:    rdata = 32'h00000000;
        2346:    rdata = 32'h00000000;
        2347:    rdata = 32'h00000000;
        2348:    rdata = 32'h00000000;
        2349:    rdata = 32'h00000000;
        2350:    rdata = 32'h00000000;
        2351:    rdata = 32'h00000000;
        2352:    rdata = 32'h00000000;
        2353:    rdata = 32'h00000000;
        2354:    rdata = 32'h00000000;
        2355:    rdata = 32'h00000000;
        2356:    rdata = 32'h00000000;
        2357:    rdata = 32'h00000000;
        2358:    rdata = 32'h00000000;
        2359:    rdata = 32'h00000000;
        2360:    rdata = 32'h00000000;
        2361:    rdata = 32'h00000000;
        2362:    rdata = 32'h00000000;
        2363:    rdata = 32'h00000000;
        2364:    rdata = 32'h00000000;
        2365:    rdata = 32'h00000000;
        2366:    rdata = 32'h00000000;
        2367:    rdata = 32'h00000000;
        2368:    rdata = 32'h00000000;
        2369:    rdata = 32'h00000000;
        2370:    rdata = 32'h00000000;
        2371:    rdata = 32'h00000000;
        2372:    rdata = 32'h00000000;
        2373:    rdata = 32'h00000000;
        2374:    rdata = 32'h00000000;
        2375:    rdata = 32'h00000000;
        2376:    rdata = 32'h00000000;
        2377:    rdata = 32'h00000000;
        2378:    rdata = 32'h00000000;
        2379:    rdata = 32'h00000000;
        2380:    rdata = 32'h00000000;
        2381:    rdata = 32'h00000000;
        2382:    rdata = 32'h00000000;
        2383:    rdata = 32'h00000000;
        2384:    rdata = 32'h00000000;
        2385:    rdata = 32'h00000000;
        2386:    rdata = 32'h00000000;
        2387:    rdata = 32'h00000000;
        2388:    rdata = 32'h00000000;
        2389:    rdata = 32'h00000000;
        2390:    rdata = 32'h00000000;
        2391:    rdata = 32'h00000000;
        2392:    rdata = 32'h00000000;
        2393:    rdata = 32'h00000000;
        2394:    rdata = 32'h00000000;
        2395:    rdata = 32'h00000000;
        2396:    rdata = 32'h00000000;
        2397:    rdata = 32'h00000000;
        2398:    rdata = 32'h00000000;
        2399:    rdata = 32'h00000000;
        2400:    rdata = 32'h00000000;
        2401:    rdata = 32'h00000000;
        2402:    rdata = 32'h00000000;
        2403:    rdata = 32'h00000000;
        2404:    rdata = 32'h00000000;
        2405:    rdata = 32'h00000000;
        2406:    rdata = 32'h00000000;
        2407:    rdata = 32'h00000000;
        2408:    rdata = 32'h00000000;
        2409:    rdata = 32'h00000000;
        2410:    rdata = 32'h00000000;
        2411:    rdata = 32'h00000000;
        2412:    rdata = 32'h00000000;
        2413:    rdata = 32'h00000000;
        2414:    rdata = 32'h00000000;
        2415:    rdata = 32'h00000000;
        2416:    rdata = 32'h00000000;
        2417:    rdata = 32'h00000000;
        2418:    rdata = 32'h00000000;
        2419:    rdata = 32'h00000000;
        2420:    rdata = 32'h00000000;
        2421:    rdata = 32'h00000000;
        2422:    rdata = 32'h00000000;
        2423:    rdata = 32'h00000000;
        2424:    rdata = 32'h00000000;
        2425:    rdata = 32'h00000000;
        2426:    rdata = 32'h00000000;
        2427:    rdata = 32'h00000000;
        2428:    rdata = 32'h00000000;
        2429:    rdata = 32'h00000000;
        2430:    rdata = 32'h00000000;
        2431:    rdata = 32'h00000000;
        2432:    rdata = 32'h00000000;
        2433:    rdata = 32'h00000000;
        2434:    rdata = 32'h00000000;
        2435:    rdata = 32'h00000000;
        2436:    rdata = 32'h00000000;
        2437:    rdata = 32'h00000000;
        2438:    rdata = 32'h00000000;
        2439:    rdata = 32'h00000000;
        2440:    rdata = 32'h00000000;
        2441:    rdata = 32'h00000000;
        2442:    rdata = 32'h00000000;
        2443:    rdata = 32'h00000000;
        2444:    rdata = 32'h00000000;
        2445:    rdata = 32'h00000000;
        2446:    rdata = 32'h00000000;
        2447:    rdata = 32'h00000000;
        2448:    rdata = 32'h00000000;
        2449:    rdata = 32'h00000000;
        2450:    rdata = 32'h00000000;
        2451:    rdata = 32'h00000000;
        2452:    rdata = 32'h00000000;
        2453:    rdata = 32'h00000000;
        2454:    rdata = 32'h00000000;
        2455:    rdata = 32'h00000000;
        2456:    rdata = 32'h00000000;
        2457:    rdata = 32'h00000000;
        2458:    rdata = 32'h00000000;
        2459:    rdata = 32'h00000000;
        2460:    rdata = 32'h00000000;
        2461:    rdata = 32'h00000000;
        2462:    rdata = 32'h00000000;
        2463:    rdata = 32'h00000000;
        2464:    rdata = 32'h00000000;
        2465:    rdata = 32'h00000000;
        2466:    rdata = 32'h00000000;
        2467:    rdata = 32'h00000000;
        2468:    rdata = 32'h00000000;
        2469:    rdata = 32'h00000000;
        2470:    rdata = 32'h00000000;
        2471:    rdata = 32'h00000000;
        2472:    rdata = 32'h00000000;
        2473:    rdata = 32'h00000000;
        2474:    rdata = 32'h00000000;
        2475:    rdata = 32'h00000000;
        2476:    rdata = 32'h00000000;
        2477:    rdata = 32'h00000000;
        2478:    rdata = 32'h00000000;
        2479:    rdata = 32'h00000000;
        2480:    rdata = 32'h00000000;
        2481:    rdata = 32'h00000000;
        2482:    rdata = 32'h00000000;
        2483:    rdata = 32'h00000000;
        2484:    rdata = 32'h00000000;
        2485:    rdata = 32'h00000000;
        2486:    rdata = 32'h00000000;
        2487:    rdata = 32'h00000000;
        2488:    rdata = 32'h00000000;
        2489:    rdata = 32'h00000000;
        2490:    rdata = 32'h00000000;
        2491:    rdata = 32'h00000000;
        2492:    rdata = 32'h00000000;
        2493:    rdata = 32'h00000000;
        2494:    rdata = 32'h00000000;
        2495:    rdata = 32'h00000000;
        2496:    rdata = 32'h00000000;
        2497:    rdata = 32'h00000000;
        2498:    rdata = 32'h00000000;
        2499:    rdata = 32'h00000000;
        2500:    rdata = 32'h00000000;
        2501:    rdata = 32'h00000000;
        2502:    rdata = 32'h00000000;
        2503:    rdata = 32'h00000000;
        2504:    rdata = 32'h00000000;
        2505:    rdata = 32'h00000000;
        2506:    rdata = 32'h00000000;
        2507:    rdata = 32'h00000000;
        2508:    rdata = 32'h00000000;
        2509:    rdata = 32'h00000000;
        2510:    rdata = 32'h00000000;
        2511:    rdata = 32'h00000000;
        2512:    rdata = 32'h00000000;
        2513:    rdata = 32'h00000000;
        2514:    rdata = 32'h00000000;
        2515:    rdata = 32'h00000000;
        2516:    rdata = 32'h00000000;
        2517:    rdata = 32'h00000000;
        2518:    rdata = 32'h00000000;
        2519:    rdata = 32'h00000000;
        2520:    rdata = 32'h00000000;
        2521:    rdata = 32'h00000000;
        2522:    rdata = 32'h00000000;
        2523:    rdata = 32'h00000000;
        2524:    rdata = 32'h00000000;
        2525:    rdata = 32'h00000000;
        2526:    rdata = 32'h00000000;
        2527:    rdata = 32'h00000000;
        2528:    rdata = 32'h00000000;
        2529:    rdata = 32'h00000000;
        2530:    rdata = 32'h00000000;
        2531:    rdata = 32'h00000000;
        2532:    rdata = 32'h00000000;
        2533:    rdata = 32'h00000000;
        2534:    rdata = 32'h00000000;
        2535:    rdata = 32'h00000000;
        2536:    rdata = 32'h00000000;
        2537:    rdata = 32'h00000000;
        2538:    rdata = 32'h00000000;
        2539:    rdata = 32'h00000000;
        2540:    rdata = 32'h00000000;
        2541:    rdata = 32'h00000000;
        2542:    rdata = 32'h00000000;
        2543:    rdata = 32'h00000000;
        2544:    rdata = 32'h00000000;
        2545:    rdata = 32'h00000000;
        2546:    rdata = 32'h00000000;
        2547:    rdata = 32'h00000000;
        2548:    rdata = 32'h00000000;
        2549:    rdata = 32'h00000000;
        2550:    rdata = 32'h00000000;
        2551:    rdata = 32'h00000000;
        2552:    rdata = 32'h00000000;
        2553:    rdata = 32'h00000000;
        2554:    rdata = 32'h00000000;
        2555:    rdata = 32'h00000000;
        2556:    rdata = 32'h00000000;
        2557:    rdata = 32'h00000000;
        2558:    rdata = 32'h00000000;
        2559:    rdata = 32'h00000000;
        2560:    rdata = 32'h00000000;
        2561:    rdata = 32'h00000000;
        2562:    rdata = 32'h00000000;
        2563:    rdata = 32'h00000000;
        2564:    rdata = 32'h00000000;
        2565:    rdata = 32'h00000000;
        2566:    rdata = 32'h00000000;
        2567:    rdata = 32'h00000000;
        2568:    rdata = 32'h00000000;
        2569:    rdata = 32'h00000000;
        2570:    rdata = 32'h00000000;
        2571:    rdata = 32'h00000000;
        2572:    rdata = 32'h00000000;
        2573:    rdata = 32'h00000000;
        2574:    rdata = 32'h00000000;
        2575:    rdata = 32'h00000000;
        2576:    rdata = 32'h00000000;
        2577:    rdata = 32'h00000000;
        2578:    rdata = 32'h00000000;
        2579:    rdata = 32'h00000000;
        2580:    rdata = 32'h00000000;
        2581:    rdata = 32'h00000000;
        2582:    rdata = 32'h00000000;
        2583:    rdata = 32'h00000000;
        2584:    rdata = 32'h00000000;
        2585:    rdata = 32'h00000000;
        2586:    rdata = 32'h00000000;
        2587:    rdata = 32'h00000000;
        2588:    rdata = 32'h00000000;
        2589:    rdata = 32'h00000000;
        2590:    rdata = 32'h00000000;
        2591:    rdata = 32'h00000000;
        2592:    rdata = 32'h00000000;
        2593:    rdata = 32'h00000000;
        2594:    rdata = 32'h00000000;
        2595:    rdata = 32'h00000000;
        2596:    rdata = 32'h00000000;
        2597:    rdata = 32'h00000000;
        2598:    rdata = 32'h00000000;
        2599:    rdata = 32'h00000000;
        2600:    rdata = 32'h00000000;
        2601:    rdata = 32'h00000000;
        2602:    rdata = 32'h00000000;
        2603:    rdata = 32'h00000000;
        2604:    rdata = 32'h00000000;
        2605:    rdata = 32'h00000000;
        2606:    rdata = 32'h00000000;
        2607:    rdata = 32'h00000000;
        2608:    rdata = 32'h00000000;
        2609:    rdata = 32'h00000000;
        2610:    rdata = 32'h00000000;
        2611:    rdata = 32'h00000000;
        2612:    rdata = 32'h00000000;
        2613:    rdata = 32'h00000000;
        2614:    rdata = 32'h00000000;
        2615:    rdata = 32'h00000000;
        2616:    rdata = 32'h00000000;
        2617:    rdata = 32'h00000000;
        2618:    rdata = 32'h00000000;
        2619:    rdata = 32'h00000000;
        2620:    rdata = 32'h00000000;
        2621:    rdata = 32'h00000000;
        2622:    rdata = 32'h00000000;
        2623:    rdata = 32'h00000000;
        2624:    rdata = 32'h00000000;
        2625:    rdata = 32'h00000000;
        2626:    rdata = 32'h00000000;
        2627:    rdata = 32'h00000000;
        2628:    rdata = 32'h00000000;
        2629:    rdata = 32'h00000000;
        2630:    rdata = 32'h00000000;
        2631:    rdata = 32'h00000000;
        2632:    rdata = 32'h00000000;
        2633:    rdata = 32'h00000000;
        2634:    rdata = 32'h00000000;
        2635:    rdata = 32'h00000000;
        2636:    rdata = 32'h00000000;
        2637:    rdata = 32'h00000000;
        2638:    rdata = 32'h00000000;
        2639:    rdata = 32'h00000000;
        2640:    rdata = 32'h00000000;
        2641:    rdata = 32'h00000000;
        2642:    rdata = 32'h00000000;
        2643:    rdata = 32'h00000000;
        2644:    rdata = 32'h00000000;
        2645:    rdata = 32'h00000000;
        2646:    rdata = 32'h00000000;
        2647:    rdata = 32'h00000000;
        2648:    rdata = 32'h00000000;
        2649:    rdata = 32'h00000000;
        2650:    rdata = 32'h00000000;
        2651:    rdata = 32'h00000000;
        2652:    rdata = 32'h00000000;
        2653:    rdata = 32'h00000000;
        2654:    rdata = 32'h00000000;
        2655:    rdata = 32'h00000000;
        2656:    rdata = 32'h00000000;
        2657:    rdata = 32'h00000000;
        2658:    rdata = 32'h00000000;
        2659:    rdata = 32'h00000000;
        2660:    rdata = 32'h00000000;
        2661:    rdata = 32'h00000000;
        2662:    rdata = 32'h00000000;
        2663:    rdata = 32'h00000000;
        2664:    rdata = 32'h00000000;
        2665:    rdata = 32'h00000000;
        2666:    rdata = 32'h00000000;
        2667:    rdata = 32'h00000000;
        2668:    rdata = 32'h00000000;
        2669:    rdata = 32'h00000000;
        2670:    rdata = 32'h00000000;
        2671:    rdata = 32'h00000000;
        2672:    rdata = 32'h00000000;
        2673:    rdata = 32'h00000000;
        2674:    rdata = 32'h00000000;
        2675:    rdata = 32'h00000000;
        2676:    rdata = 32'h00000000;
        2677:    rdata = 32'h00000000;
        2678:    rdata = 32'h00000000;
        2679:    rdata = 32'h00000000;
        2680:    rdata = 32'h00000000;
        2681:    rdata = 32'h00000000;
        2682:    rdata = 32'h00000000;
        2683:    rdata = 32'h00000000;
        2684:    rdata = 32'h00000000;
        2685:    rdata = 32'h00000000;
        2686:    rdata = 32'h00000000;
        2687:    rdata = 32'h00000000;
        2688:    rdata = 32'h00000000;
        2689:    rdata = 32'h00000000;
        2690:    rdata = 32'h00000000;
        2691:    rdata = 32'h00000000;
        2692:    rdata = 32'h00000000;
        2693:    rdata = 32'h00000000;
        2694:    rdata = 32'h00000000;
        2695:    rdata = 32'h00000000;
        2696:    rdata = 32'h00000000;
        2697:    rdata = 32'h00000000;
        2698:    rdata = 32'h00000000;
        2699:    rdata = 32'h00000000;
        2700:    rdata = 32'h00000000;
        2701:    rdata = 32'h00000000;
        2702:    rdata = 32'h00000000;
        2703:    rdata = 32'h00000000;
        2704:    rdata = 32'h00000000;
        2705:    rdata = 32'h00000000;
        2706:    rdata = 32'h00000000;
        2707:    rdata = 32'h00000000;
        2708:    rdata = 32'h00000000;
        2709:    rdata = 32'h00000000;
        2710:    rdata = 32'h00000000;
        2711:    rdata = 32'h00000000;
        2712:    rdata = 32'h00000000;
        2713:    rdata = 32'h00000000;
        2714:    rdata = 32'h00000000;
        2715:    rdata = 32'h00000000;
        2716:    rdata = 32'h00000000;
        2717:    rdata = 32'h00000000;
        2718:    rdata = 32'h00000000;
        2719:    rdata = 32'h00000000;
        2720:    rdata = 32'h00000000;
        2721:    rdata = 32'h00000000;
        2722:    rdata = 32'h00000000;
        2723:    rdata = 32'h00000000;
        2724:    rdata = 32'h00000000;
        2725:    rdata = 32'h00000000;
        2726:    rdata = 32'h00000000;
        2727:    rdata = 32'h00000000;
        2728:    rdata = 32'h00000000;
        2729:    rdata = 32'h00000000;
        2730:    rdata = 32'h00000000;
        2731:    rdata = 32'h00000000;
        2732:    rdata = 32'h00000000;
        2733:    rdata = 32'h00000000;
        2734:    rdata = 32'h00000000;
        2735:    rdata = 32'h00000000;
        2736:    rdata = 32'h00000000;
        2737:    rdata = 32'h00000000;
        2738:    rdata = 32'h00000000;
        2739:    rdata = 32'h00000000;
        2740:    rdata = 32'h00000000;
        2741:    rdata = 32'h00000000;
        2742:    rdata = 32'h00000000;
        2743:    rdata = 32'h00000000;
        2744:    rdata = 32'h00000000;
        2745:    rdata = 32'h00000000;
        2746:    rdata = 32'h00000000;
        2747:    rdata = 32'h00000000;
        2748:    rdata = 32'h00000000;
        2749:    rdata = 32'h00000000;
        2750:    rdata = 32'h00000000;
        2751:    rdata = 32'h00000000;
        2752:    rdata = 32'h00000000;
        2753:    rdata = 32'h00000000;
        2754:    rdata = 32'h00000000;
        2755:    rdata = 32'h00000000;
        2756:    rdata = 32'h00000000;
        2757:    rdata = 32'h00000000;
        2758:    rdata = 32'h00000000;
        2759:    rdata = 32'h00000000;
        2760:    rdata = 32'h00000000;
        2761:    rdata = 32'h00000000;
        2762:    rdata = 32'h00000000;
        2763:    rdata = 32'h00000000;
        2764:    rdata = 32'h00000000;
        2765:    rdata = 32'h00000000;
        2766:    rdata = 32'h00000000;
        2767:    rdata = 32'h00000000;
        2768:    rdata = 32'h00000000;
        2769:    rdata = 32'h00000000;
        2770:    rdata = 32'h00000000;
        2771:    rdata = 32'h00000000;
        2772:    rdata = 32'h00000000;
        2773:    rdata = 32'h00000000;
        2774:    rdata = 32'h00000000;
        2775:    rdata = 32'h00000000;
        2776:    rdata = 32'h00000000;
        2777:    rdata = 32'h00000000;
        2778:    rdata = 32'h00000000;
        2779:    rdata = 32'h00000000;
        2780:    rdata = 32'h00000000;
        2781:    rdata = 32'h00000000;
        2782:    rdata = 32'h00000000;
        2783:    rdata = 32'h00000000;
        2784:    rdata = 32'h00000000;
        2785:    rdata = 32'h00000000;
        2786:    rdata = 32'h00000000;
        2787:    rdata = 32'h00000000;
        2788:    rdata = 32'h00000000;
        2789:    rdata = 32'h00000000;
        2790:    rdata = 32'h00000000;
        2791:    rdata = 32'h00000000;
        2792:    rdata = 32'h00000000;
        2793:    rdata = 32'h00000000;
        2794:    rdata = 32'h00000000;
        2795:    rdata = 32'h00000000;
        2796:    rdata = 32'h00000000;
        2797:    rdata = 32'h00000000;
        2798:    rdata = 32'h00000000;
        2799:    rdata = 32'h00000000;
        2800:    rdata = 32'h00000000;
        2801:    rdata = 32'h00000000;
        2802:    rdata = 32'h00000000;
        2803:    rdata = 32'h00000000;
        2804:    rdata = 32'h00000000;
        2805:    rdata = 32'h00000000;
        2806:    rdata = 32'h00000000;
        2807:    rdata = 32'h00000000;
        2808:    rdata = 32'h00000000;
        2809:    rdata = 32'h00000000;
        2810:    rdata = 32'h00000000;
        2811:    rdata = 32'h00000000;
        2812:    rdata = 32'h00000000;
        2813:    rdata = 32'h00000000;
        2814:    rdata = 32'h00000000;
        2815:    rdata = 32'h00000000;
        2816:    rdata = 32'h00000000;
        2817:    rdata = 32'h00000000;
        2818:    rdata = 32'h00000000;
        2819:    rdata = 32'h00000000;
        2820:    rdata = 32'h00000000;
        2821:    rdata = 32'h00000000;
        2822:    rdata = 32'h00000000;
        2823:    rdata = 32'h00000000;
        2824:    rdata = 32'h00000000;
        2825:    rdata = 32'h00000000;
        2826:    rdata = 32'h00000000;
        2827:    rdata = 32'h00000000;
        2828:    rdata = 32'h00000000;
        2829:    rdata = 32'h00000000;
        2830:    rdata = 32'h00000000;
        2831:    rdata = 32'h00000000;
        2832:    rdata = 32'h00000000;
        2833:    rdata = 32'h00000000;
        2834:    rdata = 32'h00000000;
        2835:    rdata = 32'h00000000;
        2836:    rdata = 32'h00000000;
        2837:    rdata = 32'h00000000;
        2838:    rdata = 32'h00000000;
        2839:    rdata = 32'h00000000;
        2840:    rdata = 32'h00000000;
        2841:    rdata = 32'h00000000;
        2842:    rdata = 32'h00000000;
        2843:    rdata = 32'h00000000;
        2844:    rdata = 32'h00000000;
        2845:    rdata = 32'h00000000;
        2846:    rdata = 32'h00000000;
        2847:    rdata = 32'h00000000;
        2848:    rdata = 32'h00000000;
        2849:    rdata = 32'h00000000;
        2850:    rdata = 32'h00000000;
        2851:    rdata = 32'h00000000;
        2852:    rdata = 32'h00000000;
        2853:    rdata = 32'h00000000;
        2854:    rdata = 32'h00000000;
        2855:    rdata = 32'h00000000;
        2856:    rdata = 32'h00000000;
        2857:    rdata = 32'h00000000;
        2858:    rdata = 32'h00000000;
        2859:    rdata = 32'h00000000;
        2860:    rdata = 32'h00000000;
        2861:    rdata = 32'h00000000;
        2862:    rdata = 32'h00000000;
        2863:    rdata = 32'h00000000;
        2864:    rdata = 32'h00000000;
        2865:    rdata = 32'h00000000;
        2866:    rdata = 32'h00000000;
        2867:    rdata = 32'h00000000;
        2868:    rdata = 32'h00000000;
        2869:    rdata = 32'h00000000;
        2870:    rdata = 32'h00000000;
        2871:    rdata = 32'h00000000;
        2872:    rdata = 32'h00000000;
        2873:    rdata = 32'h00000000;
        2874:    rdata = 32'h00000000;
        2875:    rdata = 32'h00000000;
        2876:    rdata = 32'h00000000;
        2877:    rdata = 32'h00000000;
        2878:    rdata = 32'h00000000;
        2879:    rdata = 32'h00000000;
        2880:    rdata = 32'h00000000;
        2881:    rdata = 32'h00000000;
        2882:    rdata = 32'h00000000;
        2883:    rdata = 32'h00000000;
        2884:    rdata = 32'h00000000;
        2885:    rdata = 32'h00000000;
        2886:    rdata = 32'h00000000;
        2887:    rdata = 32'h00000000;
        2888:    rdata = 32'h00000000;
        2889:    rdata = 32'h00000000;
        2890:    rdata = 32'h00000000;
        2891:    rdata = 32'h00000000;
        2892:    rdata = 32'h00000000;
        2893:    rdata = 32'h00000000;
        2894:    rdata = 32'h00000000;
        2895:    rdata = 32'h00000000;
        2896:    rdata = 32'h00000000;
        2897:    rdata = 32'h00000000;
        2898:    rdata = 32'h00000000;
        2899:    rdata = 32'h00000000;
        2900:    rdata = 32'h00000000;
        2901:    rdata = 32'h00000000;
        2902:    rdata = 32'h00000000;
        2903:    rdata = 32'h00000000;
        2904:    rdata = 32'h00000000;
        2905:    rdata = 32'h00000000;
        2906:    rdata = 32'h00000000;
        2907:    rdata = 32'h00000000;
        2908:    rdata = 32'h00000000;
        2909:    rdata = 32'h00000000;
        2910:    rdata = 32'h00000000;
        2911:    rdata = 32'h00000000;
        2912:    rdata = 32'h00000000;
        2913:    rdata = 32'h00000000;
        2914:    rdata = 32'h00000000;
        2915:    rdata = 32'h00000000;
        2916:    rdata = 32'h00000000;
        2917:    rdata = 32'h00000000;
        2918:    rdata = 32'h00000000;
        2919:    rdata = 32'h00000000;
        2920:    rdata = 32'h00000000;
        2921:    rdata = 32'h00000000;
        2922:    rdata = 32'h00000000;
        2923:    rdata = 32'h00000000;
        2924:    rdata = 32'h00000000;
        2925:    rdata = 32'h00000000;
        2926:    rdata = 32'h00000000;
        2927:    rdata = 32'h00000000;
        2928:    rdata = 32'h00000000;
        2929:    rdata = 32'h00000000;
        2930:    rdata = 32'h00000000;
        2931:    rdata = 32'h00000000;
        2932:    rdata = 32'h00000000;
        2933:    rdata = 32'h00000000;
        2934:    rdata = 32'h00000000;
        2935:    rdata = 32'h00000000;
        2936:    rdata = 32'h00000000;
        2937:    rdata = 32'h00000000;
        2938:    rdata = 32'h00000000;
        2939:    rdata = 32'h00000000;
        2940:    rdata = 32'h00000000;
        2941:    rdata = 32'h00000000;
        2942:    rdata = 32'h00000000;
        2943:    rdata = 32'h00000000;
        2944:    rdata = 32'h00000000;
        2945:    rdata = 32'h00000000;
        2946:    rdata = 32'h00000000;
        2947:    rdata = 32'h00000000;
        2948:    rdata = 32'h00000000;
        2949:    rdata = 32'h00000000;
        2950:    rdata = 32'h00000000;
        2951:    rdata = 32'h00000000;
        2952:    rdata = 32'h00000000;
        2953:    rdata = 32'h00000000;
        2954:    rdata = 32'h00000000;
        2955:    rdata = 32'h00000000;
        2956:    rdata = 32'h00000000;
        2957:    rdata = 32'h00000000;
        2958:    rdata = 32'h00000000;
        2959:    rdata = 32'h00000000;
        2960:    rdata = 32'h00000000;
        2961:    rdata = 32'h00000000;
        2962:    rdata = 32'h00000000;
        2963:    rdata = 32'h00000000;
        2964:    rdata = 32'h00000000;
        2965:    rdata = 32'h00000000;
        2966:    rdata = 32'h00000000;
        2967:    rdata = 32'h00000000;
        2968:    rdata = 32'h00000000;
        2969:    rdata = 32'h00000000;
        2970:    rdata = 32'h00000000;
        2971:    rdata = 32'h00000000;
        2972:    rdata = 32'h00000000;
        2973:    rdata = 32'h00000000;
        2974:    rdata = 32'h00000000;
        2975:    rdata = 32'h00000000;
        2976:    rdata = 32'h00000000;
        2977:    rdata = 32'h00000000;
        2978:    rdata = 32'h00000000;
        2979:    rdata = 32'h00000000;
        2980:    rdata = 32'h00000000;
        2981:    rdata = 32'h00000000;
        2982:    rdata = 32'h00000000;
        2983:    rdata = 32'h00000000;
        2984:    rdata = 32'h00000000;
        2985:    rdata = 32'h00000000;
        2986:    rdata = 32'h00000000;
        2987:    rdata = 32'h00000000;
        2988:    rdata = 32'h00000000;
        2989:    rdata = 32'h00000000;
        2990:    rdata = 32'h00000000;
        2991:    rdata = 32'h00000000;
        2992:    rdata = 32'h00000000;
        2993:    rdata = 32'h00000000;
        2994:    rdata = 32'h00000000;
        2995:    rdata = 32'h00000000;
        2996:    rdata = 32'h00000000;
        2997:    rdata = 32'h00000000;
        2998:    rdata = 32'h00000000;
        2999:    rdata = 32'h00000000;
        3000:    rdata = 32'h00000000;
        3001:    rdata = 32'h00000000;
        3002:    rdata = 32'h00000000;
        3003:    rdata = 32'h00000000;
        3004:    rdata = 32'h00000000;
        3005:    rdata = 32'h00000000;
        3006:    rdata = 32'h00000000;
        3007:    rdata = 32'h00000000;
        3008:    rdata = 32'h00000000;
        3009:    rdata = 32'h00000000;
        3010:    rdata = 32'h00000000;
        3011:    rdata = 32'h00000000;
        3012:    rdata = 32'h00000000;
        3013:    rdata = 32'h00000000;
        3014:    rdata = 32'h00000000;
        3015:    rdata = 32'h00000000;
        3016:    rdata = 32'h00000000;
        3017:    rdata = 32'h00000000;
        3018:    rdata = 32'h00000000;
        3019:    rdata = 32'h00000000;
        3020:    rdata = 32'h00000000;
        3021:    rdata = 32'h00000000;
        3022:    rdata = 32'h00000000;
        3023:    rdata = 32'h00000000;
        3024:    rdata = 32'h00000000;
        3025:    rdata = 32'h00000000;
        3026:    rdata = 32'h00000000;
        3027:    rdata = 32'h00000000;
        3028:    rdata = 32'h00000000;
        3029:    rdata = 32'h00000000;
        3030:    rdata = 32'h00000000;
        3031:    rdata = 32'h00000000;
        3032:    rdata = 32'h00000000;
        3033:    rdata = 32'h00000000;
        3034:    rdata = 32'h00000000;
        3035:    rdata = 32'h00000000;
        3036:    rdata = 32'h00000000;
        3037:    rdata = 32'h00000000;
        3038:    rdata = 32'h00000000;
        3039:    rdata = 32'h00000000;
        3040:    rdata = 32'h00000000;
        3041:    rdata = 32'h00000000;
        3042:    rdata = 32'h00000000;
        3043:    rdata = 32'h00000000;
        3044:    rdata = 32'h00000000;
        3045:    rdata = 32'h00000000;
        3046:    rdata = 32'h00000000;
        3047:    rdata = 32'h00000000;
        3048:    rdata = 32'h00000000;
        3049:    rdata = 32'h00000000;
        3050:    rdata = 32'h00000000;
        3051:    rdata = 32'h00000000;
        3052:    rdata = 32'h00000000;
        3053:    rdata = 32'h00000000;
        3054:    rdata = 32'h00000000;
        3055:    rdata = 32'h00000000;
        3056:    rdata = 32'h00000000;
        3057:    rdata = 32'h00000000;
        3058:    rdata = 32'h00000000;
        3059:    rdata = 32'h00000000;
        3060:    rdata = 32'h00000000;
        3061:    rdata = 32'h00000000;
        3062:    rdata = 32'h00000000;
        3063:    rdata = 32'h00000000;
        3064:    rdata = 32'h00000000;
        3065:    rdata = 32'h00000000;
        3066:    rdata = 32'h00000000;
        3067:    rdata = 32'h00000000;
        3068:    rdata = 32'h00000000;
        3069:    rdata = 32'h00000000;
        3070:    rdata = 32'h00000000;
        3071:    rdata = 32'h00000000;
        3072:    rdata = 32'h00000000;
        3073:    rdata = 32'h00000000;
        3074:    rdata = 32'h00000000;
        3075:    rdata = 32'h00000000;
        3076:    rdata = 32'h00000000;
        3077:    rdata = 32'h00000000;
        3078:    rdata = 32'h00000000;
        3079:    rdata = 32'h00000000;
        3080:    rdata = 32'h00000000;
        3081:    rdata = 32'h00000000;
        3082:    rdata = 32'h00000000;
        3083:    rdata = 32'h00000000;
        3084:    rdata = 32'h00000000;
        3085:    rdata = 32'h00000000;
        3086:    rdata = 32'h00000000;
        3087:    rdata = 32'h00000000;
        3088:    rdata = 32'h00000000;
        3089:    rdata = 32'h00000000;
        3090:    rdata = 32'h00000000;
        3091:    rdata = 32'h00000000;
        3092:    rdata = 32'h00000000;
        3093:    rdata = 32'h00000000;
        3094:    rdata = 32'h00000000;
        3095:    rdata = 32'h00000000;
        3096:    rdata = 32'h00000000;
        3097:    rdata = 32'h00000000;
        3098:    rdata = 32'h00000000;
        3099:    rdata = 32'h00000000;
        3100:    rdata = 32'h00000000;
        3101:    rdata = 32'h00000000;
        3102:    rdata = 32'h00000000;
        3103:    rdata = 32'h00000000;
        3104:    rdata = 32'h00000000;
        3105:    rdata = 32'h00000000;
        3106:    rdata = 32'h00000000;
        3107:    rdata = 32'h00000000;
        3108:    rdata = 32'h00000000;
        3109:    rdata = 32'h00000000;
        3110:    rdata = 32'h00000000;
        3111:    rdata = 32'h00000000;
        3112:    rdata = 32'h00000000;
        3113:    rdata = 32'h00000000;
        3114:    rdata = 32'h00000000;
        3115:    rdata = 32'h00000000;
        3116:    rdata = 32'h00000000;
        3117:    rdata = 32'h00000000;
        3118:    rdata = 32'h00000000;
        3119:    rdata = 32'h00000000;
        3120:    rdata = 32'h00000000;
        3121:    rdata = 32'h00000000;
        3122:    rdata = 32'h00000000;
        3123:    rdata = 32'h00000000;
        3124:    rdata = 32'h00000000;
        3125:    rdata = 32'h00000000;
        3126:    rdata = 32'h00000000;
        3127:    rdata = 32'h00000000;
        3128:    rdata = 32'h00000000;
        3129:    rdata = 32'h00000000;
        3130:    rdata = 32'h00000000;
        3131:    rdata = 32'h00000000;
        3132:    rdata = 32'h00000000;
        3133:    rdata = 32'h00000000;
        3134:    rdata = 32'h00000000;
        3135:    rdata = 32'h00000000;
        3136:    rdata = 32'h00000000;
        3137:    rdata = 32'h00000000;
        3138:    rdata = 32'h00000000;
        3139:    rdata = 32'h00000000;
        3140:    rdata = 32'h00000000;
        3141:    rdata = 32'h00000000;
        3142:    rdata = 32'h00000000;
        3143:    rdata = 32'h00000000;
        3144:    rdata = 32'h00000000;
        3145:    rdata = 32'h00000000;
        3146:    rdata = 32'h00000000;
        3147:    rdata = 32'h00000000;
        3148:    rdata = 32'h00000000;
        3149:    rdata = 32'h00000000;
        3150:    rdata = 32'h00000000;
        3151:    rdata = 32'h00000000;
        3152:    rdata = 32'h00000000;
        3153:    rdata = 32'h00000000;
        3154:    rdata = 32'h00000000;
        3155:    rdata = 32'h00000000;
        3156:    rdata = 32'h00000000;
        3157:    rdata = 32'h00000000;
        3158:    rdata = 32'h00000000;
        3159:    rdata = 32'h00000000;
        3160:    rdata = 32'h00000000;
        3161:    rdata = 32'h00000000;
        3162:    rdata = 32'h00000000;
        3163:    rdata = 32'h00000000;
        3164:    rdata = 32'h00000000;
        3165:    rdata = 32'h00000000;
        3166:    rdata = 32'h00000000;
        3167:    rdata = 32'h00000000;
        3168:    rdata = 32'h00000000;
        3169:    rdata = 32'h00000000;
        3170:    rdata = 32'h00000000;
        3171:    rdata = 32'h00000000;
        3172:    rdata = 32'h00000000;
        3173:    rdata = 32'h00000000;
        3174:    rdata = 32'h00000000;
        3175:    rdata = 32'h00000000;
        3176:    rdata = 32'h00000000;
        3177:    rdata = 32'h00000000;
        3178:    rdata = 32'h00000000;
        3179:    rdata = 32'h00000000;
        3180:    rdata = 32'h00000000;
        3181:    rdata = 32'h00000000;
        3182:    rdata = 32'h00000000;
        3183:    rdata = 32'h00000000;
        3184:    rdata = 32'h00000000;
        3185:    rdata = 32'h00000000;
        3186:    rdata = 32'h00000000;
        3187:    rdata = 32'h00000000;
        3188:    rdata = 32'h00000000;
        3189:    rdata = 32'h00000000;
        3190:    rdata = 32'h00000000;
        3191:    rdata = 32'h00000000;
        3192:    rdata = 32'h00000000;
        3193:    rdata = 32'h00000000;
        3194:    rdata = 32'h00000000;
        3195:    rdata = 32'h00000000;
        3196:    rdata = 32'h00000000;
        3197:    rdata = 32'h00000000;
        3198:    rdata = 32'h00000000;
        3199:    rdata = 32'h00000000;
        3200:    rdata = 32'h00000000;
        3201:    rdata = 32'h00000000;
        3202:    rdata = 32'h00000000;
        3203:    rdata = 32'h00000000;
        3204:    rdata = 32'h00000000;
        3205:    rdata = 32'h00000000;
        3206:    rdata = 32'h00000000;
        3207:    rdata = 32'h00000000;
        3208:    rdata = 32'h00000000;
        3209:    rdata = 32'h00000000;
        3210:    rdata = 32'h00000000;
        3211:    rdata = 32'h00000000;
        3212:    rdata = 32'h00000000;
        3213:    rdata = 32'h00000000;
        3214:    rdata = 32'h00000000;
        3215:    rdata = 32'h00000000;
        3216:    rdata = 32'h00000000;
        3217:    rdata = 32'h00000000;
        3218:    rdata = 32'h00000000;
        3219:    rdata = 32'h00000000;
        3220:    rdata = 32'h00000000;
        3221:    rdata = 32'h00000000;
        3222:    rdata = 32'h00000000;
        3223:    rdata = 32'h00000000;
        3224:    rdata = 32'h00000000;
        3225:    rdata = 32'h00000000;
        3226:    rdata = 32'h00000000;
        3227:    rdata = 32'h00000000;
        3228:    rdata = 32'h00000000;
        3229:    rdata = 32'h00000000;
        3230:    rdata = 32'h00000000;
        3231:    rdata = 32'h00000000;
        3232:    rdata = 32'h00000000;
        3233:    rdata = 32'h00000000;
        3234:    rdata = 32'h00000000;
        3235:    rdata = 32'h00000000;
        3236:    rdata = 32'h00000000;
        3237:    rdata = 32'h00000000;
        3238:    rdata = 32'h00000000;
        3239:    rdata = 32'h00000000;
        3240:    rdata = 32'h00000000;
        3241:    rdata = 32'h00000000;
        3242:    rdata = 32'h00000000;
        3243:    rdata = 32'h00000000;
        3244:    rdata = 32'h00000000;
        3245:    rdata = 32'h00000000;
        3246:    rdata = 32'h00000000;
        3247:    rdata = 32'h00000000;
        3248:    rdata = 32'h00000000;
        3249:    rdata = 32'h00000000;
        3250:    rdata = 32'h00000000;
        3251:    rdata = 32'h00000000;
        3252:    rdata = 32'h00000000;
        3253:    rdata = 32'h00000000;
        3254:    rdata = 32'h00000000;
        3255:    rdata = 32'h00000000;
        3256:    rdata = 32'h00000000;
        3257:    rdata = 32'h00000000;
        3258:    rdata = 32'h00000000;
        3259:    rdata = 32'h00000000;
        3260:    rdata = 32'h00000000;
        3261:    rdata = 32'h00000000;
        3262:    rdata = 32'h00000000;
        3263:    rdata = 32'h00000000;
        3264:    rdata = 32'h00000000;
        3265:    rdata = 32'h00000000;
        3266:    rdata = 32'h00000000;
        3267:    rdata = 32'h00000000;
        3268:    rdata = 32'h00000000;
        3269:    rdata = 32'h00000000;
        3270:    rdata = 32'h00000000;
        3271:    rdata = 32'h00000000;
        3272:    rdata = 32'h00000000;
        3273:    rdata = 32'h00000000;
        3274:    rdata = 32'h00000000;
        3275:    rdata = 32'h00000000;
        3276:    rdata = 32'h00000000;
        3277:    rdata = 32'h00000000;
        3278:    rdata = 32'h00000000;
        3279:    rdata = 32'h00000000;
        3280:    rdata = 32'h00000000;
        3281:    rdata = 32'h00000000;
        3282:    rdata = 32'h00000000;
        3283:    rdata = 32'h00000000;
        3284:    rdata = 32'h00000000;
        3285:    rdata = 32'h00000000;
        3286:    rdata = 32'h00000000;
        3287:    rdata = 32'h00000000;
        3288:    rdata = 32'h00000000;
        3289:    rdata = 32'h00000000;
        3290:    rdata = 32'h00000000;
        3291:    rdata = 32'h00000000;
        3292:    rdata = 32'h00000000;
        3293:    rdata = 32'h00000000;
        3294:    rdata = 32'h00000000;
        3295:    rdata = 32'h00000000;
        3296:    rdata = 32'h00000000;
        3297:    rdata = 32'h00000000;
        3298:    rdata = 32'h00000000;
        3299:    rdata = 32'h00000000;
        3300:    rdata = 32'h00000000;
        3301:    rdata = 32'h00000000;
        3302:    rdata = 32'h00000000;
        3303:    rdata = 32'h00000000;
        3304:    rdata = 32'h00000000;
        3305:    rdata = 32'h00000000;
        3306:    rdata = 32'h00000000;
        3307:    rdata = 32'h00000000;
        3308:    rdata = 32'h00000000;
        3309:    rdata = 32'h00000000;
        3310:    rdata = 32'h00000000;
        3311:    rdata = 32'h00000000;
        3312:    rdata = 32'h00000000;
        3313:    rdata = 32'h00000000;
        3314:    rdata = 32'h00000000;
        3315:    rdata = 32'h00000000;
        3316:    rdata = 32'h00000000;
        3317:    rdata = 32'h00000000;
        3318:    rdata = 32'h00000000;
        3319:    rdata = 32'h00000000;
        3320:    rdata = 32'h00000000;
        3321:    rdata = 32'h00000000;
        3322:    rdata = 32'h00000000;
        3323:    rdata = 32'h00000000;
        3324:    rdata = 32'h00000000;
        3325:    rdata = 32'h00000000;
        3326:    rdata = 32'h00000000;
        3327:    rdata = 32'h00000000;
        3328:    rdata = 32'h00000000;
        3329:    rdata = 32'h00000000;
        3330:    rdata = 32'h00000000;
        3331:    rdata = 32'h00000000;
        3332:    rdata = 32'h00000000;
        3333:    rdata = 32'h00000000;
        3334:    rdata = 32'h00000000;
        3335:    rdata = 32'h00000000;
        3336:    rdata = 32'h00000000;
        3337:    rdata = 32'h00000000;
        3338:    rdata = 32'h00000000;
        3339:    rdata = 32'h00000000;
        3340:    rdata = 32'h00000000;
        3341:    rdata = 32'h00000000;
        3342:    rdata = 32'h00000000;
        3343:    rdata = 32'h00000000;
        3344:    rdata = 32'h00000000;
        3345:    rdata = 32'h00000000;
        3346:    rdata = 32'h00000000;
        3347:    rdata = 32'h00000000;
        3348:    rdata = 32'h00000000;
        3349:    rdata = 32'h00000000;
        3350:    rdata = 32'h00000000;
        3351:    rdata = 32'h00000000;
        3352:    rdata = 32'h00000000;
        3353:    rdata = 32'h00000000;
        3354:    rdata = 32'h00000000;
        3355:    rdata = 32'h00000000;
        3356:    rdata = 32'h00000000;
        3357:    rdata = 32'h00000000;
        3358:    rdata = 32'h00000000;
        3359:    rdata = 32'h00000000;
        3360:    rdata = 32'h00000000;
        3361:    rdata = 32'h00000000;
        3362:    rdata = 32'h00000000;
        3363:    rdata = 32'h00000000;
        3364:    rdata = 32'h00000000;
        3365:    rdata = 32'h00000000;
        3366:    rdata = 32'h00000000;
        3367:    rdata = 32'h00000000;
        3368:    rdata = 32'h00000000;
        3369:    rdata = 32'h00000000;
        3370:    rdata = 32'h00000000;
        3371:    rdata = 32'h00000000;
        3372:    rdata = 32'h00000000;
        3373:    rdata = 32'h00000000;
        3374:    rdata = 32'h00000000;
        3375:    rdata = 32'h00000000;
        3376:    rdata = 32'h00000000;
        3377:    rdata = 32'h00000000;
        3378:    rdata = 32'h00000000;
        3379:    rdata = 32'h00000000;
        3380:    rdata = 32'h00000000;
        3381:    rdata = 32'h00000000;
        3382:    rdata = 32'h00000000;
        3383:    rdata = 32'h00000000;
        3384:    rdata = 32'h00000000;
        3385:    rdata = 32'h00000000;
        3386:    rdata = 32'h00000000;
        3387:    rdata = 32'h00000000;
        3388:    rdata = 32'h00000000;
        3389:    rdata = 32'h00000000;
        3390:    rdata = 32'h00000000;
        3391:    rdata = 32'h00000000;
        3392:    rdata = 32'h00000000;
        3393:    rdata = 32'h00000000;
        3394:    rdata = 32'h00000000;
        3395:    rdata = 32'h00000000;
        3396:    rdata = 32'h00000000;
        3397:    rdata = 32'h00000000;
        3398:    rdata = 32'h00000000;
        3399:    rdata = 32'h00000000;
        3400:    rdata = 32'h00000000;
        3401:    rdata = 32'h00000000;
        3402:    rdata = 32'h00000000;
        3403:    rdata = 32'h00000000;
        3404:    rdata = 32'h00000000;
        3405:    rdata = 32'h00000000;
        3406:    rdata = 32'h00000000;
        3407:    rdata = 32'h00000000;
        3408:    rdata = 32'h00000000;
        3409:    rdata = 32'h00000000;
        3410:    rdata = 32'h00000000;
        3411:    rdata = 32'h00000000;
        3412:    rdata = 32'h00000000;
        3413:    rdata = 32'h00000000;
        3414:    rdata = 32'h00000000;
        3415:    rdata = 32'h00000000;
        3416:    rdata = 32'h00000000;
        3417:    rdata = 32'h00000000;
        3418:    rdata = 32'h00000000;
        3419:    rdata = 32'h00000000;
        3420:    rdata = 32'h00000000;
        3421:    rdata = 32'h00000000;
        3422:    rdata = 32'h00000000;
        3423:    rdata = 32'h00000000;
        3424:    rdata = 32'h00000000;
        3425:    rdata = 32'h00000000;
        3426:    rdata = 32'h00000000;
        3427:    rdata = 32'h00000000;
        3428:    rdata = 32'h00000000;
        3429:    rdata = 32'h00000000;
        3430:    rdata = 32'h00000000;
        3431:    rdata = 32'h00000000;
        3432:    rdata = 32'h00000000;
        3433:    rdata = 32'h00000000;
        3434:    rdata = 32'h00000000;
        3435:    rdata = 32'h00000000;
        3436:    rdata = 32'h00000000;
        3437:    rdata = 32'h00000000;
        3438:    rdata = 32'h00000000;
        3439:    rdata = 32'h00000000;
        3440:    rdata = 32'h00000000;
        3441:    rdata = 32'h00000000;
        3442:    rdata = 32'h00000000;
        3443:    rdata = 32'h00000000;
        3444:    rdata = 32'h00000000;
        3445:    rdata = 32'h00000000;
        3446:    rdata = 32'h00000000;
        3447:    rdata = 32'h00000000;
        3448:    rdata = 32'h00000000;
        3449:    rdata = 32'h00000000;
        3450:    rdata = 32'h00000000;
        3451:    rdata = 32'h00000000;
        3452:    rdata = 32'h00000000;
        3453:    rdata = 32'h00000000;
        3454:    rdata = 32'h00000000;
        3455:    rdata = 32'h00000000;
        3456:    rdata = 32'h00000000;
        3457:    rdata = 32'h00000000;
        3458:    rdata = 32'h00000000;
        3459:    rdata = 32'h00000000;
        3460:    rdata = 32'h00000000;
        3461:    rdata = 32'h00000000;
        3462:    rdata = 32'h00000000;
        3463:    rdata = 32'h00000000;
        3464:    rdata = 32'h00000000;
        3465:    rdata = 32'h00000000;
        3466:    rdata = 32'h00000000;
        3467:    rdata = 32'h00000000;
        3468:    rdata = 32'h00000000;
        3469:    rdata = 32'h00000000;
        3470:    rdata = 32'h00000000;
        3471:    rdata = 32'h00000000;
        3472:    rdata = 32'h00000000;
        3473:    rdata = 32'h00000000;
        3474:    rdata = 32'h00000000;
        3475:    rdata = 32'h00000000;
        3476:    rdata = 32'h00000000;
        3477:    rdata = 32'h00000000;
        3478:    rdata = 32'h00000000;
        3479:    rdata = 32'h00000000;
        3480:    rdata = 32'h00000000;
        3481:    rdata = 32'h00000000;
        3482:    rdata = 32'h00000000;
        3483:    rdata = 32'h00000000;
        3484:    rdata = 32'h00000000;
        3485:    rdata = 32'h00000000;
        3486:    rdata = 32'h00000000;
        3487:    rdata = 32'h00000000;
        3488:    rdata = 32'h00000000;
        3489:    rdata = 32'h00000000;
        3490:    rdata = 32'h00000000;
        3491:    rdata = 32'h00000000;
        3492:    rdata = 32'h00000000;
        3493:    rdata = 32'h00000000;
        3494:    rdata = 32'h00000000;
        3495:    rdata = 32'h00000000;
        3496:    rdata = 32'h00000000;
        3497:    rdata = 32'h00000000;
        3498:    rdata = 32'h00000000;
        3499:    rdata = 32'h00000000;
        3500:    rdata = 32'h00000000;
        3501:    rdata = 32'h00000000;
        3502:    rdata = 32'h00000000;
        3503:    rdata = 32'h00000000;
        3504:    rdata = 32'h00000000;
        3505:    rdata = 32'h00000000;
        3506:    rdata = 32'h00000000;
        3507:    rdata = 32'h00000000;
        3508:    rdata = 32'h00000000;
        3509:    rdata = 32'h00000000;
        3510:    rdata = 32'h00000000;
        3511:    rdata = 32'h00000000;
        3512:    rdata = 32'h00000000;
        3513:    rdata = 32'h00000000;
        3514:    rdata = 32'h00000000;
        3515:    rdata = 32'h00000000;
        3516:    rdata = 32'h00000000;
        3517:    rdata = 32'h00000000;
        3518:    rdata = 32'h00000000;
        3519:    rdata = 32'h00000000;
        3520:    rdata = 32'h00000000;
        3521:    rdata = 32'h00000000;
        3522:    rdata = 32'h00000000;
        3523:    rdata = 32'h00000000;
        3524:    rdata = 32'h00000000;
        3525:    rdata = 32'h00000000;
        3526:    rdata = 32'h00000000;
        3527:    rdata = 32'h00000000;
        3528:    rdata = 32'h00000000;
        3529:    rdata = 32'h00000000;
        3530:    rdata = 32'h00000000;
        3531:    rdata = 32'h00000000;
        3532:    rdata = 32'h00000000;
        3533:    rdata = 32'h00000000;
        3534:    rdata = 32'h00000000;
        3535:    rdata = 32'h00000000;
        3536:    rdata = 32'h00000000;
        3537:    rdata = 32'h00000000;
        3538:    rdata = 32'h00000000;
        3539:    rdata = 32'h00000000;
        3540:    rdata = 32'h00000000;
        3541:    rdata = 32'h00000000;
        3542:    rdata = 32'h00000000;
        3543:    rdata = 32'h00000000;
        3544:    rdata = 32'h00000000;
        3545:    rdata = 32'h00000000;
        3546:    rdata = 32'h00000000;
        3547:    rdata = 32'h00000000;
        3548:    rdata = 32'h00000000;
        3549:    rdata = 32'h00000000;
        3550:    rdata = 32'h00000000;
        3551:    rdata = 32'h00000000;
        3552:    rdata = 32'h00000000;
        3553:    rdata = 32'h00000000;
        3554:    rdata = 32'h00000000;
        3555:    rdata = 32'h00000000;
        3556:    rdata = 32'h00000000;
        3557:    rdata = 32'h00000000;
        3558:    rdata = 32'h00000000;
        3559:    rdata = 32'h00000000;
        3560:    rdata = 32'h00000000;
        3561:    rdata = 32'h00000000;
        3562:    rdata = 32'h00000000;
        3563:    rdata = 32'h00000000;
        3564:    rdata = 32'h00000000;
        3565:    rdata = 32'h00000000;
        3566:    rdata = 32'h00000000;
        3567:    rdata = 32'h00000000;
        3568:    rdata = 32'h00000000;
        3569:    rdata = 32'h00000000;
        3570:    rdata = 32'h00000000;
        3571:    rdata = 32'h00000000;
        3572:    rdata = 32'h00000000;
        3573:    rdata = 32'h00000000;
        3574:    rdata = 32'h00000000;
        3575:    rdata = 32'h00000000;
        3576:    rdata = 32'h00000000;
        3577:    rdata = 32'h00000000;
        3578:    rdata = 32'h00000000;
        3579:    rdata = 32'h00000000;
        3580:    rdata = 32'h00000000;
        3581:    rdata = 32'h00000000;
        3582:    rdata = 32'h00000000;
        3583:    rdata = 32'h00000000;
        3584:    rdata = 32'h00000000;
        3585:    rdata = 32'h00000000;
        3586:    rdata = 32'h00000000;
        3587:    rdata = 32'h00000000;
        3588:    rdata = 32'h00000000;
        3589:    rdata = 32'h00000000;
        3590:    rdata = 32'h00000000;
        3591:    rdata = 32'h00000000;
        3592:    rdata = 32'h00000000;
        3593:    rdata = 32'h00000000;
        3594:    rdata = 32'h00000000;
        3595:    rdata = 32'h00000000;
        3596:    rdata = 32'h00000000;
        3597:    rdata = 32'h00000000;
        3598:    rdata = 32'h00000000;
        3599:    rdata = 32'h00000000;
        3600:    rdata = 32'h00000000;
        3601:    rdata = 32'h00000000;
        3602:    rdata = 32'h00000000;
        3603:    rdata = 32'h00000000;
        3604:    rdata = 32'h00000000;
        3605:    rdata = 32'h00000000;
        3606:    rdata = 32'h00000000;
        3607:    rdata = 32'h00000000;
        3608:    rdata = 32'h00000000;
        3609:    rdata = 32'h00000000;
        3610:    rdata = 32'h00000000;
        3611:    rdata = 32'h00000000;
        3612:    rdata = 32'h00000000;
        3613:    rdata = 32'h00000000;
        3614:    rdata = 32'h00000000;
        3615:    rdata = 32'h00000000;
        3616:    rdata = 32'h00000000;
        3617:    rdata = 32'h00000000;
        3618:    rdata = 32'h00000000;
        3619:    rdata = 32'h00000000;
        3620:    rdata = 32'h00000000;
        3621:    rdata = 32'h00000000;
        3622:    rdata = 32'h00000000;
        3623:    rdata = 32'h00000000;
        3624:    rdata = 32'h00000000;
        3625:    rdata = 32'h00000000;
        3626:    rdata = 32'h00000000;
        3627:    rdata = 32'h00000000;
        3628:    rdata = 32'h00000000;
        3629:    rdata = 32'h00000000;
        3630:    rdata = 32'h00000000;
        3631:    rdata = 32'h00000000;
        3632:    rdata = 32'h00000000;
        3633:    rdata = 32'h00000000;
        3634:    rdata = 32'h00000000;
        3635:    rdata = 32'h00000000;
        3636:    rdata = 32'h00000000;
        3637:    rdata = 32'h00000000;
        3638:    rdata = 32'h00000000;
        3639:    rdata = 32'h00000000;
        3640:    rdata = 32'h00000000;
        3641:    rdata = 32'h00000000;
        3642:    rdata = 32'h00000000;
        3643:    rdata = 32'h00000000;
        3644:    rdata = 32'h00000000;
        3645:    rdata = 32'h00000000;
        3646:    rdata = 32'h00000000;
        3647:    rdata = 32'h00000000;
        3648:    rdata = 32'h00000000;
        3649:    rdata = 32'h00000000;
        3650:    rdata = 32'h00000000;
        3651:    rdata = 32'h00000000;
        3652:    rdata = 32'h00000000;
        3653:    rdata = 32'h00000000;
        3654:    rdata = 32'h00000000;
        3655:    rdata = 32'h00000000;
        3656:    rdata = 32'h00000000;
        3657:    rdata = 32'h00000000;
        3658:    rdata = 32'h00000000;
        3659:    rdata = 32'h00000000;
        3660:    rdata = 32'h00000000;
        3661:    rdata = 32'h00000000;
        3662:    rdata = 32'h00000000;
        3663:    rdata = 32'h00000000;
        3664:    rdata = 32'h00000000;
        3665:    rdata = 32'h00000000;
        3666:    rdata = 32'h00000000;
        3667:    rdata = 32'h00000000;
        3668:    rdata = 32'h00000000;
        3669:    rdata = 32'h00000000;
        3670:    rdata = 32'h00000000;
        3671:    rdata = 32'h00000000;
        3672:    rdata = 32'h00000000;
        3673:    rdata = 32'h00000000;
        3674:    rdata = 32'h00000000;
        3675:    rdata = 32'h00000000;
        3676:    rdata = 32'h00000000;
        3677:    rdata = 32'h00000000;
        3678:    rdata = 32'h00000000;
        3679:    rdata = 32'h00000000;
        3680:    rdata = 32'h00000000;
        3681:    rdata = 32'h00000000;
        3682:    rdata = 32'h00000000;
        3683:    rdata = 32'h00000000;
        3684:    rdata = 32'h00000000;
        3685:    rdata = 32'h00000000;
        3686:    rdata = 32'h00000000;
        3687:    rdata = 32'h00000000;
        3688:    rdata = 32'h00000000;
        3689:    rdata = 32'h00000000;
        3690:    rdata = 32'h00000000;
        3691:    rdata = 32'h00000000;
        3692:    rdata = 32'h00000000;
        3693:    rdata = 32'h00000000;
        3694:    rdata = 32'h00000000;
        3695:    rdata = 32'h00000000;
        3696:    rdata = 32'h00000000;
        3697:    rdata = 32'h00000000;
        3698:    rdata = 32'h00000000;
        3699:    rdata = 32'h00000000;
        3700:    rdata = 32'h00000000;
        3701:    rdata = 32'h00000000;
        3702:    rdata = 32'h00000000;
        3703:    rdata = 32'h00000000;
        3704:    rdata = 32'h00000000;
        3705:    rdata = 32'h00000000;
        3706:    rdata = 32'h00000000;
        3707:    rdata = 32'h00000000;
        3708:    rdata = 32'h00000000;
        3709:    rdata = 32'h00000000;
        3710:    rdata = 32'h00000000;
        3711:    rdata = 32'h00000000;
        3712:    rdata = 32'h00000000;
        3713:    rdata = 32'h00000000;
        3714:    rdata = 32'h00000000;
        3715:    rdata = 32'h00000000;
        3716:    rdata = 32'h00000000;
        3717:    rdata = 32'h00000000;
        3718:    rdata = 32'h00000000;
        3719:    rdata = 32'h00000000;
        3720:    rdata = 32'h00000000;
        3721:    rdata = 32'h00000000;
        3722:    rdata = 32'h00000000;
        3723:    rdata = 32'h00000000;
        3724:    rdata = 32'h00000000;
        3725:    rdata = 32'h00000000;
        3726:    rdata = 32'h00000000;
        3727:    rdata = 32'h00000000;
        3728:    rdata = 32'h00000000;
        3729:    rdata = 32'h00000000;
        3730:    rdata = 32'h00000000;
        3731:    rdata = 32'h00000000;
        3732:    rdata = 32'h00000000;
        3733:    rdata = 32'h00000000;
        3734:    rdata = 32'h00000000;
        3735:    rdata = 32'h00000000;
        3736:    rdata = 32'h00000000;
        3737:    rdata = 32'h00000000;
        3738:    rdata = 32'h00000000;
        3739:    rdata = 32'h00000000;
        3740:    rdata = 32'h00000000;
        3741:    rdata = 32'h00000000;
        3742:    rdata = 32'h00000000;
        3743:    rdata = 32'h00000000;
        3744:    rdata = 32'h00000000;
        3745:    rdata = 32'h00000000;
        3746:    rdata = 32'h00000000;
        3747:    rdata = 32'h00000000;
        3748:    rdata = 32'h00000000;
        3749:    rdata = 32'h00000000;
        3750:    rdata = 32'h00000000;
        3751:    rdata = 32'h00000000;
        3752:    rdata = 32'h00000000;
        3753:    rdata = 32'h00000000;
        3754:    rdata = 32'h00000000;
        3755:    rdata = 32'h00000000;
        3756:    rdata = 32'h00000000;
        3757:    rdata = 32'h00000000;
        3758:    rdata = 32'h00000000;
        3759:    rdata = 32'h00000000;
        3760:    rdata = 32'h00000000;
        3761:    rdata = 32'h00000000;
        3762:    rdata = 32'h00000000;
        3763:    rdata = 32'h00000000;
        3764:    rdata = 32'h00000000;
        3765:    rdata = 32'h00000000;
        3766:    rdata = 32'h00000000;
        3767:    rdata = 32'h00000000;
        3768:    rdata = 32'h00000000;
        3769:    rdata = 32'h00000000;
        3770:    rdata = 32'h00000000;
        3771:    rdata = 32'h00000000;
        3772:    rdata = 32'h00000000;
        3773:    rdata = 32'h00000000;
        3774:    rdata = 32'h00000000;
        3775:    rdata = 32'h00000000;
        3776:    rdata = 32'h00000000;
        3777:    rdata = 32'h00000000;
        3778:    rdata = 32'h00000000;
        3779:    rdata = 32'h00000000;
        3780:    rdata = 32'h00000000;
        3781:    rdata = 32'h00000000;
        3782:    rdata = 32'h00000000;
        3783:    rdata = 32'h00000000;
        3784:    rdata = 32'h00000000;
        3785:    rdata = 32'h00000000;
        3786:    rdata = 32'h00000000;
        3787:    rdata = 32'h00000000;
        3788:    rdata = 32'h00000000;
        3789:    rdata = 32'h00000000;
        3790:    rdata = 32'h00000000;
        3791:    rdata = 32'h00000000;
        3792:    rdata = 32'h00000000;
        3793:    rdata = 32'h00000000;
        3794:    rdata = 32'h00000000;
        3795:    rdata = 32'h00000000;
        3796:    rdata = 32'h00000000;
        3797:    rdata = 32'h00000000;
        3798:    rdata = 32'h00000000;
        3799:    rdata = 32'h00000000;
        3800:    rdata = 32'h00000000;
        3801:    rdata = 32'h00000000;
        3802:    rdata = 32'h00000000;
        3803:    rdata = 32'h00000000;
        3804:    rdata = 32'h00000000;
        3805:    rdata = 32'h00000000;
        3806:    rdata = 32'h00000000;
        3807:    rdata = 32'h00000000;
        3808:    rdata = 32'h00000000;
        3809:    rdata = 32'h00000000;
        3810:    rdata = 32'h00000000;
        3811:    rdata = 32'h00000000;
        3812:    rdata = 32'h00000000;
        3813:    rdata = 32'h00000000;
        3814:    rdata = 32'h00000000;
        3815:    rdata = 32'h00000000;
        3816:    rdata = 32'h00000000;
        3817:    rdata = 32'h00000000;
        3818:    rdata = 32'h00000000;
        3819:    rdata = 32'h00000000;
        3820:    rdata = 32'h00000000;
        3821:    rdata = 32'h00000000;
        3822:    rdata = 32'h00000000;
        3823:    rdata = 32'h00000000;
        3824:    rdata = 32'h00000000;
        3825:    rdata = 32'h00000000;
        3826:    rdata = 32'h00000000;
        3827:    rdata = 32'h00000000;
        3828:    rdata = 32'h00000000;
        3829:    rdata = 32'h00000000;
        3830:    rdata = 32'h00000000;
        3831:    rdata = 32'h00000000;
        3832:    rdata = 32'h00000000;
        3833:    rdata = 32'h00000000;
        3834:    rdata = 32'h00000000;
        3835:    rdata = 32'h00000000;
        3836:    rdata = 32'h00000000;
        3837:    rdata = 32'h00000000;
        3838:    rdata = 32'h00000000;
        3839:    rdata = 32'h00000000;
        3840:    rdata = 32'h00000000;
        3841:    rdata = 32'h00000000;
        3842:    rdata = 32'h00000000;
        3843:    rdata = 32'h00000000;
        3844:    rdata = 32'h00000000;
        3845:    rdata = 32'h00000000;
        3846:    rdata = 32'h00000000;
        3847:    rdata = 32'h00000000;
        3848:    rdata = 32'h00000000;
        3849:    rdata = 32'h00000000;
        3850:    rdata = 32'h00000000;
        3851:    rdata = 32'h00000000;
        3852:    rdata = 32'h00000000;
        3853:    rdata = 32'h00000000;
        3854:    rdata = 32'h00000000;
        3855:    rdata = 32'h00000000;
        3856:    rdata = 32'h00000000;
        3857:    rdata = 32'h00000000;
        3858:    rdata = 32'h00000000;
        3859:    rdata = 32'h00000000;
        3860:    rdata = 32'h00000000;
        3861:    rdata = 32'h00000000;
        3862:    rdata = 32'h00000000;
        3863:    rdata = 32'h00000000;
        3864:    rdata = 32'h00000000;
        3865:    rdata = 32'h00000000;
        3866:    rdata = 32'h00000000;
        3867:    rdata = 32'h00000000;
        3868:    rdata = 32'h00000000;
        3869:    rdata = 32'h00000000;
        3870:    rdata = 32'h00000000;
        3871:    rdata = 32'h00000000;
        3872:    rdata = 32'h00000000;
        3873:    rdata = 32'h00000000;
        3874:    rdata = 32'h00000000;
        3875:    rdata = 32'h00000000;
        3876:    rdata = 32'h00000000;
        3877:    rdata = 32'h00000000;
        3878:    rdata = 32'h00000000;
        3879:    rdata = 32'h00000000;
        3880:    rdata = 32'h00000000;
        3881:    rdata = 32'h00000000;
        3882:    rdata = 32'h00000000;
        3883:    rdata = 32'h00000000;
        3884:    rdata = 32'h00000000;
        3885:    rdata = 32'h00000000;
        3886:    rdata = 32'h00000000;
        3887:    rdata = 32'h00000000;
        3888:    rdata = 32'h00000000;
        3889:    rdata = 32'h00000000;
        3890:    rdata = 32'h00000000;
        3891:    rdata = 32'h00000000;
        3892:    rdata = 32'h00000000;
        3893:    rdata = 32'h00000000;
        3894:    rdata = 32'h00000000;
        3895:    rdata = 32'h00000000;
        3896:    rdata = 32'h00000000;
        3897:    rdata = 32'h00000000;
        3898:    rdata = 32'h00000000;
        3899:    rdata = 32'h00000000;
        3900:    rdata = 32'h00000000;
        3901:    rdata = 32'h00000000;
        3902:    rdata = 32'h00000000;
        3903:    rdata = 32'h00000000;
        3904:    rdata = 32'h00000000;
        3905:    rdata = 32'h00000000;
        3906:    rdata = 32'h00000000;
        3907:    rdata = 32'h00000000;
        3908:    rdata = 32'h00000000;
        3909:    rdata = 32'h00000000;
        3910:    rdata = 32'h00000000;
        3911:    rdata = 32'h00000000;
        3912:    rdata = 32'h00000000;
        3913:    rdata = 32'h00000000;
        3914:    rdata = 32'h00000000;
        3915:    rdata = 32'h00000000;
        3916:    rdata = 32'h00000000;
        3917:    rdata = 32'h00000000;
        3918:    rdata = 32'h00000000;
        3919:    rdata = 32'h00000000;
        3920:    rdata = 32'h00000000;
        3921:    rdata = 32'h00000000;
        3922:    rdata = 32'h00000000;
        3923:    rdata = 32'h00000000;
        3924:    rdata = 32'h00000000;
        3925:    rdata = 32'h00000000;
        3926:    rdata = 32'h00000000;
        3927:    rdata = 32'h00000000;
        3928:    rdata = 32'h00000000;
        3929:    rdata = 32'h00000000;
        3930:    rdata = 32'h00000000;
        3931:    rdata = 32'h00000000;
        3932:    rdata = 32'h00000000;
        3933:    rdata = 32'h00000000;
        3934:    rdata = 32'h00000000;
        3935:    rdata = 32'h00000000;
        3936:    rdata = 32'h00000000;
        3937:    rdata = 32'h00000000;
        3938:    rdata = 32'h00000000;
        3939:    rdata = 32'h00000000;
        3940:    rdata = 32'h00000000;
        3941:    rdata = 32'h00000000;
        3942:    rdata = 32'h00000000;
        3943:    rdata = 32'h00000000;
        3944:    rdata = 32'h00000000;
        3945:    rdata = 32'h00000000;
        3946:    rdata = 32'h00000000;
        3947:    rdata = 32'h00000000;
        3948:    rdata = 32'h00000000;
        3949:    rdata = 32'h00000000;
        3950:    rdata = 32'h00000000;
        3951:    rdata = 32'h00000000;
        3952:    rdata = 32'h00000000;
        3953:    rdata = 32'h00000000;
        3954:    rdata = 32'h00000000;
        3955:    rdata = 32'h00000000;
        3956:    rdata = 32'h00000000;
        3957:    rdata = 32'h00000000;
        3958:    rdata = 32'h00000000;
        3959:    rdata = 32'h00000000;
        3960:    rdata = 32'h00000000;
        3961:    rdata = 32'h00000000;
        3962:    rdata = 32'h00000000;
        3963:    rdata = 32'h00000000;
        3964:    rdata = 32'h00000000;
        3965:    rdata = 32'h00000000;
        3966:    rdata = 32'h00000000;
        3967:    rdata = 32'h00000000;
        3968:    rdata = 32'h00000000;
        3969:    rdata = 32'h00000000;
        3970:    rdata = 32'h00000000;
        3971:    rdata = 32'h00000000;
        3972:    rdata = 32'h00000000;
        3973:    rdata = 32'h00000000;
        3974:    rdata = 32'h00000000;
        3975:    rdata = 32'h00000000;
        3976:    rdata = 32'h00000000;
        3977:    rdata = 32'h00000000;
        3978:    rdata = 32'h00000000;
        3979:    rdata = 32'h00000000;
        3980:    rdata = 32'h00000000;
        3981:    rdata = 32'h00000000;
        3982:    rdata = 32'h00000000;
        3983:    rdata = 32'h00000000;
        3984:    rdata = 32'h00000000;
        3985:    rdata = 32'h00000000;
        3986:    rdata = 32'h00000000;
        3987:    rdata = 32'h00000000;
        3988:    rdata = 32'h00000000;
        3989:    rdata = 32'h00000000;
        3990:    rdata = 32'h00000000;
        3991:    rdata = 32'h00000000;
        3992:    rdata = 32'h00000000;
        3993:    rdata = 32'h00000000;
        3994:    rdata = 32'h00000000;
        3995:    rdata = 32'h00000000;
        3996:    rdata = 32'h00000000;
        3997:    rdata = 32'h00000000;
        3998:    rdata = 32'h00000000;
        3999:    rdata = 32'h00000000;
        4000:    rdata = 32'h00000000;
        4001:    rdata = 32'h00000000;
        4002:    rdata = 32'h00000000;
        4003:    rdata = 32'h00000000;
        4004:    rdata = 32'h00000000;
        4005:    rdata = 32'h00000000;
        4006:    rdata = 32'h00000000;
        4007:    rdata = 32'h00000000;
        4008:    rdata = 32'h00000000;
        4009:    rdata = 32'h00000000;
        4010:    rdata = 32'h00000000;
        4011:    rdata = 32'h00000000;
        4012:    rdata = 32'h00000000;
        4013:    rdata = 32'h00000000;
        4014:    rdata = 32'h00000000;
        4015:    rdata = 32'h00000000;
        4016:    rdata = 32'h00000000;
        4017:    rdata = 32'h00000000;
        4018:    rdata = 32'h00000000;
        4019:    rdata = 32'h00000000;
        4020:    rdata = 32'h00000000;
        4021:    rdata = 32'h00000000;
        4022:    rdata = 32'h00000000;
        4023:    rdata = 32'h00000000;
        4024:    rdata = 32'h00000000;
        4025:    rdata = 32'h00000000;
        4026:    rdata = 32'h00000000;
        4027:    rdata = 32'h00000000;
        4028:    rdata = 32'h00000000;
        4029:    rdata = 32'h00000000;
        4030:    rdata = 32'h00000000;
        4031:    rdata = 32'h00000000;
        4032:    rdata = 32'h00000000;
        4033:    rdata = 32'h00000000;
        4034:    rdata = 32'h00000000;
        4035:    rdata = 32'h00000000;
        4036:    rdata = 32'h00000000;
        4037:    rdata = 32'h00000000;
        4038:    rdata = 32'h00000000;
        4039:    rdata = 32'h00000000;
        4040:    rdata = 32'h00000000;
        4041:    rdata = 32'h00000000;
        4042:    rdata = 32'h00000000;
        4043:    rdata = 32'h00000000;
        4044:    rdata = 32'h00000000;
        4045:    rdata = 32'h00000000;
        4046:    rdata = 32'h00000000;
        4047:    rdata = 32'h00000000;
        4048:    rdata = 32'h00000000;
        4049:    rdata = 32'h00000000;
        4050:    rdata = 32'h00000000;
        4051:    rdata = 32'h00000000;
        4052:    rdata = 32'h00000000;
        4053:    rdata = 32'h00000000;
        4054:    rdata = 32'h00000000;
        4055:    rdata = 32'h00000000;
        4056:    rdata = 32'h00000000;
        4057:    rdata = 32'h00000000;
        4058:    rdata = 32'h00000000;
        4059:    rdata = 32'h00000000;
        4060:    rdata = 32'h00000000;
        4061:    rdata = 32'h00000000;
        4062:    rdata = 32'h00000000;
        4063:    rdata = 32'h00000000;
        4064:    rdata = 32'h00000000;
        4065:    rdata = 32'h00000000;
        4066:    rdata = 32'h00000000;
        4067:    rdata = 32'h00000000;
        4068:    rdata = 32'h00000000;
        4069:    rdata = 32'h00000000;
        4070:    rdata = 32'h00000000;
        4071:    rdata = 32'h00000000;
        4072:    rdata = 32'h00000000;
        4073:    rdata = 32'h00000000;
        4074:    rdata = 32'h00000000;
        4075:    rdata = 32'h00000000;
        4076:    rdata = 32'h00000000;
        4077:    rdata = 32'h00000000;
        4078:    rdata = 32'h00000000;
        4079:    rdata = 32'h00000000;
        4080:    rdata = 32'h00000000;
        4081:    rdata = 32'h00000000;
        4082:    rdata = 32'h00000000;
        4083:    rdata = 32'h00000000;
        4084:    rdata = 32'h00000000;
        4085:    rdata = 32'h00000000;
        4086:    rdata = 32'h00000000;
        4087:    rdata = 32'h00000000;
        4088:    rdata = 32'h00000000;
        4089:    rdata = 32'h00000000;
        4090:    rdata = 32'h00000000;
        4091:    rdata = 32'h00000000;
        4092:    rdata = 32'h00000000;
        4093:    rdata = 32'h00000000;
        4094:    rdata = 32'h00000000;
        4095:    rdata = 32'h00000000;
        default: rdata = 32'h00000000;
    endcase
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module boot_rom (
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  dbus,
    instr_bus.slave ibus
);


/**
 * Local variables and signals
 */

logic [31:0] addr, rdata;


/**
 * Submodules placement
 */

boot_mem u_boot_mem (
    .rdata,
    .addr
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rvalid <= 1'b0;
        dbus.rdata <= 32'b0;
        ibus.rvalid <= 1'b0;
        ibus.rdata <= 32'b0;
    end else begin
        dbus.rvalid <= dbus.gnt;
        dbus.rdata <= rdata;
        ibus.rvalid <= ibus.gnt;
        ibus.rdata <= rdata;
    end
end

always_comb begin
    addr = 32'b0;
    dbus.gnt = 1'b0;
    ibus.gnt = 1'b0;

    if (dbus.req) begin
        addr = dbus.addr;
        dbus.gnt = 1'b1;
    end else if (ibus.req) begin
        addr = ibus.addr;
        ibus.gnt = 1'b1;
    end
end

endmodule
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module code_ram (
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  dbus,
    instr_bus.slave ibus
);


/**
 * Local variables and signals
 */

logic [31:0] addr, rdata, wdata;
logic        req, we;
logic [3:0]  be;


/**
 * Signals assignments
 */

assign dbus.rdata = rdata;
assign ibus.rdata = rdata;


/**
 * Submodules placement
 */

ram u_ram (
    .clk,

    .rdata,
    .req,
    .addr,
    .we,
    .be,
    .wdata
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rvalid <= 1'b0;
        ibus.rvalid <= 1'b0;
    end else begin
        dbus.rvalid <= dbus.gnt;
        ibus.rvalid <= ibus.gnt;
    end
end

always_comb begin
    req = 1'b0;
    addr = 32'b0;
    we = 1'b0;
    be = 4'b0;
    wdata = 32'b0;
    dbus.gnt = 1'b0;
    ibus.gnt = 1'b0;

    if (dbus.req) begin
        req = 1'b1;
        addr = dbus.addr;
        we = dbus.we;
        be = dbus.be;
        wdata = dbus.wdata;
        dbus.gnt = 1'b1;
    end else if (ibus.req) begin
        req = 1'b1;
        addr = ibus.addr;
        ibus.gnt = 1'b1;
    end
end

endmodule
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module data_ram (
    input logic    clk,
    input logic    rst_n,

    data_bus.slave dbus
);


/**
 * Signals assignments
 */

assign dbus.gnt = dbus.req;


/**
 * Submodules placement
 */

ram u_ram (
    .clk,

    .rdata(dbus.rdata),
    .req(dbus.req),
    .addr(dbus.addr),
    .we(dbus.we),
    .be(dbus.be),
    .wdata(dbus.wdata)
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.gnt;
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart_clock_generator (
    input logic       clk,
    input logic       rst_n,

    output logic      sck,
    output logic      rising_edge,
    output logic      falling_edge,
    input logic       en,
    input logic       clk_divider_valid,
    input logic [7:0] clk_divider
);


/**
 * Local variables and signals
 */

logic       sck_nxt, rising_edge_nxt, falling_edge_nxt;
logic [7:0] counter, counter_nxt, counter_target, counter_target_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sck <= 1'b0;
        rising_edge <= 1'b0;
        falling_edge <= 1'b0;
        counter_target <= 8'b0;
        counter <= 8'b0;
    end else begin
        sck <= sck_nxt;
        rising_edge <= rising_edge_nxt;
        falling_edge <= falling_edge_nxt;
        counter_target <= counter_target_nxt;
        counter <= counter_nxt;
    end
end

always_comb begin
    sck_nxt = 1'b0;
    rising_edge_nxt = 1'b0;
    falling_edge_nxt = 1'b0;
    counter_target_nxt = counter_target;
    counter_nxt = 8'b0;

    if (clk_divider_valid) begin
        counter_target_nxt = clk_divider;
    end else if (en) begin
        sck_nxt = sck;
        counter_nxt = counter + 1;

        if (counter_target == 8'b0) begin
            sck_nxt = ~sck;
            rising_edge_nxt = ~sck;
            falling_edge_nxt = sck;
            counter_nxt = 8'b0;
        end else if (counter == counter_target) begin
            sck_nxt = ~sck;
            rising_edge_nxt = ~sck;
            falling_edge_nxt = sck;
            counter_nxt = 8'b0;
        end
    end
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

package uart_csr;


/**
 * Memory map
 */

const logic [11:0] UART_CR_OFFSET = 12'h000,    /* control register */
                   UART_SR_OFFSET = 12'h004,    /* status register */
                   UART_TDR_OFFSET = 12'h008,   /* transmitter data register */
                   UART_RDR_OFFSET = 12'h00c,   /* receiver data register */
                   UART_CDR_OFFSET = 12'h010,   /* clock divider register */
                   UART_IER_OFFSET = 12'h014,   /* interrupt enable register */
                   UART_ISR_OFFSET = 12'h018;   /* interrupt status register */


/**
 * User defined types
 */

typedef struct packed {
    logic [30:0] res;
    logic        en;
} uart_cr_t;

typedef struct packed {
    logic [28:0] res;
    logic        rxerr;
    logic        txact;
    logic        rxne;
} uart_sr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_tdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_rdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_cdr_t;

typedef struct packed {
    logic [29:0] res;
    logic        txactie;
    logic        rxneie;
} uart_ier_t;

typedef struct packed {
    logic [29:0] res;
    logic        txactf;
    logic        rxnef;
} uart_isr_t;

typedef struct packed {
    uart_cr_t  cr;
    uart_sr_t  sr;
    uart_tdr_t tdr;
    uart_rdr_t rdr;
    uart_cdr_t cdr;
    uart_ier_t ier;
    uart_isr_t isr;
} uart_csr_t;

endpackage
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart_receiver (
    input logic        clk,
    input logic        rst_n,

    output logic       busy,
    output logic       rx_data_valid,
    output logic [7:0] rx_data,
    output logic       error,
    input logic        sck_rising_edge,

    input logic        sin
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    START,
    ACTIVE,
    STOP
} state_t;


/**
 * Local variables and signals
 */

state_t     state, state_nxt;
logic       rx_data_valid_nxt;
logic [7:0] rx_data_nxt;
logic [2:0] bits_counter, bits_counter_nxt;
logic [3:0] edges_counter, edges_counter_nxt;
logic [7:0] rx_buffer, rx_buffer_nxt;
logic       error_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bits_counter <= 3'b0;
        edges_counter <= 4'b0;
    end else begin
        state <= state_nxt;
        bits_counter <= bits_counter_nxt;
        edges_counter <= edges_counter_nxt;
    end
end

always_comb begin
    state_nxt = state;
    bits_counter_nxt = bits_counter;
    edges_counter_nxt = edges_counter;

    case (state)
    IDLE: begin
        if (!sin)
            state_nxt = START;
    end
    START: begin
        if (sck_rising_edge) begin
            if (edges_counter == 15) begin
                state_nxt = ACTIVE;
                edges_counter_nxt = 4'b0;
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    ACTIVE: begin
        if (sck_rising_edge) begin
            if (edges_counter == 15) begin
                edges_counter_nxt = 4'b0;

                if (bits_counter == 7) begin
                    state_nxt = STOP;
                    bits_counter_nxt = 3'b0;
                end else begin
                    bits_counter_nxt = bits_counter + 1;
                end
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    STOP: begin
        if (sck_rising_edge) begin
            if (edges_counter == 7) begin
                state_nxt = IDLE;
                edges_counter_nxt = 4'b0;
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    default: ;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_data_valid <= 1'b0;
        rx_data <= 8'b0;
        error <= 1'b0;
        rx_buffer <= 8'b0;
    end else begin
        rx_data_valid <= rx_data_valid_nxt;
        rx_data <= rx_data_nxt;
        error <= error_nxt;
        rx_buffer <= rx_buffer_nxt;
    end
end

always_comb begin
    busy = 1'b1;
    rx_data_valid_nxt = 1'b0;
    rx_data_nxt = rx_data;
    error_nxt = error;
    rx_buffer_nxt = rx_buffer;

    case (state)
    IDLE: begin
        busy = 1'b0;
    end
    START: begin
        rx_buffer_nxt = 8'b0;
        error_nxt = 1'b0;
    end
    ACTIVE: begin
        if (sck_rising_edge && edges_counter == 7)
            rx_buffer_nxt = {sin, rx_buffer[7:1]};
    end
    STOP: begin
        if (sck_rising_edge) begin
            if (edges_counter == 7) begin
                rx_data_valid_nxt = 1'b1;
                rx_data_nxt = rx_buffer;
                error_nxt = ~sin;
            end
        end
    end
    default: ;
    endcase
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart_transmitter (
    input logic       clk,
    input logic       rst_n,

    output logic      busy,
    input logic       sck_rising_edge,
    input logic       tx_data_valid,
    input logic [7:0] tx_data,

    output logic      sout
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    START,
    ACTIVE,
    STOP
} state_t;


/**
 * Local variables and signals
 */

state_t     state, state_nxt;
logic       sout_nxt;
logic [2:0] bits_counter, bits_counter_nxt;
logic [3:0] edges_counter, edges_counter_nxt;
logic [7:0] tx_buffer, tx_buffer_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        bits_counter <= 3'b0;
        edges_counter <= 4'b0;
    end else begin
        state <= state_nxt;
        bits_counter <= bits_counter_nxt;
        edges_counter <= edges_counter_nxt;
    end
end

always_comb begin
    state_nxt = state;
    bits_counter_nxt = bits_counter;
    edges_counter_nxt = edges_counter;

    case (state)
    IDLE: begin
        if (tx_data_valid)
            state_nxt = START;
    end
    START: begin
        if (sck_rising_edge) begin
            if (edges_counter == 15) begin
                state_nxt = ACTIVE;
                edges_counter_nxt = 4'b0;
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    ACTIVE: begin
        if (sck_rising_edge) begin
            if (edges_counter == 15) begin
                edges_counter_nxt = 4'b0;

                if (bits_counter == 7) begin
                    state_nxt = STOP;
                    bits_counter_nxt = 3'b0;
                end else begin
                    bits_counter_nxt = bits_counter + 1;
                end
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    STOP: begin
        if (sck_rising_edge) begin
            if (edges_counter == 15) begin
                state_nxt = IDLE;
                edges_counter_nxt = 4'b0;
            end else begin
                edges_counter_nxt = edges_counter + 1;
            end
        end
    end
    default: ;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sout <= 1'b1;
        tx_buffer <= 8'b0;
    end else begin
        sout <= sout_nxt;
        tx_buffer <= tx_buffer_nxt;
    end
end

always_comb begin
    busy = 1'b1;
    sout_nxt = sout;
    tx_buffer_nxt = tx_buffer;

    case (state)
    IDLE: begin
        busy = 1'b0;
    end
    START: begin
        sout_nxt = 1'b0;
        tx_buffer_nxt = tx_data;

        if (sck_rising_edge && edges_counter == 15) begin
            sout_nxt = tx_buffer[0];
            tx_buffer_nxt = tx_buffer>>1;
        end
    end
    ACTIVE: begin
        if (sck_rising_edge && edges_counter == 15) begin
            if (bits_counter == 7) begin
                sout_nxt = 1'b1;
            end else begin
                sout_nxt = tx_buffer[0];
                tx_buffer_nxt = tx_buffer>>1;
            end
        end
    end
    STOP: ;
    default: ;
    endcase
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart
    import uart_csr::*;
(
    input logic    clk,
    input logic    rst_n,

    data_bus.slave dbus,

    output logic   sout,
    input logic    sin
);


/**
 * Local variables and signals
 */

uart_csr_t  csr, csr_nxt;
logic [7:0] rx_data;
logic       tx_data_valid, rx_data_valid, clk_divider_valid, tx_busy, rx_error,
            sck_rising_edge;


/**
 * Submodules placement
 */

uart_clock_generator u_uart_clock_generator (
    .clk,
    .rst_n,

    .sck(),
    .rising_edge(sck_rising_edge),
    .falling_edge(),
    .en(csr.cr.en),
    .clk_divider_valid,
    .clk_divider(csr.cdr.data)
);

uart_transmitter u_uart_transmitter (
    .clk,
    .rst_n,

    .busy(tx_busy),
    .sck_rising_edge,
    .tx_data_valid,
    .tx_data(csr.tdr.data),

    .sout
);

uart_receiver u_uart_receiver (
    .clk,
    .rst_n,

    .busy(),
    .rx_data_valid,
    .rx_data,
    .error(rx_error),
    .sck_rising_edge,

    .sin
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        UART_CR_OFFSET, UART_SR_OFFSET, UART_TDR_OFFSET, UART_RDR_OFFSET, UART_CDR_OFFSET,
        UART_IER_OFFSET, UART_ISR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return dbus.req && dbus.we && dbus.addr[11:0] == offset;
endfunction

function automatic logic is_reg_read(logic [11:0] offset);
    return dbus.req && dbus.addr[11:0] == offset;
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) dbus.req |-> is_offset_valid(dbus.addr[11:0])) else
    $warning("incorrect offset requested: 0x%x", dbus.addr[11:0]);


/**
 * Module internal logic
 */

always_comb begin
    dbus.gnt = dbus.req;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.gnt;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr <= {{7{32'b0}}};
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;
    end else begin
        csr <= csr_nxt;
        tx_data_valid <= is_reg_written(UART_TDR_OFFSET);
        clk_divider_valid <= is_reg_written(UART_CDR_OFFSET);
    end
end

always_comb begin
    csr_nxt = csr;

    if (dbus.req && dbus.we) begin
        case (dbus.addr[11:0])
        UART_CR_OFFSET:     csr_nxt.cr = dbus.wdata;
        UART_SR_OFFSET:     csr_nxt.sr = dbus.wdata;
        UART_TDR_OFFSET:    csr_nxt.tdr = dbus.wdata;
        UART_RDR_OFFSET:    csr_nxt.rdr = dbus.wdata;
        UART_CDR_OFFSET:    csr_nxt.cdr = dbus.wdata;
        UART_IER_OFFSET:    csr_nxt.ier = dbus.wdata;
        UART_ISR_OFFSET:    csr_nxt.isr = dbus.wdata;
        endcase
    end

    if (rx_error)
        csr_nxt.sr.rxerr = 1'b1;

    csr_nxt.sr.txact = tx_busy;

    if (rx_data_valid)
        csr_nxt.sr.rxne = 1'b1;
    else if (is_reg_read(UART_RDR_OFFSET))
        csr_nxt.sr.rxne = 1'b0;

    if (rx_data_valid)
        csr_nxt.rdr.data = rx_data;

    if (csr.sr.txact && !csr_nxt.sr.txact)
        csr_nxt.isr.txactf = 1'b1;

    if (!csr.sr.rxne && csr_nxt.sr.rxne)
        csr_nxt.isr.rxnef = 1'b1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rdata <= 32'b0;
    end else begin
        if (dbus.req) begin
            case (dbus.addr[11:0])
            UART_CR_OFFSET:     dbus.rdata <= csr.cr;
            UART_SR_OFFSET:     dbus.rdata <= csr.sr;
            UART_TDR_OFFSET:    dbus.rdata <= csr.tdr;
            UART_RDR_OFFSET:    dbus.rdata <= csr.rdr;
            UART_CDR_OFFSET:    dbus.rdata <= csr.cdr;
            UART_IER_OFFSET:    dbus.rdata <= csr.ier;
            UART_ISR_OFFSET:    dbus.rdata <= csr.isr;
            endcase
        end
    end
end

endmodule
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

package memory_map;

const logic [31:0] BOOT_ROM_BASE_ADDRESS = 32'h0000_0000,
                   BOOT_ROM_END_ADDRESS = 32'h0000_3fff,

                   CODE_RAM_BASE_ADDRESS = 32'h0001_0000,
                   CODE_RAM_END_ADDRESS = 32'h0001_3fff,

                   DATA_RAM_BASE_ADDRESS = 32'h4000_0000,
                   DATA_RAM_END_ADDRESS = 32'h4000_3fff,

                   GPIO_BASE_ADDRESS = 32'hc000_0000,
                   GPIO_END_ADDRESS = 32'hc000_0fff,

                   UART_BASE_ADDRESS = 32'hc000_1000,
                   UART_END_ADDRESS = 32'hc000_1fff;
endpackage
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module data_bus_arbiter
    import memory_map::*;
(
    input logic     clk,
    input logic     rst_n,

    data_bus.slave  core_dbus,

    data_bus.master boot_rom_dbus,
    data_bus.master code_ram_dbus,
    data_bus.master data_ram_dbus,

    data_bus.master gpio_dbus,
    data_bus.master uart_dbus
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    IDLE,
    WAITING_FOR_GRANT,
    WAITING_FOR_RESPONSE
} state_t;


/**
 * Local variables and signals
 */

state_t      state, state_nxt;
logic [31:0] requested_addr, requested_addr_nxt;


/**
 * Tasks and functions definitions
 */

`define attach_core_data_bus_to_slave(bus) \
    bus.req = core_dbus.req; \
    bus.we = core_dbus.we; \
    bus.be = core_dbus.be; \
    bus.addr = core_dbus.addr; \
    bus.wdata = core_dbus.wdata

`define attach_zeros_to_slave_data_bus(bus) \
    bus.req = 1'b0; \
    bus.we = 1'b0; \
    bus.be = 4'b0; \
    bus.addr = 32'b0; \
    bus.wdata = 32'b0

`define attach_slave_data_bus_to_core(bus) \
    core_dbus.gnt = bus.gnt; \
    core_dbus.rvalid = bus.rvalid; \
    core_dbus.rdata = bus.rdata

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS],
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS],
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS],
        [UART_BASE_ADDRESS:UART_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_dbus.req |-> is_address_valid(core_dbus.addr)) else
    $warning("incorrect address requested: 0x%x", core_dbus.addr);


/**
 * Module internal logic
 */

/* state control */

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
        if (core_dbus.req)
            state_nxt = core_dbus.gnt ? WAITING_FOR_RESPONSE : WAITING_FOR_GRANT;
    end
    WAITING_FOR_GRANT: begin
        if (core_dbus.gnt)
            state_nxt = WAITING_FOR_RESPONSE;
    end
    WAITING_FOR_RESPONSE: begin
        if (core_dbus.rvalid)
            state_nxt = IDLE;
    end
    endcase
end

/* core input signals demultiplexing */

always_comb begin
    `attach_zeros_to_slave_data_bus(boot_rom_dbus);
    `attach_zeros_to_slave_data_bus(code_ram_dbus);
    `attach_zeros_to_slave_data_bus(data_ram_dbus);
    `attach_zeros_to_slave_data_bus(gpio_dbus);
    `attach_zeros_to_slave_data_bus(uart_dbus);

    case (state)
    IDLE,
    WAITING_FOR_GRANT: begin
        if (core_dbus.req) begin
            case (core_dbus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(boot_rom_dbus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(code_ram_dbus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(data_ram_dbus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(gpio_dbus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_core_data_bus_to_slave(uart_dbus);
            end
            endcase
        end
    end
    WAITING_FOR_RESPONSE: ;
    endcase
end

/* core output signals multiplexing */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        requested_addr <= 32'b0;
    else
        requested_addr <= requested_addr_nxt;
end

always_comb begin
    requested_addr_nxt = requested_addr;
    core_dbus.gnt = 1'b0;
    core_dbus.rvalid = 1'b0;
    core_dbus.rdata = 32'b0;

    case (state)
    IDLE: begin
        if (core_dbus.req) begin
            core_dbus.gnt = 1'b1;
            requested_addr_nxt = core_dbus.addr;

            case (core_dbus.addr) inside
            [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(boot_rom_dbus);
            end
            [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(code_ram_dbus);
            end
            [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(data_ram_dbus);
            end
            [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(gpio_dbus);
            end
            [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
                `attach_slave_data_bus_to_core(uart_dbus);
            end
            endcase
        end
    end
    WAITING_FOR_GRANT: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_dbus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_dbus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_dbus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_dbus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_dbus);
        end
        endcase
    end
    WAITING_FOR_RESPONSE: begin
        case (requested_addr) inside
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(boot_rom_dbus);
        end
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(code_ram_dbus);
        end
        [DATA_RAM_BASE_ADDRESS:DATA_RAM_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(data_ram_dbus);
        end
        [GPIO_BASE_ADDRESS:GPIO_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(gpio_dbus);
        end
        [UART_BASE_ADDRESS:UART_END_ADDRESS]: begin
            `attach_slave_data_bus_to_core(uart_dbus);
        end
        default: begin
            core_dbus.rvalid = 1'b1;
        end
        endcase
    end
    endcase
end

endmodule
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module instr_bus_arbiter
    import memory_map::*;
(
    input logic      clk,
    input logic      rst_n,

    instr_bus.slave  core_ibus,

    instr_bus.master boot_rom_ibus,
    instr_bus.master code_ram_ibus
);


/**
 * User defined types
 */

typedef enum logic [1:0] {
    INVALID,
    BOOT_ROM,
    CODE_RAM
} slave_t;


/**
 * Local variables and signals
 */

slave_t requested_slave, responding_slave;


/**
 * Tasks and functions definitions
 */

function automatic logic is_address_valid(logic [31:0] address);
    return address inside {
        [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS],
        [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]
    };
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) core_ibus.req |-> is_address_valid(core_ibus.addr)) else
    $warning("incorrect address requested: 0x%x", core_ibus.addr);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        responding_slave <= INVALID;
    else
        responding_slave <= requested_slave;
end

always_comb begin
    case (core_ibus.addr) inside
    [BOOT_ROM_BASE_ADDRESS:BOOT_ROM_END_ADDRESS]:   requested_slave = BOOT_ROM;
    [CODE_RAM_BASE_ADDRESS:CODE_RAM_END_ADDRESS]:   requested_slave = CODE_RAM;
    default:                                        requested_slave = INVALID;
    endcase
end

always_comb begin
    case (requested_slave)
    BOOT_ROM: begin
        core_ibus.gnt = boot_rom_ibus.gnt;
        boot_rom_ibus.addr = core_ibus.addr;
        boot_rom_ibus.req = core_ibus.req;

        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    CODE_RAM: begin
        core_ibus.gnt = code_ram_ibus.gnt;
        code_ram_ibus.addr = core_ibus.addr;
        code_ram_ibus.req = core_ibus.req;

        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
    end
    INVALID: begin
        core_ibus.gnt = 1'b0;
        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    default: begin
        core_ibus.gnt = 1'b0;
        boot_rom_ibus.addr = 32'b0;
        boot_rom_ibus.req = 1'b0;
        code_ram_ibus.addr = 32'b0;
        code_ram_ibus.req = 1'b0;
    end
    endcase
end

always_comb begin
    case (responding_slave)
    BOOT_ROM: begin
        core_ibus.rvalid = boot_rom_ibus.rvalid;
        core_ibus.rdata = boot_rom_ibus.rdata;
    end
    CODE_RAM: begin
        core_ibus.rvalid = code_ram_ibus.rvalid;
        core_ibus.rdata = code_ram_ibus.rdata;
    end
    default: begin
        core_ibus.rvalid = 1'b0;
        core_ibus.rdata = 32'b0;
    end
    endcase
end

endmodule
/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module soc (
    input logic         clk,
    input logic         rst_n,

    output logic [31:0] gpio_dout,
    input logic [31:0]  gpio_din,

    output logic        uart_sout,
    input logic         uart_sin
);


/**
 * Local variables and signals
 */

data_bus  core_dbus ();
data_bus  boot_rom_dbus ();
data_bus  code_ram_dbus ();
data_bus  data_ram_dbus ();
data_bus  gpio_dbus ();
data_bus  uart_dbus ();

instr_bus core_ibus ();
instr_bus boot_rom_ibus ();
instr_bus code_ram_ibus ();


/**
 * Submodules placement
 */

core u_core (
    .clk,
    .rst_n,

    .ibus(core_ibus),
    .dbus(core_dbus)
);

data_bus_arbiter u_data_bus_arbiter (
    .clk,
    .rst_n,

    .core_dbus,

    .boot_rom_dbus,
    .code_ram_dbus,
    .data_ram_dbus,
    .gpio_dbus,
    .uart_dbus
);

instr_bus_arbiter u_instr_bus_arbiter (
    .clk,
    .rst_n,

    .core_ibus,

    .boot_rom_ibus,
    .code_ram_ibus
);

boot_rom u_boot_rom (
    .clk,
    .rst_n,

    .dbus(boot_rom_dbus),
    .ibus(boot_rom_ibus)
);

code_ram u_code_ram (
    .clk,
    .rst_n,

    .dbus(code_ram_dbus),
    .ibus(code_ram_ibus)
);

data_ram u_data_ram (
    .clk,
    .rst_n,

    .dbus(data_ram_dbus)
);

gpio u_gpio (
    .clk,
    .rst_n,

    .dbus(gpio_dbus),

    .dout(gpio_dout),
    .din(gpio_din)
);

uart u_uart (
    .clk,
    .rst_n,

    .dbus(uart_dbus),

    .sout(uart_sout),
    .sin(uart_sin)
);

endmodule
/**
 * Copyright (C) 2021  AGH University of Science and Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

`timescale 1ns / 1ns
`ifdef KMIE_IMPLEMENT_ASIC

module mtm_riscv_chip (
    input logic        clk,
    input logic        rst_n,

    output logic [3:0] gpio_dout,
    input logic [3:0]  gpio_din,

    output logic       uart_sout,
    input logic        uart_sin
);


/**
 * Local variables and signals
 */

logic        soc_clk, soc_rst_n;
logic [31:0] soc_gpio_dout, soc_gpio_din;
logic        soc_uart_sout, soc_uart_sin;


/**
 * Submodules placement
 */

soc u_soc (
    .clk(soc_clk),
    .rst_n(soc_rst_n),

    .gpio_dout(soc_gpio_dout),
    .gpio_din(soc_gpio_din),

    .uart_sout(soc_uart_sout),
    .uart_sin(soc_uart_sin)
);

pads_out u_pads_out (
    .boot_sequence_done(),
    .led(gpio_dout[3:0]),
    .spi_mosi(),
    .spi_sck(),
    .spi_ss(),
    .uart_sout(uart_sout),
    .boot_sequence_done_core(1'b0),
    .led_core(soc_gpio_dout[3:0]),
    .spi_mosi_core(1'b0),
    .spi_sck_core(1'b0),
    .spi_ss_core(1'b0),
    .uart_sout_core(soc_uart_sout)
);

pads_in u_pads_in (
    .btn_core(soc_gpio_din[3:0]),
    .clk_core(soc_clk),
    .rst_n_core(soc_rst_n),
    .spi_miso_core(),
    .uart_sin_core(soc_uart_sin),
    .btn(gpio_din[3:0]),
    .clk(clk),
    .rst_n(rst_n),
    .spi_miso(),
    .uart_sin(uart_sin)
);

pads_pwr u_pads_pwr ();

endmodule

`endif
// Library - PPCU_VLSI_RISCV, Cell - pads_in, View - schematic
// LAST TIME SAVED: Apr  6 13:28:29 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns 
`ifdef KMIE_IMPLEMENT_ASIC

module pads_in ( btn_core, clk_core, rst_n_core, spi_miso_core,
     uart_sin_core, btn, clk, rst_n, spi_miso, uart_sin );

output  clk_core, rst_n_core, spi_miso_core, uart_sin_core;

input  clk, rst_n, spi_miso, uart_sin;

output [3:0]  btn_core;

input [3:0]  btn;

//------------------------------------------------------------------------------
// TODO: replace input pad names with the correct ones
//------------------------------------------------------------------------------

PDISDGZ u_btn_3_ ( .C(btn_core[3]), .PAD(btn[3]) );
PDISDGZ u_btn_2_ ( .C(btn_core[2]), .PAD(btn[2]) );
PDISDGZ u_btn_1_ ( .C(btn_core[1]), .PAD(btn[1]) );
PDISDGZ u_btn_0_ ( .C(btn_core[0]), .PAD(btn[0]) );
PDISDGZ u_clk ( .C(clk_core), .PAD(clk) );
PDISDGZ u_rst_n ( .C(rst_n_core), .PAD(rst_n) );
// PDB02SDGZ u_spi_miso ( .C(spi_miso_core), .PAD(spi_miso), .OEN(oen));
PDISDGZ u_uart_sin ( .C(uart_sin_core), .PAD(uart_sin) );
endmodule


`endif


// was PDIDGZ
// PDIDGZ u_btn_3_ ( .C(btn_core[3]), .PAD(btn[3]));
// PDIDGZ u_btn_2_ ( .C(btn_core[2]), .PAD(btn[2]));
// PDIDGZ u_btn_1_ ( .C(btn_core[1]), .PAD(btn[1]));
// PDIDGZ u_btn_0_ ( .C(btn_core[0]), .PAD(btn[0]));
// PDIDGZ u_clk ( .C(clk_core), .PAD(clk));
// PDIDGZ u_rst_n ( .C(rst_n_core), .PAD(rst_n));
// PDIDGZ u_spi_miso ( .C(spi_miso_core), .PAD(spi_miso));
// PDIDGZ u_uart_sin ( .C(uart_sin_core), .PAD(uart_sin));
// endmodule// Library - PPCU_VLSI_RISCV, Cell - pads_out, View - schematic
// LAST TIME SAVED: Apr  6 13:28:29 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns
`ifdef KMIE_IMPLEMENT_ASIC

module pads_out ( boot_sequence_done, led, spi_mosi, spi_sck, spi_ss,
    uart_sout, boot_sequence_done_core, led_core, spi_mosi_core,
    spi_sck_core, spi_ss_core, uart_sout_core );

output       boot_sequence_done, spi_mosi, spi_sck, spi_ss, uart_sout;

input boot_sequence_done_core, spi_mosi_core, spi_sck_core,
spi_ss_core, uart_sout_core;

output [3:0] led;

input  [3:0] led_core;

//------------------------------------------------------------------------------
// TODO: replace cell names to the correct ones
//------------------------------------------------------------------------------
// was PDO24CDG

PDO12CDG u_led_3_ ( .PAD(led[3]), .I(led_core[3]));
PDO12CDG u_led_2_ ( .PAD(led[2]), .I(led_core[2]));
PDO12CDG u_led_1_ ( .PAD(led[1]), .I(led_core[1]));
PDO12CDG u_led_0_ ( .PAD(led[0]), .I(led_core[0]));
// PDO12CDG u_spi_mosi ( .PAD(spi_mosi), .I(spi_mosi_core));
// PDO12CDG u_spi_sck ( .PAD(spi_sck), .I(spi_sck_core));
// PDO12CDG u_spi_ss ( .PAD(spi_ss), .I(spi_ss_core));
PDO12CDG u_uart_sout ( .PAD(uart_sout), .I(uart_sout_core));
// PDO12CDG u_boot_sequence_done ( .PAD(boot_sequence_done),
//    .I(boot_sequence_done_core));

endmodule

`endif
// Library - PPCU_VLSI_RISCV, Cell - pads_pwr, View - schematic
// LAST TIME SAVED: Apr  6 13:36:45 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns

// TODO: provide proper number of power pads
// Note: the module must be set to "dont_touch" in the constraints

`ifdef KMIE_IMPLEMENT_ASIC

module pads_pwr ( );

//-- pad instances are note connected

//------------------------------------------------------------------------------
// TODO: add the correct number of the power pads
//------------------------------------------------------------------------------

// core vdd
PVDD1DGZ VDD1_1_ ( .VDD() );
PVDD1DGZ VDD1_0_ ( .VDD() );
    
// io vdd    
// PVDD2DGZ VDD2_1_ ( .VDDPST() );
PVDD2DGZ VDD2_0_ ( .VDDPST() );
    
// io power on control (only one)
PVDD2POC VDD2POC ( .VDDPST() );
    
// common ground 
PVSS3DGZ VSS3_3_ ( .VSS() );
PVSS3DGZ VSS3_2_ ( .VSS() );   
PVSS3DGZ VSS3_1_ ( .VSS() );
PVSS3DGZ VSS3_0_ ( .VSS() );

endmodule

`endif