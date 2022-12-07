`timescale 1ns / 1ps
`include "const.v"

module MulDiv_tb;

	// Inputs
	reg clk;
	reg rst;
	reg start;
	reg WE;
	reg [2:0] sel;
	reg [31:0] A;
	reg [31:0] B;

	// Outputs
	wire busy;
	wire [31:0] C;

	// Instantiate the Unit Under Test (UUT)
	MulDiv uut (
		.clk(clk), 
        .req(0),
		.rst(rst), 
		.start(start), 
		.WE(WE), 
		.sel(sel), 
		.A(A), 
		.B(B), 
		.busy(busy), 
		.C(C)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		start = 0;
		WE = 0;
		sel = 0;
		A = 0;
		B = 0;
        
        #10 rst=0;
        #5 B<=32'h1c7;
        A<=32'h7e2;
        start<=1;
        sel<=`MULDIV_DO_MUL;
        #10 A<=0;
        B<=0;
        start<=0;
        #50 $finish;
	end
    
    always #5 clk=~clk;
      
endmodule

