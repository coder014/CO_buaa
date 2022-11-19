`timescale 1ns / 1ps

module StageE(
    input clk,
    input rst, // ! Sync reset
    input flush,
    input req,
    input RegWrite_in,
    input MemWrite_in,
    input RegDst_in,
    input MemToReg_in,
    input [3:0] ALUCtr_in,
    input ALUSrc_in,
    input Link_in,
    input [31:0] data1_in,
    input [31:0] data2_in,
    input [4:0] rs_in,
    input [4:0] rt_in,
    input [4:0] rd_in,
    input [31:0] imm_in,
    input [31:0] pc_in,
    input MoveFromMDU_in,
    input MoveToMDU_in,
    input StartMDU_in,
    input [2:0] MDUSel_in,
    input [2:0] MemSel_in,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg RegDst_out,
    output reg MemToReg_out,
    output reg [3:0] ALUCtr_out,
    output reg ALUSrc_out,
    output reg Link_out,
    output reg [31:0] data1_out,
    output reg [31:0] data2_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [31:0] imm_out,
    output reg [31:0] pc_out,
    output reg MoveFromMDU_out,
    output reg MoveToMDU_out,
    output reg StartMDU_out,
    output reg [2:0] MDUSel_out,
    output reg [2:0] MemSel_out,
    input MFC0_in,
    input MTC0_in,
    input ERET_in,
    input [4:0] exc_in,
    input slot_in,
    output reg MFC0_out,
    output reg MTC0_out,
    output reg ERET_out,
    output reg [4:0] exc_out,
    output reg slot_out
    );

    always@(posedge clk) begin
        if(rst) begin
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            RegDst_out <= 0;
            MemToReg_out <= 0;
            ALUCtr_out <= 0;
            ALUSrc_out <= 0;
            Link_out <= 0;
            data1_out <= 0;
            data2_out <= 0;
            rs_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            imm_out <= 0;
            pc_out <= 32'h0000_3000;
            MoveFromMDU_out <= 0;
            MoveToMDU_out <= 0;
            StartMDU_out <= 0;
            MDUSel_out <= 0;
            MemSel_out <= 0;
            MFC0_out <= 0;
            MTC0_out <= 0;
            ERET_out <= 0;
            exc_out <= 0;
            slot_out <= 0;
        end else if(req) begin
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            RegDst_out <= 0;
            MemToReg_out <= 0;
            ALUCtr_out <= 0;
            ALUSrc_out <= 0;
            Link_out <= 0;
            data1_out <= 0;
            data2_out <= 0;
            rs_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            imm_out <= 0;
            pc_out <= 32'h0000_4180;
            MoveFromMDU_out <= 0;
            MoveToMDU_out <= 0;
            StartMDU_out <= 0;
            MDUSel_out <= 0;
            MemSel_out <= 0;
            MFC0_out <= 0;
            MTC0_out <= 0;
            ERET_out <= 0;
            exc_out <= 0;
            slot_out <= 0;
        end else if(flush) begin
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            RegDst_out <= 0;
            MemToReg_out <= 0;
            ALUCtr_out <= 0;
            ALUSrc_out <= 0;
            Link_out <= 0;
            data1_out <= 0;
            data2_out <= 0;
            rs_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            imm_out <= 0;
            MoveFromMDU_out <= 0;
            MoveToMDU_out <= 0;
            StartMDU_out <= 0;
            MDUSel_out <= 0;
            MemSel_out <= 0;
            MFC0_out <= 0;
            MTC0_out <= 0;
            ERET_out <= 0;
            exc_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            RegDst_out <= RegDst_in;
            MemToReg_out <= MemToReg_in;
            ALUCtr_out <= ALUCtr_in;
            ALUSrc_out <= ALUSrc_in;
            Link_out <= Link_in;
            data1_out <= data1_in;
            data2_out <= data2_in;
            rs_out <= rs_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
            imm_out <= imm_in;
            pc_out <= pc_in;
            MoveFromMDU_out <= MoveFromMDU_in;
            MoveToMDU_out <= MoveToMDU_in;
            StartMDU_out <= StartMDU_in;
            MDUSel_out <= MDUSel_in;
            MemSel_out <= MemSel_in;
            MFC0_out <= MFC0_in;
            MTC0_out <= MTC0_in;
            ERET_out <= ERET_in;
            exc_out <= exc_in;
            slot_out <= slot_in;
        end
    end

endmodule
