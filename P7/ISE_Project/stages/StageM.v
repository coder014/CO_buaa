`timescale 1ns / 1ps

module StageM(
    input clk,
    input rst, // ! Sync reset
    input req,
    input RegWrite_in,
    input MemWrite_in,
    input MemToReg_in,
    input [31:0] ALUOut_in,
    input [31:0] WriteData_in,
    input [4:0] RegAddr_in,
    input [31:0] pc_in,
    input [4:0] rt_in,
    input [4:0] rd_in,
    input [2:0] MemSel_in,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg [31:0] ALUOut_out,
    output reg [31:0] WriteData_out,
    output reg [4:0] RegAddr_out,
    output reg [31:0] pc_out,
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
            MemToReg_out <= 0;
            ALUOut_out <= 0;
            WriteData_out <= 0;
            RegAddr_out <= 0;
            pc_out <= 32'h0000_3000;
            rt_out <= 0;
            rd_out <= 0;
            MemSel_out <= 0;
            MFC0_out <= 0;
            MTC0_out <= 0;
            ERET_out <= 0;
            exc_out <= 0;
            slot_out <= 0;
        end else if(req) begin
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemToReg_out <= 0;
            ALUOut_out <= 0;
            WriteData_out <= 0;
            RegAddr_out <= 0;
            pc_out <= 32'h0000_4180;
            rt_out <= 0;
            rd_out <= 0;
            MemSel_out <= 0;
            MFC0_out <= 0;
            MTC0_out <= 0;
            ERET_out <= 0;
            exc_out <= 0;
            slot_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            ALUOut_out <= ALUOut_in;
            WriteData_out <= WriteData_in;
            RegAddr_out <= RegAddr_in;
            pc_out <= pc_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
            MemSel_out <= MemSel_in;
            MFC0_out <= MFC0_in;
            MTC0_out <= MTC0_in;
            ERET_out <= ERET_in;
            exc_out <= exc_in;
            slot_out <= slot_in;
        end
    end

endmodule
