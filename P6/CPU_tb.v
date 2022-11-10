`timescale 1ns / 1ps

module CPU_tb;
	reg clk;
	reg reset;

	mips CPU (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		clk=0;
		reset=1;
		#3 reset=0;
        #200 $finish;
	end
    
    always #1 clk=~clk;
      
endmodule

