`timescale 1ns / 1ps
`include "../const.v"

module MemDataExt(
    input [2:0] sel,
    input [1:0] AddrLow,
    input [31:0] RawData,
    output reg [31:0] ParsedData
    );

    always@(*) begin
        case(sel)
            `MEM_LOAD_WORD: begin
                ParsedData = RawData;
            end
            `MEM_LOAD_HALF: begin
                if(AddrLow[1]) ParsedData = $signed(RawData[31:16]);
                else ParsedData = $signed(RawData[15:0]);
            end
            `MEM_LOAD_BYTE: begin
                if(AddrLow==2'b11) ParsedData = $signed(RawData[31:24]);
                else if(AddrLow==2'b10) ParsedData = $signed(RawData[23:16]);
                else if(AddrLow==2'b01) ParsedData = $signed(RawData[15:8]);
                else ParsedData = $signed(RawData[7:0]);
            end
            default: ParsedData = 0;
        endcase
    end

endmodule
