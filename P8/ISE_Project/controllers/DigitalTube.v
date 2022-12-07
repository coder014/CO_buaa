`timescale 1ns / 1ps

module DigitalTube(
    input clk,
    input rst,

    output [3:0] sel0,
    output [7:0] seg0,
    output [3:0] sel1,
    output [7:0] seg1,
    output sel2,
    output [7:0] seg2,
    
    input [31:0] Addr,
    input [3:0] ByteEn,
    input [31:0] Din,
    output reg [31:0] Dout
    );
    
    reg [31:0] g0;
    reg [3:0] g1;
    reg [31:0] wdata;
    
    always@(posedge clk) begin
        if(rst) begin
            g0 <= 32'h88888888;
            g1 <= 4'h8;
        end else begin
            if((|ByteEn) && ((Addr>>2) == (32'h7f50>>2))) g0 <= wdata;
            else if((|ByteEn) && ((Addr>>2) == (32'h7f54>>2))) g1 <= wdata[3:0];
        end
    end

    always@(*) begin
        if((Addr>>2) == (32'h7f50>>2)) begin
            Dout = g0;
            wdata = g0;
            if(ByteEn[3]) wdata[31:24] = Din[31:24];
            if(ByteEn[2]) wdata[23:16] = Din[23:16];
            if(ByteEn[1]) wdata[15:8] = Din[15:8];
            if(ByteEn[0]) wdata[7:0] = Din[7:0];
        end else if((Addr>>2) == (32'h7f54>>2)) begin
            Dout = {28'b0, g1};
            wdata = {28'b0, g1};
            if(ByteEn[0]) wdata[3:0] = Din[3:0];
        end else begin
            Dout = 0;
            wdata = 0;
        end
    end

    localparam PERIOD = 32'd25000;
    reg [31:0] counter;
    reg [1:0] select;
    always@(posedge clk) begin
        if(rst) begin
            counter <= 0;
            select <= 0;
        end else begin
            if(counter + 1 >= PERIOD) begin
                counter <= 0;
                select <= select + 2'b1;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    assign sel0 = 4'b1 << select;
    assign seg0 = hex2dig(g0[((select<<2)+5'd0) +: 4]);
    assign sel1 = 4'b1 << select;
    assign seg1 = hex2dig(g0[((select<<2)+5'd16) +: 4]);
    assign sel2 = 1;
    assign seg2 = hex2dig(g1);

    function [7:0] hex2dig;
        input [3:0] hex;
        begin
            case (hex)
            4'h0    : hex2dig = 8'b1000_0001;   // not G
            4'h1    : hex2dig = 8'b1100_1111;   // B, C
            4'h2    : hex2dig = 8'b1001_0010;   // not C, F
            4'h3    : hex2dig = 8'b1000_0110;   // not E, F
            4'h4    : hex2dig = 8'b1100_1100;   // not A, D, E
            4'h5    : hex2dig = 8'b1010_0100;   // not B, E
            4'h6    : hex2dig = 8'b1010_0000;   // not B
            4'h7    : hex2dig = 8'b1000_1111;   // A, B, C
            4'h8    : hex2dig = 8'b1000_0000;   // All
            4'h9    : hex2dig = 8'b1000_0100;   // not E
            4'hA    : hex2dig = 8'b1000_1000;   // not D
            4'hB    : hex2dig = 8'b1110_0000;   // not A, B
            4'hC    : hex2dig = 8'b1011_0001;   // A, D, E, F
            4'hD    : hex2dig = 8'b1100_0010;   // not A, F
            4'hE    : hex2dig = 8'b1011_0000;   // not B, C
            4'hF    : hex2dig = 8'b1011_1000;   // A, E, F, G
            default : hex2dig = 8'b1111_1111;
            endcase
        end
    endfunction

endmodule
