`timescale 1ns / 1ps

module alu(
	A,B,ALUOp,outcome,zero
    );
	input [31:0] A;
	input [31:0] B;
	input [1:0] ALUOp;
	output [31:0] outcome;
	output zero;

	parameter ADD = 2'b00,SUB = 2'b01,
			OR = 2'b10,AND = 2'b11;

	assign outcome = (ALUOp==ADD)?(A+B):
					((ALUOp==SUB)?(A-B):((ALUOp==OR)?(A|B):(A&B)));
	assign zero = (A==B)?1:0; 

endmodule