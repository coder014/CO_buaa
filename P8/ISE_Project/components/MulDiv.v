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
    wire ready, inter_valid;
    wire [31:0] inter_res0, inter_res1;
    reg [1:0] inter_op;
    reg inter_sign;
    
    assign busy = !ready;

    always@(posedge clk) begin
        if(rst) begin
            lo <= 0;
            hi <= 0;
        end else if (inter_valid) begin
            lo <= inter_res0;
            hi <= inter_res1;
        end else if(!req && WE) begin
            if(sel==`MULDIV_SELECT_LO) begin
                lo <= A;
            end else if(sel==`MULDIV_SELECT_HI) begin
                hi <= A;
            end
        end
    end
    
    always@(*) begin
        if(!req && start) begin
            if(sel==`MULDIV_DO_MUL) begin
                inter_op = 2'd1;
                inter_sign = 1'b1;
            end else if(sel==`MULDIV_DO_MULU) begin
                inter_op = 2'd1;
                inter_sign = 0;
            end else if(sel==`MULDIV_DO_DIV) begin
                inter_op = 2'd2;
                inter_sign = 1'b1;
            end else if(sel==`MULDIV_DO_DIVU) begin
                inter_op = 2'd2;
                inter_sign = 0;
            end else begin
                inter_op = 0;
                inter_sign = 0;
            end
        end else begin
            inter_op = 0;
            inter_sign = 0;
        end

        if(!ready) begin
            C = 0;
        end else begin
            if(sel==`MULDIV_SELECT_LO)
                C = lo;
            else if(sel==`MULDIV_SELECT_HI)
                C = hi;
            else C = 0;
        end
    end
    
    MDU_internal MDU_internal(
        .clk(clk), 
        .reset(rst), 
        .in_src0(A), 
        .in_src1(B), 
        .in_op(inter_op), 
        .in_sign(inter_sign), 
        .in_ready(ready), 
        .in_valid(!req && start), 
        .out_ready(1'b1), 
        .out_valid(inter_valid), 
        .out_res0(inter_res0), 
        .out_res1(inter_res1)
    );

endmodule
