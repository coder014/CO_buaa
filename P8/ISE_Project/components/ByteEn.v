`timescale 1ns / 1ps
`include "../const.v"

module ByteEn(
    input MemWrite,
    input [2:0] sel,
    input [1:0] AddrLow,
    input [31:0] RawData,
    output reg [3:0] En,
    output reg [31:0] ParsedData
    );
    
    always@(*) begin
        if(MemWrite) begin
            case(sel)
                `MEM_STORE_WORD: begin
                    En = 4'b1111;
                    ParsedData = RawData;
                end
                `MEM_STORE_HALF: begin
                    if(AddrLow[1]) begin
                        En = 4'b1100;
                        ParsedData = {RawData[15:0], 16'b0};
                    end
                    else begin
                        En = 4'b0011;
                        ParsedData = RawData;
                    end
                end
                `MEM_STORE_BYTE: begin
                    En = 4'd1 << AddrLow;
                    if(AddrLow==2'b11) ParsedData = {RawData[7:0], 24'b0};
                    else if(AddrLow==2'b10) ParsedData = {RawData[15:0], 16'b0};
                    else if(AddrLow==2'b01) ParsedData = {RawData[23:0], 8'b0};
                    else ParsedData = RawData;
                end
                default: begin
                    En = 0;
                    ParsedData = 0;
                end
            endcase
        end else begin
            En = 0;
            ParsedData = 0;
        end
    end

endmodule
