`timescale 1ns / 1ps

module IM(
    input [15:2] A, //Address ! Word-Select
    output [31:0] D //Data to read out
    );

    reg [31:0] rom [0:4095];
    
    initial $readmemh("code.txt", rom); 
    
    assign D = rom[A - 14'h0C00]; //offset (0x00003000 >> 2)

endmodule
