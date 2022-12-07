`timescale 1ns / 1ps
`include "../const.v"

module NpcController(
    input [3:0] op,
    input [31:0] pc4,
    input [31:0] data1,
    input [31:0] data2,
    input [25:0] imm26,
    input [31:0] imm32,
    input [31:0] epc,
    output reg [31:0] out,
    output reg sel,
    output reg ClearSlot,
    output reg IsSlot
    );

    always@(*) begin
        case(op)
            `JUMP_NONE: begin
                out = 0;
                sel = 0;
                IsSlot = 0;
                ClearSlot = 0;
            end
            `JUMP_BEQ: begin
                sel = data1 == data2;
                out = pc4 + (imm32 << 2);
                IsSlot = 1;
                ClearSlot = 0;
            end
            `JUMP_BNE: begin
                sel = data1 != data2;
                out = pc4 + (imm32 << 2);
                IsSlot = 1;
                ClearSlot = 0;
            end
            `JUMP_JAL: begin
                sel = 1;
                out = {pc4[31:28], imm26, 2'b00};
                IsSlot = 1;
                ClearSlot = 0;
            end
            `JUMP_JR: begin
                sel = 1;
                out = data1;
                IsSlot = 1;
                ClearSlot = 0;
            end
            `JUMP_ERET: begin
                sel = 1;
                out = epc;
                IsSlot = 0;
                ClearSlot = 1;
            end
            default: begin
                out = 0;
                sel = 0;
                IsSlot = 0;
                ClearSlot = 0;
            end
        endcase
    end

endmodule
