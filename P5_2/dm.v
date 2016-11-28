`timescale 1ns / 1ps
//swr and swl
module dm(
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

	assign dout = DM[addr[11:2]];

	wire [31:0] _addr;
	assign _addr = {20'b0,addr,2'b0};

	always @(posedge clk)begin
		if(reset)begin
			for(i=0;i<1024;i=i+1)begin
				DM[i] = 0;
			end
		end
		else if(we)begin
			DM[addr] <= din;
			$dispaly("*%h <= %h",_addr,din);
		end
	end


endmodule