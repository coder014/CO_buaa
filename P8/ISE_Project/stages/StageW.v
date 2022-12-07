`timescale 1ns / 1ps

module StageW(
    input clk,
    input rst, // ! Sync reset
    input req,
    input RegWrite_in,
    input MemToReg_in,
    input [31:0] ALUOut_in,
    input [31:0] ReadData_in,
    input [4:0] RegAddr_in,
    input [31:0] pc_in,
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg [31:0] ALUOut_out,
    output [31:0] ReadData_out,
    output reg [4:0] RegAddr_out,
    output reg [31:0] pc_out
    );
    
    assign ReadData_out = ReadData_in;

    always@(posedge clk) begin
        if(rst) begin
            RegWrite_out <= 0;
            MemToReg_out <= 0;
            ALUOut_out <= 0;
            //ReadData_out <= 0;
            RegAddr_out <= 0;
            pc_out <= 32'h0000_3000;
        end else if(req) begin
            RegWrite_out <= 0;
            MemToReg_out <= 0;
            ALUOut_out <= 0;
            //ReadData_out <= 0;
            RegAddr_out <= 0;
            pc_out <= 32'h0000_4180;
        end else begin
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            ALUOut_out <= ALUOut_in;
            //ReadData_out <= ReadData_in;
            RegAddr_out <= RegAddr_in;
            pc_out <= pc_in;
        end
    end

endmodule
