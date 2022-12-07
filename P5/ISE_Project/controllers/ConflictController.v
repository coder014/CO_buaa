`timescale 1ns / 1ps
`include "../const.v"

module ConflictController(
    input [4:0] RsD,
    input [4:0] RtD,
    input [4:0] RsE,
    input [4:0] RtE,
    input [4:0] RtM,
    input [4:0] RegAddrE,
    input [4:0] RegAddrM,
    input [4:0] RegAddrW,
    input [1:0] RsUsageD,
    input [1:0] RtUsageD,
    input MemToRegE,
    input RegWriteE,
    input MemToRegM,
    input RegWriteM,
    input RegWriteW,
    output StallD,
    output StallF,
    output FlushE,
    output reg ForwardAD,
    output reg ForwardBD,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output reg ForwardM
    );

    //=================Forward Check Zone=================
    //When latter instruction in stage E needs the value
    //which former instruction in stage M or W produces,
    //then forward ......
    always@(*) begin
        if ((RsE != 0) && RegWriteM && (RsE == RegAddrM))
            ForwardAE = `E_FW_USE_M;
        else if((RsE != 0) && RegWriteW && (RsE == RegAddrW))
            ForwardAE = `E_FW_USE_W;
        else ForwardAE = `E_FW_USE_S;
        
        if ((RtE != 0) && RegWriteM && (RtE == RegAddrM))
            ForwardBE = `E_FW_USE_M;
        else if((RtE != 0) && RegWriteW && (RtE == RegAddrW))
            ForwardBE = `E_FW_USE_W;
        else ForwardBE = `E_FW_USE_S;
        
        //Special: Jump instructions pre-check forwarding ......
        if ((RsD != 0) && RegWriteM && (RsD == RegAddrM))
            ForwardAD = `D_FW_USE_M;
        else ForwardAD = `D_FW_USE_S;
        
        if ((RtD != 0) && RegWriteM && (RtD == RegAddrM))
            ForwardBD = `D_FW_USE_M;
        else ForwardBD = `D_FW_USE_S;
        
        //Special: store instructions check forwarding ......
        if ((RtM != 0) && RegWriteW && (RtM == RegAddrW))
            ForwardM = `M_FW_USE_W;
        else ForwardM = `M_FW_USE_S;
    end

    //==================Stall Check Zone==================
    //When latter instruction in stage D will need the value
    //which former instruction in stage E hasn't prepared,
    //then stall ......
    reg stall_rs, stall_rt;
    always@(*) begin
        case(RsUsageD)
            `VALUE_USE_NEXT: stall_rs = (RsD != 0) && (RsD == RegAddrE) && MemToRegE && RegWriteE;
            `VALUE_USE_NOW: stall_rs = (RsD != 0) && (((RsD == RegAddrE) && RegWriteE) || ((RsD == RegAddrM) && MemToRegM && RegWriteM));
            default: stall_rs = 0; //`VALUE_USE_NONE
        endcase
        
        case(RtUsageD)
            `VALUE_USE_NEXT: stall_rt = (RtD != 0) && (RtD == RegAddrE) && MemToRegE && RegWriteE;
            `VALUE_USE_NOW: stall_rt = (RtD != 0) && (((RtD == RegAddrE) && RegWriteE) || ((RtD == RegAddrM) && MemToRegM && RegWriteM));
            default: stall_rt = 0; //`VALUE_USE_NONE
        endcase
    end
    assign StallD = stall_rs || stall_rt;
    assign StallF = StallD;
    assign FlushE = StallD;
endmodule
