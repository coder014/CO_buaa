`timescale 1ns / 1ps

module GRF(
    input clk,
    input WE, //Write Enable signal
    input rst, //! Sync reset
    input [4:0] A1, //Read Address 1
    input [4:0] A2, //Read Address 2
    input [4:0] A3, //Write Address
    input [31:0] WD, //Write Data
    input [31:0] PC8, //Test use: pc addr
    output reg [31:0] RD1, //Read Data 1
    output reg [31:0] RD2 //Read Data 2
    );
    
    reg [31:0] RF [1:31]; //Registers

    generate
        genvar i;
        for(i=1;i<32;i=i+1) begin: gen_regs
            always@(posedge clk) begin
                if(rst) RF[i] <= 0;
                else if(WE) begin
                    if(i==A3) RF[i] <= WD;
                end
            end
        end
    endgenerate
    
    always@(posedge clk) begin
        if(!rst && WE) $display("%d@%h: $%d <= %h", $time, PC8-8, A3, WD);
    end
    
    //!!!!!Use internal forwarding!!!!!
    always@(*) begin
        if(A1==0) RD1 = 0;
        else if(WE && A1==A3) RD1 = WD;
        else RD1 = RF[A1];
        
        if(A2==0) RD2 = 0;
        else if(WE && A2==A3) RD2 = WD;
        else RD2 = RF[A2];
    end

endmodule
