`timescale 1ns / 1ps
// nop,jal,jr,addu,subu,ori,lw,sw,beq,lui
module ctrl(
	Op,Func,Jump,Branch,
	ALUSrc,ALUOp,
	ExtOp,MemWrite,MemtoReg,
	WriteEn,WriteRegDist,
    );
	input [5:0] Op;
	input [5:0] Func;
	output [1:0] Jump;
	output Branch;
	output ALUSrc;
	output [1:0] ALUOp;
	output ExtOp;
	output MemWrite;
	output [1:0] MemtoReg;
	output WriteEn;
	output [1:0]WriteRegDist;

	wire jal,jr,addu,subu,ori,lw,sw,beq,lui;
	//and
	assign addu = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&!Func[1]&Func[0];
	assign subu = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&Func[1]&Func[0];
	assign ori = !Op[5]&!Op[4]&Op[3]&Op[2]&!Op[1]&Op[0];
	assign lw = Op[5]&!Op[4]&!Op[3]&!Op[2]&Op[1]&Op[0];
	assign sw = Op[5]&!Op[4]&Op[3]&!Op[2]&Op[1]&Op[0];
	assign beq = !Op[5]&!Op[4]&!Op[3]&Op[2]&!Op[1]&!Op[0];
	assign lui = !Op[5]&!Op[4]&Op[3]&Op[2]&Op[1]&Op[0];
	assign jal = !Op[5]&!Op[4]&!Op[3]&!Op[2]&Op[1]&Op[0];
	assign jr = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				!Func[5]&!Func[4]&SFunc[3]&!Func[2]&!Func[1]&!Func[0];

	assign Jump = {jr,jal};//jal 01  jr 10
	assign Branch = beq;
	assign ALUSrc = ori|lw|sw;
	assign ALUOp = {ori,subu};
	assign ExtOp = ori;
	assign MemWrite = sw;
	assign MemtoReg = {lui,lw};//lui 10  lw 01
	assign WriteEn = addu|subu|ori|lw|lui|jal;
	assign WriteRegDist = {jal,addu|subu|ori|lw|lui};

endmodule