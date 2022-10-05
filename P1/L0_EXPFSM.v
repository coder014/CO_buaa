`timescale 1ns / 1ps

module string(
    input clk,
    input clr,
    input [7:0] in,
    output out
    );
    
    reg [1:0] status;
    
    initial status = 0;
    
    assign out = status==1;
    
    always @(posedge clk or posedge clr) begin
        if(clr) status <= 0;
        else case(status)
            0: begin
                if(isNum(in)) status <= 1;
                else status <= 3;
            end
            1: begin
                if(isOp(in)) status <= 2;
                else status <= 3;
            end
            2: begin
                if(isNum(in)) status <= 1;
                else status <= 3;
            end
            default:;
        endcase
    end


    function isNum;
        input [7:0] c;
        begin
            isNum = (c>="0" && c<="9");
        end
    endfunction
    function isOp;
        input [7:0] c;
        begin
            isOp = (c=="*" || c=="+");
        end
    endfunction

endmodule
