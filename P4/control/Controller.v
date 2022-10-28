`timescale 1ns / 1ps
`include "SignalDefs.v"

module Controller(
    input [5:0] opcode, //Opcode zone of instruction
    input [5:0] funct, //Funct zone of instruction
    input [31:0] ALUResult, //Result of ALU (usually for compare)
    output RegWrite,
    output MemWrite,
    output reg [1:0] NPC,
    output [1:0] RegDst,
    output [1:0] RegSrc,
    output reg [3:0] ALUCtr,
    output ALUSrc,
    output ImmSrc
    );

    wire special = opcode == 0;
    wire add = special && funct == 6'b100000;
    wire sub = special && funct == 6'b100010;
    wire lui = opcode == 6'b001111;
    wire ori = opcode == 6'b001101;
    wire lw = opcode == 6'b100011;
    wire sw = opcode == 6'b101011;
    wire beq = opcode == 6'b000100;
    wire nop = special && funct == 0;
    wire jal = opcode == 6'b000011;
    wire jr = special && funct == 6'b001000;
    
    assign ImmSrc = jr;
    assign MemWrite = sw;
    assign RegWrite = add||sub||lui||ori||lw||jal;
    assign ALUSrc = lui||ori||sw||lw;
    assign RegDst = (add || sub) ? 2'b01 :
                    jal ? 2'b10 : 2'b00;
    assign RegSrc = lw ? 2'b01 :
                    jal ? 2'b10 : 2'b00;
    always@(*) begin
        if(add || lw || sw || jr) ALUCtr = `ALUOP_ADD;
        else if(sub) ALUCtr = `ALUOP_SUB;
        else if(lui) ALUCtr = `ALUOP_LUI;
        else if(ori) ALUCtr = `ALUOP_ORI;
        else if(beq) ALUCtr = `ALUOP_EQU;
        else ALUCtr = `ALUOP_ADD;
    end
    always@(*) begin
        if(jal) NPC = `NPC_JUMP_S;
        else if(jr) NPC = `NPC_JUMP_L;
        else if(beq) NPC = ALUResult[0] ? `NPC_OFFSET : `NPC_ADD4;
        else NPC = `NPC_ADD4;
    end

endmodule
