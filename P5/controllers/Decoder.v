`timescale 1ns / 1ps
`include "../const.v"

module Decoder(
    input [5:0] opcode, //Opcode zone of instruction
    input [5:0] funct, //Funct zone of instruction
    output RegWrite,
    output MemWrite,
    output reg [3:0] JType, //Jump Type
    output RegDst,
    output MemToReg,
    output reg [3:0] ALUCtr,
    output ALUSrc,
    output Link,
    output reg [1:0] RsUsage,
    output reg [1:0] RtUsage
    );

    wire special = opcode == 0;
    wire add = special && (funct == 6'b100000);
    wire sub = special && (funct == 6'b100010);
    wire lui = opcode == 6'b001111;
    wire ori = opcode == 6'b001101;
    wire lw = opcode == 6'b100011;
    wire sw = opcode == 6'b101011;
    wire beq = opcode == 6'b000100;
    wire jal = opcode == 6'b000011;
    wire jr = special && (funct == 6'b001000);

    assign MemWrite = sw;
    assign RegWrite = add||sub||lui||ori||lw||jal;
    assign ALUSrc = lui||ori||sw||lw;
    assign RegDst = add || sub;
    assign MemToReg = lw;
    assign Link = jal;

    always@(*) begin
        if(add || lw || sw) ALUCtr = `ALUOP_ADD;
        else if(sub) ALUCtr = `ALUOP_SUB;
        else if(lui) ALUCtr = `ALUOP_LUI;
        else if(ori) ALUCtr = `ALUOP_ORI;
        else ALUCtr = `ALUOP_ADD;
    end

    always@(*) begin
        if(jal) JType = `JUMP_JAL;
        else if(jr) JType = `JUMP_JR;
        else if(beq) JType = `JUMP_BEQ;
        else JType = `JUMP_NONE;
    end
    
    always@(*) begin
        if(lui || jal) RsUsage = `VALUE_USE_NONE;
        else if(beq || jr) RsUsage = `VALUE_USE_NOW;
        else RsUsage = `VALUE_USE_NEXT;
        
        if(ori || lw || lui || jal || jr) RtUsage = `VALUE_USE_NONE;
        else if(beq) RtUsage = `VALUE_USE_NOW;
        //Caution! For sb/sw/sh instruction needs rt value at the NEXT of the NEXT cycle
        //?? so it's ok to regard it as USE_NONE WITHOUT STALL ??
        else if(sw) RtUsage = `VALUE_USE_NONE;
        else RtUsage = `VALUE_USE_NEXT;
    end

endmodule
