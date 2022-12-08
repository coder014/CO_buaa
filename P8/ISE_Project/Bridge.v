`timescale 1ns / 1ps
`include "const.v"

module Bridge(
    input clk,
    input rst,

    input [31:0] data_addr,
    input [31:0] data_wdata,
    input data_mem_write,
    input [2:0] data_sel,
    input data_req,
    output [31:0] data_rdata, 
    output reg [4:0] data_exc,

    output [31:0] DMAddr,
    input  [31:0] DMRdata,
    output [31:0] DMWdata,
    output [3:0] DMByteen,

    output [31:2] TC0Addr,
    output TC0WE,
    output [31:0] TC0Din,
    input [31:0] TC0Dout,
    
    output [31:0] GPIOAddr,
    output [3:0] GPIOBE,
    output [31:0] GPIODin,
    input [31:0] GPIODout,
    
    output [31:0] TubeAddr,
    output [3:0] TubeBE,
    output [31:0] TubeDin,
    input [31:0] TubeDout,
    
    output [31:0] UARTAddr,
    output UARTWE,
    output [31:0] UARTDin,
    input [31:0] UARTDout
    );
    
    wire [3:0] byteen;
    wire [31:0] wdata;
    reg [31:0] rdata;
    wire use_dm = data_addr>=32'h0000_0000 && data_addr<=32'h0000_2fff;
    wire use_tc0 = data_addr>=32'h0000_7f00 && data_addr<=32'h0000_7f0b;
    wire use_gpio = (data_addr>=32'h0000_7f60 && data_addr<=32'h0000_7f6b)
                    || (data_addr>=32'h0000_7f70 && data_addr<=32'h0000_7f73);
    wire use_tube = data_addr>=32'h0000_7f50 && data_addr<=32'h0000_7f57;
    wire use_uart = data_addr>=32'h0000_7f30 && data_addr<=32'h0000_7f3f;
    
    assign DMAddr = data_addr;
    assign TC0Addr = data_addr[31:2];
    assign GPIOAddr = data_addr;
    assign TubeAddr = data_addr;
    assign UARTAddr = ((data_sel==`MEM_STORE_WORD)||(data_sel==`MEM_LOAD_WORD)) ? data_addr : 0;
    assign DMByteen = use_dm ? byteen : 4'b0;
    assign TC0WE = use_tc0 ? (|byteen) : 1'b0;
    assign GPIOBE = use_gpio ? byteen : 4'b0;
    assign TubeBE = use_tube ? byteen : 4'b0;
    assign UARTWE = use_uart ? (|byteen) : 1'b0;
    assign DMWdata = wdata;
    assign TC0Din = wdata;
    assign GPIODin = wdata;
    assign TubeDin = wdata;
    assign UARTDin = wdata;
    
    always@(*) begin
        if(data_mem_write && data_sel==`MEM_STORE_WORD) begin //sw
            if(|(data_addr[1:0])) data_exc = `EXCCODE_ADES; //not aligned
            else if(!(use_dm||use_tc0||use_gpio||use_tube||use_uart)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_tc0 && data_addr==32'h0000_7f08) data_exc = `EXCCODE_ADES;//write Count of TC0
            else if(use_gpio && data_addr<32'h0000_7f70) data_exc = `EXCCODE_ADES;//write read-only of GPIO
            else if(use_uart && data_addr==32'h0000_7f34) data_exc = `EXCCODE_ADES;//write read-only of UART
            else data_exc = 0;
        end else if(data_mem_write && data_sel==`MEM_STORE_HALF) begin //sh
            if(data_addr[0]) data_exc = `EXCCODE_ADES; //not aligned
            else if(!(use_dm||use_gpio||use_tube)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_gpio && data_addr<32'h0000_7f70) data_exc = `EXCCODE_ADES;//write read-only of GPIO
            else data_exc = 0;
        end else if(data_mem_write && data_sel==`MEM_STORE_BYTE) begin //sb
            if(!(use_dm||use_gpio||use_tube)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_gpio && data_addr<32'h0000_7f70) data_exc = `EXCCODE_ADES;//write read-only of GPIO
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_WORD) begin //lw
            if(|(data_addr[1:0])) data_exc = `EXCCODE_ADEL; //not aligned
            else if(!(use_dm||use_tc0||use_gpio||use_tube||use_uart)) data_exc = `EXCCODE_ADEL;//out of range
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_HALF) begin //lh
            if(data_addr[0]) data_exc = `EXCCODE_ADEL; //not aligned
            else if(!(use_dm||use_gpio||use_tube)) data_exc = `EXCCODE_ADEL;//out of range
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_BYTE) begin //lb
            if(!(use_dm||use_gpio||use_tube)) data_exc = `EXCCODE_ADEL;//out of range
            else data_exc = 0;
        end else begin //no mem operation
            data_exc = 0;
        end
    end
    
    //除内存外均加一级寄存器，解决内存同步读问题
    reg is_mem;
    reg [1:0] data_addr_final;
    reg [2:0] data_sel_final;
    always@(posedge clk) begin
        if(rst) begin
            rdata <= 0;
            is_mem <= 0;
            data_addr_final <= 0;
            data_sel_final <= 0;
        end else begin
            is_mem <= use_dm;
            data_addr_final <= data_addr[1:0];
            data_sel_final <= data_sel;
            if(use_tc0) rdata <= TC0Dout;
            else if(use_gpio) rdata <= GPIODout;
            else if(use_tube) rdata <= TubeDout;
            else if(use_uart) rdata <= UARTDout;
            else rdata <= 0;
        end
    end
    wire [31:0] rdata_final = is_mem ? DMRdata : rdata ;

    ByteEn BE(
        .MemWrite(!data_req && data_mem_write), 
        .sel(data_sel), 
        .AddrLow(data_addr[1:0]), 
        .RawData(data_wdata), 
        .En(byteen), 
        .ParsedData(wdata)
    );
    
    MemDataExt MDE(
        .sel(data_sel_final), 
        .AddrLow(data_addr_final), 
        .RawData(rdata_final), 
        .ParsedData(data_rdata)
    );

endmodule
