`timescale 1ns / 1ps

module IM(
    input [13:2] A, //Address ! Word-Select
    output [31:0] D //Data to read out
    );

    reg [31:0] rom [0:4095];
    
    initial $readmemh("code.txt", rom, 32'h3000 >> 2); //Start at 0x00003000
    
    assign D = rom[A];

endmodule
