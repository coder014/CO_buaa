`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
    );

    wire RegWrite,MemWrite,ALUSrc,ImmSrc;
    wire [1:0] NPC,RegDst,RegSrc;
    wire [3:0] ALUCtr;
    wire [5:0] opcode,funct;
    wire [31:0] ALUResult;

    datapath datapath(.clk(clk), .rst(reset), .RegWrite(RegWrite), .MemWrite(MemWrite), .NPC(NPC), .RegDst(RegDst), .RegSrc(RegSrc), .ALUCtr(ALUCtr), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc), .opcode(opcode), .funct(funct), .ALUResult(ALUResult));
    Controller controller(.RegWrite(RegWrite), .MemWrite(MemWrite), .NPC(NPC), .RegDst(RegDst), .RegSrc(RegSrc), .ALUCtr(ALUCtr), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc), .opcode(opcode), .funct(funct), .ALUResult(ALUResult));

endmodule
