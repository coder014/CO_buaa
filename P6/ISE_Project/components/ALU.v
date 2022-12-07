`timescale 1ns / 1ps
`include "../const.v"

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] op, //operation control signal
    output reg [31:0] C
    );

    always@(*) begin
        case(op)
            `ALUOP_ADD: C = A + B;
            `ALUOP_SUB: C = A - B;
            `ALUOP_ANDI: C = A & B[15:0];
            `ALUOP_ORI: C = A | B[15:0];
            `ALUOP_LUI: C = B[15:0] << 16;
            `ALUOP_AND: C = A & B;
            `ALUOP_OR: C = A | B;
            `ALUOP_SLT: C = $signed(A) < $signed(B);
            `ALUOP_SLTU: C = A < B;
            default: C = 0;
        endcase
    end

endmodule
