`timescale 1ns / 1ps

module alu(
	A,B,ALUOp,outcome
    );
	input signed [31:0] A;
	input signed [31:0] B;
	input [3:0] ALUOp;
	output [31:0] outcome;

	parameter ADD = 4'h0,SUB = 4'h1,OR = 4'h2,
		      AND = 4'h3,XOR = 4'h4,NOR = 4'h5,
			  SLL = 4'h6,SLLV = 4'h7,SRL = 4'h8,
			  SRLV = 4'h9,SRA = 4'ha,SRAV = 4'hb,
			  SLT = 4'hc,SLTU = 4'hd;
	assign outcome = 
	ALUOp == ADD      			? A+B:
	ALUOp == SUB      			? A-B:
	ALUOp == OR       			? A|B:
	ALUOp == AND      			? A&B:
	ALUOp == XOR      			? A^B:
	ALUOp == NOR      			? !(A|B):
	ALUOp == SLL                ? (A<<B):
	ALUOp == SLLV               ? (B<<A):
	ALUOp == SRL                ? (A>>B):
	ALUOp == SRLV               ? (B>>A):
	ALUOp == SRA                ? ({{31{A[31]}},A}>>B):
	ALUOp == SRAV               ? ({{31{B[31]}},B}>>A):
	ALUOp == SLT                ? (A<B):
	ALUOp == SLTU               ? ({1'b0,A}<{1'b0,B}):0;

endmodule
