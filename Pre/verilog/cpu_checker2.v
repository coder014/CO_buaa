`timescale 1ns / 1ps

module cpu_checker(
    input clk,
    input reset,
    input [7:0] char,
    input [15:0] freq,
    output [1:0] format_type,
    output [3:0] error_code
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
    localparam err_time = 4'b0001,
               err_pc = 4'b0010,
               err_addr = 4'b0100,
               err_grf = 4'b1000;

    reg [1:0] type;
    reg [3:0] status,ctr,code;
    reg [31:0] tmp;

    initial begin
        status=0;
        type=0;
        ctr=0;
        code=0;
    end

    assign format_type = status==S_sharp ? type : 2'b00;
    assign error_code = status==S_sharp ? code : 4'b0000;

    always @(posedge clk) begin
        if(reset) begin
            status <= 0;
            type <= 0;
            ctr <= 0;
            code <= 0;
        end else begin
            case(status)
                S_0: if(char=="^") status <= S_caret;
                S_caret: begin
                    if(isNum(char)) begin
                        status <= S_time;
                        ctr <= 1;
                        tmp <= getNum(char);
                    end else SyncReset();
                end
                S_time: begin
                    if(char=="@") begin
                        status <= S_at;
                        if((tmp&((freq>>1)-1)) != 0) code <= code|err_time;
                    end else if(isNum(char) && ctr<=3) begin
                        ctr <= ctr+1;
                        tmp <= (tmp<<3)+(tmp<<1)+getNum(char);
                    end else SyncReset();
                end
                S_at: begin
                    if(isHex(char)) begin
                        status <= S_pc;
                        ctr <= 1;
                        tmp <= getNum(char);
                    end else SyncReset();
                end
                S_pc: begin
                    if(char==":" && ctr==8) begin
                        status <= S_comma;
                        if(!(tmp>=32'h3000 && tmp<=32'h4fff && tmp[1:0]==2'b00)) code <= code|err_pc;
                    end else if(isHex(char) && ctr<=7) begin
                        ctr <= ctr+1;
                        tmp <= (tmp<<4)|getNum(char);
                    end else SyncReset();
                end
                S_comma: begin
                    if(char=="$") begin
                        status <= S_prefix;
                        type <= T_reg;
                    end else if(char==8'd42) begin //ascii number of star symbol
                        status <= S_prefix;
                        type <= T_data;
                    end else if(char!=" ") SyncReset();
                end
                S_prefix: begin
                    if(type==T_reg) begin
                        if(isNum(char)) begin
                            status <= S_num;
                            ctr <= 1;
                            tmp <= getNum(char);
                        end else SyncReset();
                    end else begin
                        if(isHex(char)) begin
                            status <= S_num;
                            ctr <= 1;
                            tmp <= getNum(char);
                        end else SyncReset();
                    end
                end
                S_num: begin
                    if(type==T_reg) begin
                        if(char=="<") begin
                            status <= S_le;
                            if(tmp>31) code <= code|err_grf;
                        end else if(char==" ") begin
                            status <= S_blank;
                            if(tmp>31) code <= code|err_grf;
                        end else if(isNum(char) && ctr<=3) begin
                            ctr <= ctr+1;
                            tmp <= (tmp<<3)+(tmp<<1)+getNum(char);
                        end else SyncReset();
                    end else begin
                        if(char=="<" && ctr==8) begin
                            status <= S_le;
                            if(!(tmp<=32'h2fff && tmp[1:0]==2'b00)) code <= code|err_addr;
                        end else if(char==" " && ctr==8) begin
                            status <= S_blank;
                            if(!(tmp<=32'h2fff && tmp[1:0]==2'b00)) code <= code|err_addr;
                        end else if(isHex(char) && ctr<=7) begin
                            ctr <= ctr+1;
                            tmp <= (tmp<<4)|getNum(char);
                        end else SyncReset();
                    end
                end
                S_blank: begin
                    if(char=="<") status <= S_le;
                    else if(char!=" ") SyncReset();
                end
                S_le: begin
                    if(char=="=") status <= S_eq;
                    else SyncReset();
                end
                S_eq: begin
                    if(isHex(char)) begin
                        status <= S_hex;
                        ctr <= 1;
                    end else if(char!=" ") SyncReset();
                end
                S_hex: begin
                    if(char=="#" && ctr==8) status <= S_sharp;
                    else if(isHex(char) && ctr<=7) ctr <= ctr+1;
                    else SyncReset();
                end
                S_sharp: begin
                    if(char=="^") begin
                        status <= S_caret;
                        code <= 0;
                    end else SyncReset();
                end
            endcase
        end
    end

    task SyncReset;
        begin
            status <= S_0;
            code <= 0;
        end
    endtask
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
    function [3:0] getNum;
        input [7:0] c;
        begin
            if(isNum(c)) getNum = c-"0";
            else getNum = c-"a"+10;
        end
    endfunction
endmodule
