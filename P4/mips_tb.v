`timescale 1ns/1ps
module mips_tb;
	reg clk;
	reg reset;

	mips mips_test(
		.clk(clk),
		.reset(reset)
		);
	always #5 clk=~clk;
	initial begin
		clk=0;
		reset=0;
	end

	initial begin
		$dumpfile("mips_test.vcd");
		$dumpvars(0,mips_test);
	end


endmodule