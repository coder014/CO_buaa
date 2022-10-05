`timescale 1ns / 1ps

module gray_tb;

	// Inputs
	reg Clk;
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;

	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 0;
		En = 0;

		#10 En=1;
		#20 Reset=1;
        #10 Reset=0;
        #100 Reset = 1;
        #10 Reset=0;
		#100 $finish;

	end
    
    always #5 Clk=~Clk;
      
endmodule

