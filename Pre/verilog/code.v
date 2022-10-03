`timescale 1ns / 1ps

module code(
    input Clk,
    input Reset,
    input Slt,
    input En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
    );

    reg [1:0] tmp;
    initial begin
        tmp=0;
        Output0=0;
        Output1=0;
    end

    always @(posedge Clk) begin
        if(Reset) begin
            Output0 <= 0;
            Output1 <= 0;
            tmp <= 0;
        end else if(En) begin
            if(Slt) begin
                if(tmp==3) begin
                    tmp<=0;
                    Output1 <= Output1+1;
                end else tmp<=tmp+1;
            end else Output0 <= Output0+1;
        end
    end

endmodule
