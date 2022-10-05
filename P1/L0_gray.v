`timescale 1ns / 1ps

module gray(
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output reg Overflow
    );
    reg [2:0] counter;

    assign Output = {counter[2],counter[2]^counter[1],counter[1]^counter[0]};
    
    initial begin
        counter = 0;
        Overflow = 0;
    end
    
    always @(posedge Clk) begin
        if(Reset) begin
            counter <= 0;
            Overflow <= 0;
        end else if(En) begin
            if(counter==3'b111) Overflow <= 1;
            counter <= counter + 3'b1;
        end
    end

endmodule
