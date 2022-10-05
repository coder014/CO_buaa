`timescale 1ns / 1ps

module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
    );
    
    integer count,count_tmp;
    reg [3:0] status;
    reg [2:0] check; // 3'b000:none  3'b001:"begin" 3'b101:reset "begin" 3'b010:"end" 3'b110:reset "end"
    wire [7:0] char;
    assign char = in | 8'd32;
    assign result = count_tmp==1;
    
    initial begin
        count=1;
        count_tmp=1;
        status=0;
    end
    
    always @(*) begin
        if(status==4 && char=="n") check = 3'b001;
        else if(status==5 && char!=" ") check = 3'b101;
        else if(status==7 && char=="d") check = 3'b010;
        else if(status==8 && char!=" ") check = 3'b110;
        else check = 3'b000;
    end
    
    always @(posedge clk or posedge reset)
    if(reset) begin
        count <= 1;
        count_tmp <= 1;
        status <= 0;
    end else begin
        if(count>0) begin
            if(check==3'b001 || check==3'b110) count_tmp <= count_tmp + 1;
            else if(check==3'b101 || check==3'b010) count_tmp <= count_tmp - 1;
            else if(check==3'b000) count <= count_tmp;
        end

        case(status)
            0:begin
                if(char=="b") status <= 1;
                else if(char=="e") status <= 6;
                else if(char!=" ") status <= 9;
            end
            1:begin
                if(char=="e") status <= 2;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            2:begin
                if(char=="g") status <= 3;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            3:begin
                if(char=="i") status <= 4;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            4:begin
                if(char=="n") status <= 5;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            5:begin
                if(char==" ") status <= 0;
                else status <= 9;
            end
            6:begin
                if(char=="n") status <= 7;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            7:begin
                if(char=="d") status <= 8;
                else if(char==" ") status <= 0;
                else status <= 9;
            end
            8:begin
                if(char==" ") status <= 0;
                else status <= 9;
            end
            9:begin
                if(char==" ") status <= 0;
            end
        endcase
    end

endmodule
