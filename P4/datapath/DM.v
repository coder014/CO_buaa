`timescale 1ns / 1ps

module DM(
    input clk,
    input rst, //! Sync reset
    input str, //Store data when str is 1
    input [13:2] A, //Address ! Word-Select
    input [31:0] D, //Data to store
    input [31:0] pc, //Test use: pc addr
    output [31:0] RD //Data to read out
    );
    
    reg [31:0] mem [0:3071];
    integer i;

    always@(posedge clk) begin
        if(rst)
            for(i=0;i<3072;i=i+1) mem[i] <= 0;
        else if(str) begin
            mem[A] <= D;
        end
    end
    
    always@(posedge clk) begin
        if(!rst && str) $display("@%h: *%h <= %h", pc, {18'b0,A,2'b0}, D);
    end
    
    assign RD = mem[A];

endmodule
