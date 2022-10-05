`timescale 1ns / 1ps

module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output reg [31:0] C
    );

    wire [31:0] res_add, res_sub, res_and,
        res_or, res_srl, res_sra;
    
    assign res_add = A + B;
    assign res_sub = A - B;
    assign res_and = A & B;
    assign res_or = A | B;
    assign res_srl = A >> B;
    assign res_sra = $signed(A) >>> B;
    
    always @(*) begin
        case(ALUOp)
            3'b000: C = res_add;
            3'b001: C = res_sub;
            3'b010: C = res_and;
            3'b011: C = res_or;
            3'b100: C = res_srl;
            3'b101: C = res_sra;
            default: C = 0;
        endcase
    end
endmodule
