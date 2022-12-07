`timescale 1ns / 1ps
`include "../const.v"

module IFU(
    input clk,
    input rst, //! Sync reset
    input sel, //Control signal selects the next pc
    input [31:0] imm,
    input stall,
    input req,
    input [31:0] i_instr,
    output reg [31:0] PC, //Value of current pc
    output reg [4:0] exc,
    output reg [31:0] Instr
    );
    wire [31:0] PC_4 = PC + 4;
    
    always@(posedge clk) begin
        if(rst) PC <= 32'h0000_3000; //Reset to 0x00003000
        else if(req) PC <= 32'h0000_4180;
        else if(!stall) PC <= sel ? imm : PC_4;
    end
    
    always@(*) begin
        if(|(PC[1:0])) exc = `EXCCODE_ADEL;
        else if((PC < 32'h00003000) || (PC > 32'h00006ffc)) exc = `EXCCODE_ADEL;
        else exc = 0;
        
        if(exc!=0) Instr = 0;
        else Instr = i_instr;
    end

endmodule
