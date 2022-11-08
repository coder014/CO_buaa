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
		#12 reset=0;
        //#800 $finish;
	end
    
    always #4 clk=~clk;
      
endmodule

