`timescale 1ns / 1ps
`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11

module counting(
    input [1:0] num,
    input clk,
    output ans
    );

    reg [1:0] status;
    initial status=`S0;
    assign ans = status==`S3?1:0;

    always @(posedge clk) begin
        case(status)
            `S0: case(num)
                2'd1: status <= `S1;
                default: status <= `S0;
            endcase
            `S1: case(num)
                2'd1: status <= `S1;
                2'd2: status <= `S2;
                default: status <= `S0;
            endcase
            `S2: case(num)
                2'd1: status <= `S1;
                2'd2: status <= `S2;
                2'd3: status <= `S3;
                default: status <= `S0;
            endcase
            `S3: case(num)
                2'd1: status <= `S1;
                2'd2: status <= `S0;
                2'd3: status <= `S3;
                default: status <= `S0;
            endcase
        endcase
    end

endmodule
