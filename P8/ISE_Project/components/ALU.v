`timescale 1ns / 1ps
`include "../const.v"

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] op, //operation control signal
    output reg [31:0] C,
    output reg [4:0] Exc
    );
    
    reg [32:0] temp;

    always@(*) begin
        case(op)
            `ALUOP_ADDU, `ALUOP_ADD,
            `ALUOP_ADD_LOAD, `ALUOP_ADD_STORE: C = A + B;
            `ALUOP_SUB, `ALUOP_SUBU: C = A - B;
            `ALUOP_ANDI: C = A & B[15:0];
            `ALUOP_ORI: C = A | B[15:0];
            `ALUOP_LUI: C = B[15:0] << 16;
            `ALUOP_AND: C = A & B;
            `ALUOP_OR: C = A | B;
            `ALUOP_SLT: C = $signed(A) < $signed(B);
            `ALUOP_SLTU: C = A < B;
            default: C = 0;
        endcase
        
        case(op)
            `ALUOP_ADD: begin
                temp = {A[31], A} + {B[31], B};
                if(temp[32]!=temp[31]) Exc = `EXCCODE_OV;
                else Exc = 0;
            end
            `ALUOP_SUB: begin
                temp = {A[31], A} - {B[31], B};
                if(temp[32]!=temp[31]) Exc = `EXCCODE_OV;
                else Exc = 0;
            end
            `ALUOP_ADD_LOAD: begin
                temp = {A[31], A} + {B[31], B};
                if(temp[32]!=temp[31]) Exc = `EXCCODE_ADEL;
                else Exc = 0;
            end
            `ALUOP_ADD_STORE: begin
                temp = {A[31], A} + {B[31], B};
                if(temp[32]!=temp[31]) Exc = `EXCCODE_ADES;
                else Exc = 0;
            end
            default: begin
                temp = 0;
                Exc = 0;
            end
        endcase
    end

endmodule
