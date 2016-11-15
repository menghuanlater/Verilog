`timescale 1ns / 1ps

module ext(
	Imm16,Imm26,ExtOp,ExtH_Imm32,ExtL_Imm32,ExtJ_Imm28
    );
	input [15:0] Imm16;
	input [25:0] Imm26;
	input ExtOp;
	output [31:0] ExtH_Imm32;
	output [31:0] ExtL_Imm32;
	output [31:0] ExtJ_Imm28;

	assign ExtH_Imm32 = (ExtOp|!Imm16[15])?{16'b0,Imm16}:{16'hffff,Imm16};
	assign ExtL_Imm32 = {Imm16,16'b0};
	assign ExtJ_Imm28 = {Imm26,2'b0};
endmodule