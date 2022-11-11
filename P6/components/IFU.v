`timescale 1ns / 1ps

module IFU(
    input clk,
    input rst, //! Sync reset
    input sel, //Control signal selects the next pc
    input [31:0] imm,
    input stall,
    output reg [31:0] PC, //Value of current pc
    output [31:0] PC_4 //Value of current pc+4
    );
    assign PC_4 = PC + 4;
    
    always@(posedge clk) begin
        if(rst) PC <= 32'h0000_3000; //Reset to 0x00003000
        else if(!stall) PC <= (sel ? imm : PC_4);
    end

endmodule
