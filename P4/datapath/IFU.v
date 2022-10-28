`timescale 1ns / 1ps
`include "../control/SignalDefs.v"

module IFU(
    input clk,
    input rst, //! Sync reset
    input [1:0] npc_sel, //Control signal selects the next pc
    input [25:0] imm26,
    input [31:0] imm32, //Immediate value used to calculate the next pc
    output reg [31:0] PC, //Value of current pc+4
    output [31:0] PC_4, //Value of current pc+4
    output [31:0] Instr //Instruction read out
    );

    wire [13:2] internal_addr = PC[13:2];
    reg [31:0] npc;
    assign PC_4 = PC + 4;
    IM im(.A(internal_addr), .D(Instr)); //Instantiate an IM
    
    always@(*) begin
        case(npc_sel)
            `NPC_ADD4: npc = PC_4;
            `NPC_OFFSET: npc = PC_4 + (imm32 << 2);
            `NPC_JUMP_S: npc = {PC[31:28], imm26, 2'b00};
            `NPC_JUMP_L: npc = imm32;
        endcase
    end
    
    always@(posedge clk) begin
        if(rst) PC <= 32'h0000_3000; //Reset to 0x00003000
        else PC <= npc;
    end

endmodule
