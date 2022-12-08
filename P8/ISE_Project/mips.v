`timescale 1ns / 1ps

module mips(
    input clk_in,                    // 时钟信号
    input sys_rstn,                  // 同步复位信号
    // dip switch
    input [7:0] dip_switch0,
    input [7:0] dip_switch1,
    input [7:0] dip_switch2,
    input [7:0] dip_switch3,
    input [7:0] dip_switch4,
    input [7:0] dip_switch5,
    input [7:0] dip_switch6,
    input [7:0] dip_switch7,
    // key
    input [7:0] user_key,
    // led
    output [31:0] led_light,
    // digital tube
    output [7:0] digital_tube2,
    output digital_tube_sel2,
    output [7:0] digital_tube1,
    output [3:0] digital_tube_sel1,
    output [7:0] digital_tube0,
    output [3:0] digital_tube_sel0,
    // uart
    input uart_rxd,
    output uart_txd
    );
    
    wire clk;
    CLOCK CLOCK(
        .CLK_IN1(clk_in),
        .CLK_OUT1(clk)
    );
    
    wire reset=~sys_rstn;
    wire [31:0] pr_addr, pr_wdata, pr_rdata;
    wire [31:0] i_inst_addr, i_inst_rdata;
    wire [31:0] m_data_addr, m_data_rdata, m_data_wdata;
    wire [3:0] m_data_byteen;
    wire pr_mem_write, pr_req;
    wire [2:0] pr_sel;
    wire [4:0] pr_exc;
    
    wire [31:2] t0_a;
    wire t0_we, t0_irq;
    wire [31:0] t0_din, t0_dout;
    
    wire [31:0] gpio_a, gpio_din, gpio_dout;
    wire [3:0] gpio_be;
    
    wire [31:0] tube_a, tube_din, tube_dout;
    wire [3:0] tube_be;
    
    wire [31:0] uart_a, uart_din, uart_dout;
    wire uart_we, uart_irq;
    
    IM IM(
        .clka(clk), // input
        .addra(i_inst_addr[13:2]), // input [11:0]
        .douta(i_inst_rdata) // output [31:0]
    );
    DM DM(
        .clka(clk), // input
        .rsta(reset), // input
        .wea(m_data_byteen), // input [3:0]
        .addra(m_data_addr[13:2]), // input [11:0]
        .dina(m_data_wdata), // input [31:0]
        .douta(m_data_rdata) // output [31:0]
    );
    
    TC T0(
        .clk(clk), 
        .reset(reset), 
        .Addr(t0_a), 
        .WE(t0_we), 
        .Din(t0_din), 
        .Dout(t0_dout), 
        .IRQ(t0_irq)
    );
    
    GPIO GPIO(
        .clk(clk), 
        .rst(reset), 
        .ds0(dip_switch0), .ds1(dip_switch1), .ds2(dip_switch2), .ds3(dip_switch3), 
        .ds4(dip_switch4), .ds5(dip_switch5), .ds6(dip_switch6), .ds7(dip_switch7), 
        .key(user_key), 
        .led(led_light), 
        .Addr(gpio_a), 
        .ByteEn(gpio_be), 
        .Din(gpio_din), 
        .Dout(gpio_dout)
    );
    
    DigitalTube DigitalTube(
        .clk(clk), 
        .rst(reset), 
        .sel0(digital_tube_sel0), .seg0(digital_tube0), 
        .sel1(digital_tube_sel1), .seg1(digital_tube1), 
        .sel2(digital_tube_sel2), .seg2(digital_tube2), 
        .Addr(tube_a), 
        .ByteEn(tube_be), 
        .Din(tube_din), 
        .Dout(tube_dout)
    );
    
    uart UART(
        .clk(clk), 
        .rstn(sys_rstn), 
        .rxd(uart_rxd), 
        .txd(uart_txd), 
        .irq(uart_irq), 
        .Addr(uart_a), 
        .WE(uart_we), 
        .Din(uart_din), 
        .Dout(uart_dout)
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
        //.macro_addr(macroscopic_pc), 
        //.w_grf_we(w_grf_we), 
        //.w_grf_addr(w_grf_addr), 
        //.w_grf_wdata(w_grf_wdata), 
        //.w_inst_addr(w_inst_addr), 
        .hw_int({2'b0, uart_irq, 2'b0, t0_irq})
    );
    
    Bridge Bridge(
        .clk(clk), 
        .rst(reset),
        .data_addr(pr_addr), 
        .data_wdata(pr_wdata), 
        .data_mem_write(pr_mem_write), 
        .data_sel(pr_sel), 
        .data_req(pr_req), 
        .data_rdata(pr_rdata), 
        .data_exc(pr_exc),  
        .DMAddr(m_data_addr), 
        .DMRdata(m_data_rdata), 
        .DMWdata(m_data_wdata), 
        .DMByteen(m_data_byteen), 
        .TC0Addr(t0_a), 
        .TC0WE(t0_we), 
        .TC0Din(t0_din), 
        .TC0Dout(t0_dout),
        .GPIOAddr(gpio_a),
        .GPIOBE(gpio_be),
        .GPIODin(gpio_din),
        .GPIODout(gpio_dout),
        .TubeAddr(tube_a),
        .TubeBE(tube_be),
        .TubeDin(tube_din),
        .TubeDout(tube_dout),
        .UARTAddr(uart_a),
        .UARTWE(uart_we),
        .UARTDin(uart_din),
        .UARTDout(uart_dout)
    );

endmodule
