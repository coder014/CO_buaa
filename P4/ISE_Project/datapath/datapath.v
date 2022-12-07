`timescale 1ns / 1ps

module datapath(
    input clk,
    input rst,
    input RegWrite,
    input MemWrite,
    input [1:0] NPC,
    input [1:0] RegDst,
    input [1:0] RegSrc,
    input [3:0] ALUCtr,
    input ALUSrc,
    input ImmSrc,
    output [5:0] opcode, //Opcode zone of instruction
    output [5:0] funct, //Funct zone of instruction
    output [31:0] ALUResult //Result of ALU
    );

    wire [31:0] instr, pc, pc_4, imm32_src;
    assign opcode = instr[31:26];
    assign funct = instr[5:0];
    wire [4:0] R_rs = instr[25:21];
    wire [4:0] R_rt = instr[20:16];
    wire [4:0] R_rd = instr[15:11];
    wire [15:0] I_imm = instr[15:0];
    wire [31:0] imm_signext = $signed(I_imm);
    wire [25:0] J_imm = instr[25:0];
    wire [4:0] const_ra = 5'd31;
    wire [4:0] reg_addr;
    wire [31:0] reg_data, grf_rd1, grf_rd2, alu_data, mem_out;
    
    IFU IFU(.clk(clk), .rst(rst), .npc_sel(NPC), .imm26(J_imm), .imm32(imm32_src), .PC(pc), .PC_4(pc_4), .Instr(instr));
    mux4 #(5) mux_regdst(.sel(RegDst), .in0(R_rt), .in1(R_rd), .in2(const_ra), .out(reg_addr));
    GRF GRF(.clk(clk), .WE(RegWrite), .rst(rst), .A1(R_rs), .A2(R_rt), .A3(reg_addr), .WD(reg_data), .WPC(pc), .RD1(grf_rd1), .RD2(grf_rd2));
    mux2 #(32) mux_alusrc(.sel(ALUSrc), .in0(grf_rd2), .in1(imm_signext), .out(alu_data));
    ALU ALU(.A(grf_rd1), .B(alu_data), .op(ALUCtr), .C(ALUResult));
    DM DM(.clk(clk), .rst(rst), .str(MemWrite), .A(ALUResult[13:2]), .D(grf_rd2), .pc(pc), .RD(mem_out));
    mux4 #(32) mux_regsrc(.sel(RegSrc), .in0(ALUResult), .in1(mem_out), .in2(pc_4), .out(reg_data));
    mux2 #(32) mux_IFU_imm32(.sel(ImmSrc), .in0(imm_signext), .in1(reg_data), .out(imm32_src));
    
endmodule
