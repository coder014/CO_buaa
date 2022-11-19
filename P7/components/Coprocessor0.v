`timescale 1ns / 1ps

module Coprocessor0(
    input clk,
    input rst,
    input WE,
    input [4:0] A,
    input [31:0] Data,
    output reg [31:0] Out,
    input [31:0] PC,
    input IsSlot,
    input [4:0] ExcCode,
    input [5:0] HwInt,
    input Eret,
    output reg [31:0] EPC,
    output IRQ
    );

    reg [31:0] SR, Cause;
    
    wire ExcIRQ = !(SR[1]) && (|ExcCode);
    wire HwIRQ = !(SR[1]) && SR[0] && (|(SR[15:10] & HwInt));
    assign IRQ = ExcIRQ || HwIRQ;
    
    always@(*) begin
        if(A==5'd12) Out = SR;
        else if(A==5'd13) Out = Cause;
        else if(A==5'd14) Out = EPC;
        else Out = 0;
    end

    always@(posedge clk) begin //SR zone
        if(rst) SR <= 0;
        else begin
            if(Eret) SR[1] <= 0; //Reset EXL
            else if(IRQ) SR[1] <= 1'b1; //Set EXL
            else if(WE && A==5'd12) SR <= {16'b0, Data[15:10], 8'b0, Data[1:0]};
        end
    end
    
    always@(posedge clk) begin //Cause zone
        if(rst) Cause <= 0;
        else begin
            Cause[15:10] <= HwInt; //Update IP
            if(IRQ) begin
                Cause[31] <= IsSlot; //Update BD
                Cause[6:2] <= HwIRQ ? 5'b0 : ExcCode; //Update ExcCode, interrupt first
            end
        end
    end
    
    always@(posedge clk) begin //EPC zone
        if(rst) EPC <= 0;
        else begin
            if(IRQ) EPC <= IsSlot ? (PC - 32'd4) : PC; //Update EPC
            else if(WE && A==5'd14) EPC <= Data;
        end
    end

endmodule
