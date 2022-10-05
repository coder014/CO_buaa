`timescale 1ns / 1ps

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		in = "a";

		#1 reset=0;
        #4 in=" ";
        #4 in="B";
        #4 in="E";
        #4 in="g";
        #4 in="I";
        #4 in="n";
        #4 in=" ";
        #4 in="E";
        #4 in="n";
        #4 in="d";
        #4 in="c";
        #4 in=" ";
        #4 in="e";
        #4 in="n";
        #4 in="d";
        #4 in=" ";
        #4 in="e";
        #4 in="n";
        #4 in="d";
        #4 in=" ";
        #4 in="b";
        #4 in="E";
        #4 in="G";
        #4 in="i";
        #4 in="n";
        #4 in=" ";
        #16 $finish;

	end
    always #2 clk=~clk;
endmodule

