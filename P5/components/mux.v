`timescale 1ns / 1ps

module mux4
#(parameter N=32)(
    input [1:0] sel,
    input [N-1:0] in0,
    input [N-1:0] in1,
    input [N-1:0] in2,
    input [N-1:0] in3,
    output reg [N-1:0] out
    );

    always@(*) begin
        if(sel==2'b00) out = in0;
        else if(sel == 2'b01) out = in1;
        else if(sel == 2'b10) out = in2;
        else out = in3;
    end

endmodule

module mux2
#(parameter N=32)(
    input sel,
    input [N-1:0] in0,
    input [N-1:0] in1,
    output [N-1:0] out
    );

    assign out = sel ? in1 : in0;

endmodule