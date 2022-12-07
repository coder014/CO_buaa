`timescale 1ns / 1ps

module GPIO(
    input clk,
    input rst,

    input [7:0] ds0,
    input [7:0] ds1,
    input [7:0] ds2,
    input [7:0] ds3,
    input [7:0] ds4,
    input [7:0] ds5,
    input [7:0] ds6,
    input [7:0] ds7,
    input [7:0] key,
    output reg [31:0] led,
    //output ds_irq,
    //output key_irq,
    
    input [31:0] Addr,
    input [3:0] ByteEn,
    input [31:0] Din,
    output reg [31:0] Dout
    );
    
    reg [31:0] wdata;
    
    always@(posedge clk) begin
        if(rst) begin
            led <= 0;
        end else begin
            if((|ByteEn) && ((Addr>>2) == (32'h7f70>>2))) led <= wdata;
        end
    end

    always@(*) begin
        if((Addr>>2) == (32'h7f60>>2)) Dout = {ds3, ds2, ds1, ds0};
        else if((Addr>>2) == (32'h7f64>>2)) Dout = {ds7, ds6, ds5, ds4};
        else if((Addr>>2) == (32'h7f68>>2)) Dout = {24'b0, key};
        else if((Addr>>2) == (32'h7f70>>2)) Dout = led;
        else Dout = 0;
        
        wdata = led;
        if(ByteEn[3]) wdata[31:24] = Din[31:24];
        if(ByteEn[2]) wdata[23:16] = Din[23:16];
        if(ByteEn[1]) wdata[15:8] = Din[15:8];
        if(ByteEn[0]) wdata[7:0] = Din[7:0];
    end

endmodule
