`timescale 1ns / 1ps

module id_fsm(
    input [7:0] char,
    input clk,
    output out
    );

    localparam S0 = 2'b00, //illegal
               S1 = 2'b01, //has alphas
               S2 = 2'b10; //has nums
    localparam ordA = 8'd65,
               ordZ = 8'd90,
               orda = 8'd97,
               ordz = 8'd122,
               ord0 = 8'd48,
               ord9 = 8'd57;

    reg [1:0] status;
    initial status=S0;

    assign out = status == S2 ? 1 : 0;

    always @(posedge clk) begin
        case(status)
            S0: if(isAlpha(char)) status <= S1;
            S1: begin
                if(isNum(char)) status <= S2;
                else if(!isAlpha(char)) status <= S0;
            end
            S2: begin
                if(isAlpha(char)) status <= S1;
                else if(!isNum(char)) status <= S0;
            end
        endcase
    end

    function isAlpha;
        input [7:0] c;
        begin
            isAlpha = (c>=ordA && c<=ordZ) || (c>=orda && c<=ordz);
        end
    endfunction
    function isNum;
        input [7:0] c;
        begin
            isNum = (c>=ord0 && c<=ord9);
        end
    endfunction
endmodule
