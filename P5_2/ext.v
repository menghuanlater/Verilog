`timescale 1ns / 1ps

module ext(
	Imm16,Imm26,ExtOp,Ext_Imm32,Ext_Imm28
    );
	input [15:0] Imm16;
	input [25:0] Imm26;
	input [1:0] ExtOp;
	output [31:0] Ext_Imm32;
	output [27:0] Ext_Imm28;

	assign Ext_Imm28 = {Imm26,2'b0};
	assign Ext_Imm32 = (ExtOp == 2'b10)?{Imm16,16'b0}:
					   (ExtOp == 2'b01 || Imm16[15]==0)?{16'b0,Imm16}:
					   	{16'hffff,Imm16};
endmodule