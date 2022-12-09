`timescale 1ns / 1ps

module StageD(
    input clk,
    input rst, // ! Sync reset
    input stall,
    input req,
    input flush,
    input [31:0] instr_in,
    input [31:0] pc_in,
    input [4:0] exc_in,
    input slot_in,
    input [31:0] jumpto,
    output [31:0] instr_out,
    output reg [31:0] pc_out,
    output reg [4:0] exc_out,
    output reg slot_out
    );
    
    reg [31:0] instr;
    reg pass;
    assign instr_out = pass ? ((|exc_out) ? 0 : instr_in) : instr;

    always@(posedge clk) begin
        if(rst) begin
            pass <= 0;
            instr <= 0;
            pc_out <= 32'h0000_3000;
            exc_out <= 0;
            slot_out <= 0;
        end else if(req) begin
            pass <= 0;
            instr <= 0;
            pc_out <= 32'h0000_4180;
            exc_out <= 0;
            slot_out <= 0;
        end else if(stall) begin
            pass <= 0;
            instr <= instr_out;
        end else if(flush) begin
            pass <= 0;
            instr <= 0;
            exc_out <= exc_in; // or 0
            pc_out <= jumpto;
            slot_out <= 0;
        end else begin
            pass <= 1;
            instr <= (|exc_in) ? 0 : instr_in;
            pc_out <= pc_in;
            exc_out <= exc_in;
            slot_out <= slot_in;
        end
    end

endmodule
