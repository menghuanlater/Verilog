`timescale 1ns / 1ps

module im(
	addr,dout
    );
	input [11:2] addr;
	output [31:0] dout;

	reg [31:0] IM [1023:0];
	initial begin
		$readmemh("code.txt",IM);
	end

	assign dout = IM[addr];


endmodule
