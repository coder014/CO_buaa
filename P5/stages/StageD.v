`timescale 1ns / 1ps

module StageD(
    input clk,
    input rst, // ! Sync reset
    input stall,
    input [31:0] instr_in,
    input [31:0] pc_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
    );

    always@(posedge clk) begin
        if(rst) begin
            instr_out <= 0;
            pc_out <= 0;
        end else if(!stall) begin
            instr_out <= instr_in;
            pc_out <= pc_in;
        end
    end

endmodule
