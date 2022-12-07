//`default_nettype none
`timescale 1ns / 1ps

module mips(
    input clk,
    input reset,
    input [31:0] i_inst_rdata, //Instruction get from external IM
    output [31:0] i_inst_addr, //PC address send to external IM
    input [31:0] m_data_rdata, //Data get from external memory
    output [31:0] m_data_addr, //Data address send to external memory
    output [31:0] m_data_wdata, //Data send to external memory
    output [3:0] m_data_byteen, //Byte enable signal send to external memory
    output [31:0] m_inst_addr, //PC address send out for debug output
    output w_grf_we, //GRF write enable signal send out for debug output
    output [4:0] w_grf_addr, //GRF write reg number send out for debug output
    output [31:0] w_grf_wdata, //GRF write reg data send out for debug output
    output [31:0] w_inst_addr //PC address send out for debug output
    );

    //===================Stage F(Fetch)===================
    wire npc_sel, stall_F;
    wire [31:0] npc_imm, pc4_F;
    IFU IFU(
        .clk(clk), 
        .rst(reset), 
        .sel(npc_sel), 
        .imm(npc_imm), 
        .stall(stall_F),
        .PC(i_inst_addr),
        .PC_4(pc4_F)
    );
    
    //===================Stage D(Decode)===================
    wire stall_D;
    wire [31:0] ins_D, pc4_D;
    StageD StageD(
        .clk(clk), 
        .rst(reset), 
        .stall(stall_D), 
        .instr_in(i_inst_rdata), 
        .pc_in(pc4_F), 
        .instr_out(ins_D), 
        .pc_out(pc4_D)
    );
    wire reg_write_D, mem_write_D, reg_dst_D, mem_to_reg_D, alu_src_D, link_D;
    wire [3:0] jump_type, alu_ctr_D;
    wire [1:0] rs_usage, rt_usage;
    wire move_from_mdu_D, move_to_mdu_D, start_mdu_D;
    wire [2:0] mdu_sel_D, mem_sel_D;
    Decoder Decoder(
        .opcode(ins_D[31:26]), 
        .funct(ins_D[5:0]), 
        .RegWrite(reg_write_D), 
        .MemWrite(mem_write_D), 
        .JType(jump_type), 
        .RegDst(reg_dst_D), 
        .MemToReg(mem_to_reg_D), 
        .ALUCtr(alu_ctr_D), 
        .ALUSrc(alu_src_D), 
        .Link(link_D), 
        .MoveFromMDU(move_from_mdu_D),
        .MoveToMDU(move_to_mdu_D),
        .StartMDU(start_mdu_D),
        .MDUSel(mdu_sel_D),
        .MemSel(mem_sel_D),
        .RsUsage(rs_usage), 
        .RtUsage(rt_usage)
    );
    wire [4:0] rs_D = ins_D[25:21];
    wire [4:0] rt_D = ins_D[20:16];
    wire [31:0] data1_D, data2_D;
    wire [31:0] pc8_W, result_W;
    wire [4:0] reg_addr_W;
    wire reg_write_W;
    assign w_grf_we = reg_write_W;
    assign w_grf_addr = reg_addr_W;
    assign w_grf_wdata = result_W;
    assign w_inst_addr = pc8_W - 8;
    GRF GRF(
        .clk(clk), 
        .WE(reg_write_W), 
        .rst(reset), 
        .A1(rs_D), 
        .A2(rt_D), 
        .A3(reg_addr_W), 
        .WD(result_W), 
        .RD1(data1_D), 
        .RD2(data2_D)
    );
    wire [31:0] sign_imm_D = $signed(ins_D[15:0]);
    wire [31:0] data1_with_fw, data2_with_fw;
    wire forward_a_D, forward_b_D;
    wire [31:0] alu_out_M;
    mux2 #(32) Mux_FW_data1_D(.sel(forward_a_D), .in0(data1_D), .in1(alu_out_M), .out(data1_with_fw));
    mux2 #(32) Mux_FW_data2_D(.sel(forward_b_D), .in0(data2_D), .in1(alu_out_M), .out(data2_with_fw));
    NpcController NpcController(
        .op(jump_type), 
        .pc4(pc4_D), 
        .data1(data1_with_fw), 
        .data2(data2_with_fw), 
        .imm26(ins_D[25:0]), 
        .imm32(sign_imm_D), 
        .out(npc_imm), 
        .sel(npc_sel)
    );
    
    //===================Stage E(Execute)===================
    wire flush_E;
    wire reg_write_E, mem_write_E, reg_dst_E, mem_to_reg_E, alu_src_E, link_E;
    wire [3:0] alu_ctr_E;
    wire [31:0] data1_E, data2_E, sign_imm_E, pc8_E;
    wire [4:0] rs_E, rt_E, rd_E;
    wire move_from_mdu_E, move_to_mdu_E, start_mdu_E;
    wire [2:0] mdu_sel_E, mem_sel_E;
    StageE StageE(
        .clk(clk), 
        .rst(reset), 
        .flush(flush_E), 
        .RegWrite_in(reg_write_D), 
        .MemWrite_in(mem_write_D), 
        .RegDst_in(reg_dst_D), 
        .MemToReg_in(mem_to_reg_D), 
        .ALUCtr_in(alu_ctr_D), 
        .ALUSrc_in(alu_src_D), 
        .Link_in(link_D), 
        .data1_in(data1_D), 
        .data2_in(data2_D), 
        .rs_in(rs_D), 
        .rt_in(rt_D), 
        .rd_in(ins_D[15:11]), 
        .imm_in(sign_imm_D), 
        .pc_in(pc4_D + 4), // use pc+8 starting from E
        .MoveFromMDU_in(move_from_mdu_D),
        .MoveToMDU_in(move_to_mdu_D),
        .StartMDU_in(start_mdu_D),
        .MDUSel_in(mdu_sel_D),
        .MemSel_in(mem_sel_D),
        .RegWrite_out(reg_write_E), 
        .MemWrite_out(mem_write_E), 
        .RegDst_out(reg_dst_E), 
        .MemToReg_out(mem_to_reg_E), 
        .ALUCtr_out(alu_ctr_E), 
        .ALUSrc_out(alu_src_E), 
        .Link_out(link_E), 
        .data1_out(data1_E), 
        .data2_out(data2_E), 
        .rs_out(rs_E), 
        .rt_out(rt_E), 
        .rd_out(rd_E), 
        .imm_out(sign_imm_E), 
        .pc_out(pc8_E),
        .MoveFromMDU_out(move_from_mdu_E),
        .MoveToMDU_out(move_to_mdu_E),
        .StartMDU_out(start_mdu_E),
        .MDUSel_out(mdu_sel_E),
        .MemSel_out(mem_sel_E)
    );
    wire [1:0] forward_a_E, forward_b_E;
    wire [31:0] alu_data_a, alu_data_b, write_data_E;
    mux4 #(32) Mux_FW_data1_E(.sel(forward_a_E), .in0(data1_E), .in1(result_W), .in2(alu_out_M), .out(alu_data_a));
    mux4 #(32) Mux_FW_data2_E(.sel(forward_b_E), .in0(data2_E), .in1(result_W), .in2(alu_out_M), .out(write_data_E));
    mux2 #(32) Mux_SEL_alu_datab(.sel(alu_src_E), .in0(write_data_E), .in1(sign_imm_E), .out(alu_data_b));
    wire [31:0] alu_ans, alu_out1_E, alu_out2_E, mdu_out_E;
    wire mdu_busy_E;
    ALU ALU(
        .A(alu_data_a), 
        .B(alu_data_b), 
        .op(alu_ctr_E), 
        .C(alu_ans)
    );
    MulDiv MDU(
        .clk(clk), 
        .rst(reset), 
        .start(start_mdu_E), 
        .WE(move_to_mdu_E), 
        .sel(mdu_sel_E), 
        .A(alu_data_a), 
        .B(write_data_E), 
        .busy(mdu_busy_E), 
        .C(mdu_out_E)
    );
    mux2 #(32) Mux_SEL_alu_out1(.sel(link_E), .in0(alu_ans), .in1(pc8_E), .out(alu_out1_E));
    mux2 #(32) Mux_SEL_alu_out2(.sel(move_from_mdu_E), .in0(alu_out1_E), .in1(mdu_out_E), .out(alu_out2_E));
    wire [4:0] const_ra_addr = 5'd31;
    wire [4:0] reg_addr_tmp, reg_addr_E;
    mux2 #(5) Mux_SEL_reg_addr_1(.sel(reg_dst_E), .in0(rt_E), .in1(rd_E), .out(reg_addr_tmp));
    mux2 #(5) Mux_SEL_reg_addr_2(.sel(link_E), .in0(reg_addr_tmp), .in1(const_ra_addr), .out(reg_addr_E));
        
    //===================Stage M(Memory)===================
    wire reg_write_M, mem_write_M, mem_to_reg_M;
    wire [31:0] write_data_M, pc8_M;
    wire [4:0] reg_addr_M, rt_M;
    wire [2:0] mem_sel_M;
    StageM StageM(
        .clk(clk), 
        .rst(reset), 
        .RegWrite_in(reg_write_E), 
        .MemWrite_in(mem_write_E), 
        .MemToReg_in(mem_to_reg_E), 
        .ALUOut_in(alu_out2_E), 
        .WriteData_in(write_data_E), 
        .RegAddr_in(reg_addr_E), 
        .pc_in(pc8_E), 
        .rt_in(rt_E),
        .MemSel_in(mem_sel_E),
        .rt_out(rt_M),
        .RegWrite_out(reg_write_M), 
        .MemWrite_out(mem_write_M), 
        .MemToReg_out(mem_to_reg_M), 
        .ALUOut_out(alu_out_M), 
        .WriteData_out(write_data_M), 
        .RegAddr_out(reg_addr_M), 
        .pc_out(pc8_M),
        .MemSel_out(mem_sel_M)
    );
    wire [31:0] read_data_M, write_data_with_fw;
    wire forward_M;
    mux2 #(32) Mux_FW_write_data_M(.sel(forward_M), .in0(write_data_M), .in1(result_W), .out(write_data_with_fw));
    ByteEn BE(
        .MemWrite(mem_write_M), 
        .sel(mem_sel_M), 
        .AddrLow(alu_out_M[1:0]),
        .RawData(write_data_with_fw),
        .En(m_data_byteen),
        .ParsedData(m_data_wdata)
    );
    assign m_inst_addr = pc8_M - 8;
    assign m_data_addr = alu_out_M;
    MemDataExt MDE(
        .sel(mem_sel_M), 
        .AddrLow(alu_out_M[1:0]), 
        .RawData(m_data_rdata), 
        .ParsedData(read_data_M)
    );
    /*DM DM(
        .clk(clk), 
        .rst(reset), 
        .str(mem_write_M), 
        .A(alu_out_M[13:2]), 
        .D(write_data_with_fw), 
        .pc8(pc8_M), 
        .RD(read_data_M)
    );*/
            
    //===================Stage W(Write back)===================
    wire mem_to_reg_W;
    wire [31:0] alu_out_W, read_data_W;
    StageW StageW(
        .clk(clk), 
        .rst(reset), 
        .RegWrite_in(reg_write_M), 
        .MemToReg_in(mem_to_reg_M), 
        .ALUOut_in(alu_out_M), 
        .ReadData_in(read_data_M), 
        .RegAddr_in(reg_addr_M), 
        .pc_in(pc8_M), 
        .RegWrite_out(reg_write_W), 
        .MemToReg_out(mem_to_reg_W), 
        .ALUOut_out(alu_out_W), 
        .ReadData_out(read_data_W), 
        .RegAddr_out(reg_addr_W), 
        .pc_out(pc8_W)
    );
    mux2 #(32) Mux_SEL_write_result(.sel(mem_to_reg_W), .in0(alu_out_W), .in1(read_data_W), .out(result_W));
    
    //===================Conflict handle===================
    ConflictController ConflictController(
        .RsD(rs_D), 
        .RtD(rt_D), 
        .RsE(rs_E), 
        .RtE(rt_E), 
        .RtM(rt_M),
        .RegAddrE(reg_addr_E), 
        .RegAddrM(reg_addr_M), 
        .RegAddrW(reg_addr_W), 
        .RsUsageD(rs_usage), 
        .RtUsageD(rt_usage), 
        .MemToRegE(mem_to_reg_E), 
        .RegWriteE(reg_write_E), 
        .MemToRegM(mem_to_reg_M), 
        .RegWriteM(reg_write_M), 
        .RegWriteW(reg_write_W), 
        .MoveFromMDUD(move_from_mdu_D),
        .StartMDUE(start_mdu_E),
        .MDUBusyE(mdu_busy_E),
        .MoveToMDUE(move_to_mdu_E),
        .StallD(stall_D), 
        .StallF(stall_F), 
        .FlushE(flush_E), 
        .ForwardAD(forward_a_D), 
        .ForwardBD(forward_b_D), 
        .ForwardAE(forward_a_E), 
        .ForwardBE(forward_b_E),
        .ForwardM(forward_M)
    );

endmodule
