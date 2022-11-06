`timescale 1ns / 1ps

module IFU(
    input clk,
    input rst, //! Sync reset
    input sel, //Control signal selects the next pc
    input [31:0] imm,
    input stall,
    output [31:0] PC_4, //Value of current pc+4
    output [31:0] Instr //Instruction read out
    );
    reg [31:0] PC;
    wire [15:2] internal_addr = PC[15:2];
    assign PC_4 = PC + 4;
    IM im(.A(internal_addr), .D(Instr)); //Instantiate an IM
    
    always@(posedge clk) begin
        if(rst) PC <= 32'h0000_3000; //Reset to 0x00003000
        else if(!stall) PC <= (sel ? imm : PC_4);
    end

endmodule
