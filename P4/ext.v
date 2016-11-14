`timescale 1ns / 1ps

module ext(
	Imm16,ExtOp,Extend
    );
	input [15:0] Imm16;
	input ExtOp;
	output [31:0] Extend;

	assign Extend = (ExtOp|!Imm16[15])?{16'b0,Imm16}:{16'hffff,Imm16};

endmodule
