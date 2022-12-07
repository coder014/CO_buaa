`timescale 1ns / 1ps
`include "../const.v"

module MulDiv(
    input clk,
    input rst, // ! Sync reset
    input req,
    input start,
    input WE,
    input [2:0] sel,
    input [31:0] A,
    input [31:0] B,
    output busy,
    output reg [31:0] C
    );
    
    reg [31:0] lo,hi;
    reg [3:0] ctr;

    always@(posedge clk) begin
        if(rst) begin
            lo <= 0;
            hi <= 0;
            ctr <= 0;
        end else if(!req && WE) begin
            ctr <= 0;
            if(sel==`MULDIV_SELECT_LO) begin
                lo <= A;
            end else if(sel==`MULDIV_SELECT_HI) begin
                hi <= A;
            end
        end else if(!req && start) begin
            if(sel==`MULDIV_DO_MUL) begin
                ctr <= 5;
                {hi, lo} <= $signed(A) * $signed(B);
            end else if(sel==`MULDIV_DO_MULU) begin
                ctr <= 5;
                {hi, lo} <= A * B;
            end else if(sel==`MULDIV_DO_DIV) begin
                ctr <= 10;
                lo <= $signed(A) / $signed(B);
                hi <= $signed(A) % $signed(B);
            end else if(sel==`MULDIV_DO_DIVU) begin
                ctr <= 10;
                lo <= A / B;
                hi <= A % B;
            end
        end else if(ctr>0) ctr <= ctr - 4'd1;
    end
    
    always@(*) begin
        if(ctr>0) C = 0;
        else begin
            if(sel==`MULDIV_SELECT_LO)
                C = lo;
            else if(sel==`MULDIV_SELECT_HI)
                C = hi;
            else C = 0;
        end
    end
    assign busy = ctr > 0;

endmodule
