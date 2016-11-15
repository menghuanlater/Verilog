`timescale 1ns / 1ps

module ext(
	Imm16,Imm26,ExtOp,ExtH_Imm32,ExtL_Imm32,ExtJ_Imm28;
    );
	input [15:0] Imm16;
	input ExtOp;
	output [31:0] ;

	assign  = (ExtOp|!Imm16[15])?{16'b0,Imm16}:{16'hffff,Imm16};

endmodule