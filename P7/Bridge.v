`timescale 1ns / 1ps
`include "const.v"

module Bridge(
    input [31:0] data_addr,
    input [31:0] data_wdata,
    input data_mem_write,
    input [2:0] data_sel,
    input data_req,
    output [31:0] data_rdata, 
    output reg [4:0] data_exc,

    output [31:0] IntAddr,
    output [3:0] IntByteen,

    output [31:0] DMAddr,
    input  [31:0] DMRdata,
    output [31:0] DMWdata,
    output [3:0] DMByteen,

    output [31:2] TC0Addr,
    output TC0WE,
    output [31:0] TC0Din,
    input [31:0] TC0Dout,

    output [31:2] TC1Addr,
    output TC1WE,
    output [31:0] TC1Din,
    input [31:0] TC1Dout
    );
    
    wire [3:0] byteen;
    wire [31:0] wdata;
    reg [31:0] rdata;
    wire use_int = data_addr>=32'h0000_7f20 && data_addr<=32'h0000_7f23;
    wire use_dm = data_addr>=32'h0000_0000 && data_addr<=32'h0000_2fff;
    wire use_tc0 = data_addr>=32'h0000_7f00 && data_addr<=32'h0000_7f0b;
    wire use_tc1 = data_addr>=32'h0000_7f10 && data_addr<=32'h0000_7f1b;
    
    assign IntAddr = data_addr;
    assign DMAddr = data_addr;
    assign TC0Addr = data_addr[31:2];
    assign TC1Addr = data_addr[31:2];
    assign IntByteen = use_int ? byteen : 4'b0;
    assign DMByteen = use_dm ? byteen : 4'b0;
    assign TC0WE = use_tc0 ? (|byteen) : 1'b0;
    assign TC1WE = use_tc1 ? (|byteen) : 1'b0;
    assign DMWdata = wdata;
    assign TC0Din = wdata;
    assign TC1Din = wdata;
    
    always@(*) begin
        if(data_mem_write && data_sel==`MEM_STORE_WORD) begin //sw
            if(|(data_addr[1:0])) data_exc = `EXCCODE_ADES; //not aligned
            else if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_tc0 && data_addr==32'h0000_7f08) data_exc = `EXCCODE_ADES;//write Count of TC0
            else if(use_tc1 && data_addr==32'h0000_7f18) data_exc = `EXCCODE_ADES;//write Count of TC1
            else data_exc = 0;
        end else if(data_mem_write && data_sel==`MEM_STORE_HALF) begin //sh
            if(data_addr[0]) data_exc = `EXCCODE_ADES; //not aligned
            else if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_tc0 || use_tc1) data_exc = `EXCCODE_ADES;//write Timer not using sw
            else data_exc = 0;
        end else if(data_mem_write && data_sel==`MEM_STORE_BYTE) begin //sb
            if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADES;//out of range
            else if(use_tc0 || use_tc1) data_exc = `EXCCODE_ADES;//write Timer not using sw
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_WORD) begin //lw
            if(|(data_addr[1:0])) data_exc = `EXCCODE_ADEL; //not aligned
            else if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADEL;//out of range
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_HALF) begin //lh
            if(data_addr[0]) data_exc = `EXCCODE_ADEL; //not aligned
            else if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADEL;//out of range
            else if(use_tc0 || use_tc1) data_exc = `EXCCODE_ADEL;//read Timer not using lw
            else data_exc = 0;
        end else if(data_sel==`MEM_LOAD_BYTE) begin //lb
            if(!(use_int||use_dm||use_tc0||use_tc1)) data_exc = `EXCCODE_ADEL;//out of range
            else if(use_tc0 || use_tc1) data_exc = `EXCCODE_ADEL;//read Timer not using lw
            else data_exc = 0;
        end else begin //no mem operation
            data_exc = 0;
        end
    end
    
    always@(*) begin
        if(use_dm) rdata = DMRdata;
        else if(use_tc0) rdata = TC0Dout;
        else if(use_tc1) rdata = TC1Dout;
        else if(use_int) rdata = 0; //Currently has not been confirmed
        else rdata = 0;
    end

    ByteEn BE(
        .MemWrite(!data_req && data_mem_write), 
        .sel(data_sel), 
        .AddrLow(data_addr[1:0]), 
        .RawData(data_wdata), 
        .En(byteen), 
        .ParsedData(wdata)
    );
    
    MemDataExt MDE(
        .sel(data_sel), 
        .AddrLow(data_addr[1:0]), 
        .RawData(rdata), 
        .ParsedData(data_rdata)
    );

endmodule
