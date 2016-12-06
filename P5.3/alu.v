`timescale 1ns / 1ps

module alu(
	A,B,ALUOp,outcome
    );
	input [31:0] A;
	input [31:0] B;
	input [2:0] ALUOp;
	output [31:0] outcome;

	parameter ADD = 3'b000,SUB = 3'b001,OR = 3'b010,
		      AND = 3'b011,XOR = 3'b100,SLL = 3'b101,SRL = 3'b110;
	assign outcome = 
	ALUOp == ADD ? A+B:
	ALUOp == SUB ? A-B:
	ALUOp == OR  ? A|B:
	ALUOp == AND ? A&B:
	ALUOp == XOR ? A^B:
	ALUOp == SLL ? (A<<B[4:0]):
	ALUOp == SRL ? (A>>B[4:0]):0;

endmodule