`timescale 1ns / 1ps

module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
    );

    assign m_inst_addr = macroscopic_pc;
    
    wire [31:0] pr_addr, pr_wdata, pr_rdata;
    wire pr_mem_write, pr_req;
    wire [2:0] pr_sel;
    wire [4:0] pr_exc;
    
    wire [31:2] t0_a, t1_a;
    wire t0_we, t1_we, t0_irq, t1_irq;
    wire [31:0] t0_din, t1_din, t0_dout, t1_dout;
    
    TC T0(
        .clk(clk), 
        .reset(reset), 
        .Addr(t0_a), 
        .WE(t0_we), 
        .Din(t0_din), 
        .Dout(t0_dout), 
        .IRQ(t0_irq)
    );
    TC T1(
        .clk(clk), 
        .reset(reset), 
        .Addr(t1_a), 
        .WE(t1_we), 
        .Din(t1_din), 
        .Dout(t1_dout), 
        .IRQ(t1_irq)
    );

    CPU CPU(
        .clk(clk), 
        .reset(reset), 
        .i_inst_rdata(i_inst_rdata), 
        .i_inst_addr(i_inst_addr), 
        .m_data_rdata(pr_rdata), 
        .m_data_exc(pr_exc), 
        .m_data_addr(pr_addr), 
        .m_data_wdata(pr_wdata), 
        .m_data_mem_write(pr_mem_write), 
        .m_data_sel(pr_sel), 
        .m_data_req(pr_req),
        .macro_addr(macroscopic_pc), 
        .w_grf_we(w_grf_we), 
        .w_grf_addr(w_grf_addr), 
        .w_grf_wdata(w_grf_wdata), 
        .w_inst_addr(w_inst_addr), 
        .hw_int({3'b0, interrupt, t1_irq, t0_irq})
    );
    
    Bridge Bridge(
        .data_addr(pr_addr), 
        .data_wdata(pr_wdata), 
        .data_mem_write(pr_mem_write), 
        .data_sel(pr_sel), 
        .data_req(pr_req), 
        .data_rdata(pr_rdata), 
        .data_exc(pr_exc), 
        .IntAddr(m_int_addr), 
        .IntByteen(m_int_byteen), 
        .DMAddr(m_data_addr), 
        .DMRdata(m_data_rdata), 
        .DMWdata(m_data_wdata), 
        .DMByteen(m_data_byteen), 
        .TC0Addr(t0_a), 
        .TC0WE(t0_we), 
        .TC0Din(t0_din), 
        .TC0Dout(t0_dout), 
        .TC1Addr(t1_a), 
        .TC1WE(t1_we), 
        .TC1Din(t1_din), 
        .TC1Dout(t1_dout)
    );

endmodule
