`timescale 1ns / 1ps

module StageM(
    input clk,
    input rst, // ! Sync reset
    input RegWrite_in,
    input MemWrite_in,
    input MemToReg_in,
    input [31:0] ALUOut_in,
    input [31:0] WriteData_in,
    input [4:0] RegAddr_in,
    input [31:0] pc_in,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg [31:0] ALUOut_out,
    output reg [31:0] WriteData_out,
    output reg [4:0] RegAddr_out,
    output reg [31:0] pc_out
    );

    always@(posedge clk) begin
        if(rst) begin
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemToReg_out <= 0;
            ALUOut_out <= 0;
            WriteData_out <= 0;
            RegAddr_out <= 0;
            pc_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            ALUOut_out <= ALUOut_in;
            WriteData_out <= WriteData_in;
            RegAddr_out <= RegAddr_in;
            pc_out <= pc_in;
        end
    end

endmodule
