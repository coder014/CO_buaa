`timescale 1ns / 1ps
`include "../const.v"

module Decoder(
    input [5:0] opcode, //Opcode zone of instruction
    input [5:0] funct, //Funct zone of instruction
    input [4:0] spj, //Special judgement for mfc0/mtc0
    output RegWrite,
    output MemWrite,
    output reg [3:0] JType, //Jump Type
    output RegDst,
    output MemToReg,
    output reg [3:0] ALUCtr,
    output ALUSrc,
    output Link,
    output MFC0,
    output MTC0,
    output ERET,
    output MoveFromMDU,
    output MoveToMDU,
    output StartMDU,
    output reg [2:0] MDUSel,
    output reg [2:0] MemSel,
    output reg [1:0] RsUsage,
    output reg [1:0] RtUsage,
    output reg [4:0] Exc
    );

    wire special = opcode == 0;
    wire add = special && (funct == 6'b100000);
    wire sub = special && (funct == 6'b100010);
    wire addu = special && (funct == 6'b100001);
    wire subu = special && (funct == 6'b100011);
    wire _and_ = special && (funct == 6'b100100);
    wire _or_ = special && (funct == 6'b100101);
    wire lui = opcode == 6'b001111;
    wire andi = opcode == 6'b001100;
    wire ori = opcode == 6'b001101;
    wire addi = opcode == 6'b001000;
    wire addiu = opcode == 6'b001001;
    wire lw = opcode == 6'b100011;
    wire sw = opcode == 6'b101011;
    wire lh = opcode == 6'b100001;
    wire sh = opcode == 6'b101001;
    wire lb = opcode == 6'b100000;
    wire sb = opcode == 6'b101000;
    wire beq = opcode == 6'b000100;
    wire bne = opcode == 6'b000101;
    wire jal = opcode == 6'b000011;
    wire jr = special && (funct == 6'b001000);
    wire slt = special && (funct == 6'b101010);
    wire sltu = special && (funct == 6'b101011);
    wire mult = special && (funct == 6'b011000);
    wire multu = special && (funct == 6'b011001);
    wire div = special && (funct == 6'b011010);
    wire divu = special && (funct == 6'b011011);
    wire mfhi = special && (funct == 6'b010000);
    wire mthi = special && (funct == 6'b010001);
    wire mflo = special && (funct == 6'b010010);
    wire mtlo = special && (funct == 6'b010011);
    wire nop = special && (funct == 6'b000000);
    wire c0series = (opcode == 6'b010000) && (funct == 6'b000000);
    assign ERET = (opcode == 6'b010000) && (funct == 6'b011000);
    wire syscall = special && (funct == 6'b001100);
    
    assign MFC0 = c0series && (spj == 5'b00000);
    assign MTC0 = c0series && (spj == 5'b00100);
    
    wire KnownOP = add||sub||addu||subu||addiu||_and_||_or_||lui||andi||ori||addi||lw||sw||lh||sh||lb||sb||beq||bne||jal
                   ||jr||slt||sltu||mult||multu||div||divu||mfhi||mthi||mflo||mtlo||nop||c0series||ERET||syscall;
    
    always@(*) begin
        if(!KnownOP) Exc = `EXCCODE_RI;
        else if(syscall) Exc = `EXCCODE_SYSCALL;
        else Exc = 0;
    end

    assign MemWrite = sw||sh||sb;
    assign RegWrite = add||sub||lui||andi||ori||lw||lh||lb||jal
                      ||_and_||_or_||addi||slt||sltu||addu||subu||addiu
                      ||mfhi||mflo||MFC0;
    assign ALUSrc = lui||andi||ori||sw||lw||sh||lh||sb||lb||addi||addiu;
    assign RegDst = add||sub||addu||subu||_and_||_or_||slt||sltu||mfhi||mflo;
    assign MemToReg = lw||lh||lb;
    assign Link = jal;
    
    assign MoveFromMDU = mfhi||mflo;
    assign MoveToMDU = mthi||mtlo;
    assign StartMDU = mult||multu||div||divu;
    
    always@(*) begin
        if(mult) MDUSel = `MULDIV_DO_MUL;
        else if(multu) MDUSel = `MULDIV_DO_MULU;
        else if(div) MDUSel = `MULDIV_DO_DIV;
        else if(divu) MDUSel = `MULDIV_DO_DIVU;
        else if(mfhi||mthi) MDUSel = `MULDIV_SELECT_HI;
        else if(mflo||mtlo) MDUSel = `MULDIV_SELECT_LO;
        else MDUSel = 3'b111;
    end
    
    always@(*) begin
        if(sw) MemSel = `MEM_STORE_WORD;
        else if(sh) MemSel = `MEM_STORE_HALF;
        else if(sb) MemSel = `MEM_STORE_BYTE;
        else if(lw) MemSel = `MEM_LOAD_WORD;
        else if(lh) MemSel = `MEM_LOAD_HALF;
        else if(lb) MemSel = `MEM_LOAD_BYTE;
        else MemSel = 0;
    end

    always@(*) begin
        if(add || addi) ALUCtr = `ALUOP_ADD;
        else if(addu || addiu) ALUCtr = `ALUOP_ADDU;
        else if(lw || lh || lb) ALUCtr = `ALUOP_ADD_LOAD;
        else if(sw || sh || sb) ALUCtr = `ALUOP_ADD_STORE;
        else if(sub) ALUCtr = `ALUOP_SUB;
        else if(subu) ALUCtr = `ALUOP_SUBU;
        else if(lui) ALUCtr = `ALUOP_LUI;
        else if(andi) ALUCtr = `ALUOP_ANDI;
        else if(ori) ALUCtr = `ALUOP_ORI;
        else if(_and_) ALUCtr = `ALUOP_AND;
        else if(_or_) ALUCtr = `ALUOP_OR;
        else if(slt) ALUCtr = `ALUOP_SLT;
        else if(sltu) ALUCtr = `ALUOP_SLTU;
        else ALUCtr = `ALUOP_ADDU;
    end

    always@(*) begin
        if(jal) JType = `JUMP_JAL;
        else if(jr) JType = `JUMP_JR;
        else if(beq) JType = `JUMP_BEQ;
        else if(bne) JType = `JUMP_BNE;
        else if(ERET) JType = `JUMP_ERET;
        else JType = `JUMP_NONE;
    end
    
    always@(*) begin
        if(!KnownOP) RsUsage = `VALUE_USE_NONE;
        else if(lui || jal || mfhi || mflo || MFC0 || MTC0 || syscall || ERET) RsUsage = `VALUE_USE_NONE;
        else if(beq || bne || jr) RsUsage = `VALUE_USE_NOW;
        else RsUsage = `VALUE_USE_NEXT;
        
        if(!KnownOP) RtUsage = `VALUE_USE_NONE;
        else if(andi || ori || lui || jal || jr || addi || addiu || syscall || ERET) RtUsage = `VALUE_USE_NONE;
        else if(mfhi || mflo || mthi || mtlo || MFC0 || MTC0) RtUsage = `VALUE_USE_NONE;
        else if(beq || bne) RtUsage = `VALUE_USE_NOW;
        //Caution! For sb/sw/sh instruction needs rt value at the NEXT of the NEXT cycle
        //?? so it's ok to regard it as USE_NONE WITHOUT STALL ??
        else if(sw || sh || sb || lw || lh || lb) RtUsage = `VALUE_USE_NONE;
        else RtUsage = `VALUE_USE_NEXT;
    end

endmodule
