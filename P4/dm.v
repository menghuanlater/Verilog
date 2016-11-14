`timescale 1ns / 1ps

module dm_4k(
	addr,din,we,clk,reset,dout
    );
	input [11:2] addr;
	input [31:0] din;
	input we;
	input clk;
	input reset;
	output [31:0] dout;

	reg [31:0] DM[1023:0];
	integer i;
	initial begin
		for(i=0;i<1024;i=i+1)begin
			DM[i] = 0;
		end
	end

	assign dout = DM[addr];

	always @(posedge clk or posedge reset)begin
		if(reset)begin
			for(i=0;i<1024;i=i+1)begin
				DM[i] = 0;
			end
		end
		else if(we)begin
			DM[addr] <= din;
			$display("*%h <= %h",addr,din);
		end
	end


endmodule
