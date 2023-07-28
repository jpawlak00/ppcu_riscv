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
