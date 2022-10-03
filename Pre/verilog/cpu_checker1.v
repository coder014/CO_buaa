`timescale 1ns / 1ps

module cpu_checker(
    input clk,
    input reset,
    input [7:0] char,
    output [1:0] format_type
    );

    localparam S_0 = 4'd0,
               S_caret = 4'd1,
               S_time = 4'd2,
               S_at = 4'd3,
               S_pc = 4'd4,
               S_comma = 4'd5,
               S_prefix = 4'd6,
               S_num = 4'd7,
               S_blank = 4'd8,
               S_le = 4'd9,
               S_eq = 4'd10,
               S_hex = 4'd11,
               S_sharp = 4'd12;
    localparam T_reg = 2'b01, T_data = 2'b10;

    reg [1:0] type;
    reg [3:0] status,ctr;

    initial begin
        status=0;
        type=0;
        ctr=0;
    end

    assign format_type = status==S_sharp ? type : 2'b00;

    always @(posedge clk) begin
        if(reset) begin
            status <= 0;
            type <= 0;
            ctr <= 0;
        end else begin
            case(status)
                S_0: if(char=="^") status <= S_caret;
                S_caret: begin
                    if(isNum(char)) begin
                        status <= S_time;
                        ctr <= 1;
                    end else status <= S_0;
                end
                S_time: begin
                    if(char=="@") status <= S_at;
                    else if(isNum(char) && ctr<=3) ctr <= ctr+1;
                    else status <= S_0;
                end
                S_at: begin
                    if(isHex(char)) begin
                        status <= S_pc;
                        ctr <= 1;
                    end else status <= S_0;
                end
                S_pc: begin
                    if(char==":" && ctr==8) status <= S_comma;
                    else if(isHex(char) && ctr<=7) ctr <= ctr+1;
                    else status <= S_0;
                end
                S_comma: begin
                    if(char=="$") begin
                        status <= S_prefix;
                        type <= T_reg;
                    end else if(char=="*") begin
                        status <= S_prefix;
                        type <= T_data;
                    end else if(char!=" ") status <= S_0;
                end
                S_prefix: begin
                    if(type==T_reg) begin
                        if(isNum(char)) begin
                            status <= S_num;
                            ctr <= 1;
                        end else status <= S_0;
                    end else begin
                        if(isHex(char)) begin
                            status <= S_num;
                            ctr <= 1;
                        end else status <= S_0;
                    end
                end
                S_num: begin
                    if(type==T_reg) begin
                        if(char=="<") status <= S_le;
                        else if(char==" ") status <= S_blank;
                        else if(isNum(char) && ctr<=3) ctr <= ctr+1;
                        else status <= S_0;
                    end else begin
                        if(char=="<" && ctr==8) status <= S_le;
                        else if(char==" " && ctr==8) status <= S_blank;
                        else if(isHex(char) && ctr<=7) ctr <= ctr+1;
                        else status <= S_0;
                    end
                end
                S_blank: begin
                    if(char=="<") status <= S_le;
                    else if(char!=" ") status <= S_0;
                end
                S_le: begin
                    if(char=="=") status <= S_eq;
                    else status <= S_0;
                end
                S_eq: begin
                    if(isHex(char)) begin
                        status <= S_hex;
                        ctr <= 1;
                    end else if(char!=" ") status <= S_0;
                end
                S_hex: begin
                    if(char=="#" && ctr==8) status <= S_sharp;
                    else if(isHex(char) && ctr<=7) ctr <= ctr+1;
                    else status <= S_0;
                end
                S_sharp: begin
                    if(char=="^") status <= S_caret;
                    else status <= S_0;
                end
            endcase
        end
    end

    function isNum;
        input [7:0] c;
        begin
            isNum = (c>="0" && c<="9");
        end
    endfunction
    function isHex;
        input [7:0] c;
        begin
            isHex = isNum(c) || (c>="a" && c<="f");
        end
    endfunction
endmodule
