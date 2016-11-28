`timescale 1ns / 1ps
`define CL_INIT 32'h20
module alu(
	A,B,ALUOp,outcome
    );
	input [31:0] A;
	input [31:0] B;
	input [2:0] ALUOp;
	output reg [31:0] outcome;

	parameter ADD = 3'b000,SUB = 3'b001,
			OR = 3'b010,XOR = 3'b011,NOR = 3'b100,
			CLO = 3'b101, CLZ =3'b110;

	integer i;
	reg temp;
	initial begin
		temp = `CL_INIT;
	end
	always@(*)begin
		case(ALUOp)
			ADD:outcome <= A+B;
			SUB:outcome <= A-B;
			OR :outcome <= A|B;
			XOR:outcome <= A^B;
			NOR:outcome <= ~(A|B);
			CLO:begin
				temp = `CL_INIT;
				for(i=0;i<32;i=i+1)begin
					if(A[i]==0)
						temp=31-i;
				end
				outcome <= temp;
			end
			CLZ:begin
				temp = `CL_INIT;
				for(i=0;i<32;i=i+1)begin
					if(A[i])
						temp=31-i;
				end
				outcome <= temp;
			end
			default:outcome <= 0;
		endcase
	end

endmodule