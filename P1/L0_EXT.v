`timescale 1ns / 1ps

module ext(
    input [15:0] imm,
    input [1:0] EOp,
    output reg [31:0] ext
    );

    wire [31:0] S_ext, Z_ext, lui, other;
    
    assign S_ext = {{16{S_ext[15]}}, imm};
    assign Z_ext = {{16{1'b0}}, imm};
    assign lui = {imm, {16{1'b0}}};
    assign other = {{14{S_ext[15]}}, imm, {2{1'b0}}};
    
    always @(*) begin
        case(EOp)
            2'b00: ext = S_ext;
            2'b01: ext = Z_ext;
            2'b10: ext = lui;
            2'b11: ext = other;
            default:;
        endcase
    end
endmodule
