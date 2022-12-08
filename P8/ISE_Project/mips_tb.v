`timescale 1ns / 1ps

module mips_tb;

	// Inputs
	reg clk_in;
	reg sys_rstn;
	reg [7:0] dip_switch0;
	reg [7:0] dip_switch1;
	reg [7:0] dip_switch2;
	reg [7:0] dip_switch3;
	reg [7:0] dip_switch4;
	reg [7:0] dip_switch5;
	reg [7:0] dip_switch6;
	reg [7:0] dip_switch7;
	reg [7:0] user_key;
	wire uart_rxd;
    reg tx_start;

	// Outputs
	wire [31:0] led_light;
	wire [7:0] digital_tube2;
	wire digital_tube_sel2;
	wire [7:0] digital_tube1;
	wire [3:0] digital_tube_sel1;
	wire [7:0] digital_tube0;
	wire [3:0] digital_tube_sel0;
	wire uart_txd;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk_in(clk_in), 
		.sys_rstn(sys_rstn), 
		.dip_switch0(dip_switch0), 
		.dip_switch1(dip_switch1), 
		.dip_switch2(dip_switch2), 
		.dip_switch3(dip_switch3), 
		.dip_switch4(dip_switch4), 
		.dip_switch5(dip_switch5), 
		.dip_switch6(dip_switch6), 
		.dip_switch7(dip_switch7), 
		.user_key(user_key), 
		.led_light(led_light), 
		.digital_tube2(digital_tube2), 
		.digital_tube_sel2(digital_tube_sel2), 
		.digital_tube1(digital_tube1), 
		.digital_tube_sel1(digital_tube_sel1), 
		.digital_tube0(digital_tube0), 
		.digital_tube_sel0(digital_tube_sel0), 
		.uart_rxd(uart_rxd), 
		.uart_txd(uart_txd)
	);
    
    uart_tx tx(
        .clk(clk_in), 
        .rstn(sys_rstn), 
        .period(5208), 
        .tx_start(tx_start), 
        .tx_data(8'hB5), 
        .txd(uart_rxd)
        //.tx_avai(tx_avai)
    );

	initial begin
		// Initialize Inputs
		clk_in = 0;
		sys_rstn = 0;
        tx_start = 0;
		dip_switch0 = 'hFF;
		dip_switch1 = 'hFF;
		dip_switch2 = 'hFF;
		dip_switch3 = 'hFF;
		dip_switch4 = 'hFF;
		dip_switch5 = 'hFF;
		dip_switch6 = 'hFF;
		dip_switch7 = 'hFF;
		user_key = 'hFF;

		// Wait 100 ns for global reset to finish
		#100 sys_rstn=1;
        #20 tx_start <= 1;
        #5 tx_start <= 0;
        
		// Add stimulus here

	end
    
    always #5 clk_in=~clk_in;
      
endmodule

