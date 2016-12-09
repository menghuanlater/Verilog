`timescale 1ns / 1ps

module im(
	addr,dout
    );
	input [12:2] addr;
	output [31:0] dout;

	reg [31:0] IM [2047:0];
	integer i;
	initial begin
		for(i=0;i<2047;i=i+1)
			IM[i] = 0;
		$readmemh("code.txt",IM);
	end

	assign dout = IM[addr];


endmodule
