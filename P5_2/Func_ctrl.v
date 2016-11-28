`timescale 1ns / 1ps
//addu,subu,xor,nor,lw,sw,lui,ori,beq,j,jr,jal,jalr,clo,clz
//独热编码
`define R_Type 7'b0000001
`define I_Type 7'b0000010
`define B_Type 7'b0000100
`define Store_Type 7'b0001000
`define Load_Type 7'b0010000
`define Jl_Type 7'b0100000
`define Jr_Type 7'b1000000

module Func_ctrl(
	Op,Func,MemWrite,WriteEn,
	ALUSrc,ResultToReg,WriteRegDst,
	ALUOp,ExtOp,Branch,Jump,InstrType
    );
	input [5:0] Op;
	input [5:0] Func;
	output MemWrite;
	output WriteEn;
	output ALUSrc;
	output [1:0] ResultToReg;
	output [1:0] WriteRegDst;
	output [2:0] ALUOp;
	output [1:0] ExtOp;
	output Branch;
	output [1:0] Jump;
	output PCAddChoose;
	output [6:0] InstrType;

	wire addu,subu,xor,nor,lw,sw,lui,ori,beq,j,jr,
		jal,jalr,clo,clz;
	//指令
	assign addu = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&!Func[1]&Func[0];
	assign subu = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&Func[1]&Func[0];
	assign xor = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&Func[2]&Func[1]&!Func[0];
	assign nor = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&Func[2]&Func[1]&Func[0];
	assign ori = !Op[5]&!Op[4]&Op[3]&Op[2]&!Op[1]&Op[0];
	assign lw = Op[5]&!Op[4]&!Op[3]&!Op[2]&Op[1]&Op[0];
	assign sw = Op[5]&!Op[4]&Op[3]&!Op[2]&Op[1]&Op[0];
	assign beq = !Op[5]&!Op[4]&!Op[3]&Op[2]&!Op[1]&!Op[0];
	assign lui = !Op[5]&!Op[4]&Op[3]&Op[2]&Op[1]&Op[0];
	assign jal = !Op[5]&!Op[4]&!Op[3]&!Op[2]&Op[1]&Op[0];
	assign jr = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				!Func[5]&!Func[4]&Func[3]&!Func[2]&!Func[1]&!Func[0];
	assign j = !Op[5]&!Op[4]&!Op[3]&!Op[2]&Op[1]&!Op[0];
	assign jalr = !Op[5]&!Op[4]&!Op[3]&!Op[2]&!Op[1]&!Op[0]&
				!Func[5]&!Func[4]&Func[3]&!Func[2]&!Func[1]&Func[0];
	assign clo = !Op[5]&Op[4]&Op[3]&Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&!Func[1]&Func[0];
	assign clz = !Op[5]&Op[4]&Op[3]&Op[2]&!Op[1]&!Op[0]&
				Func[5]&!Func[4]&!Func[3]&!Func[2]&!Func[1]&!Func[0];

	//控制信号
	assign MemWrite =sw;
	assign WriteEn = addu|subu|xor|nor|lw|lui|ori|jal|jalr|clo|clz;
	assign ALUSrc = sw|lw|ori|lui;
	assign ResultToReg = {jal|jalr,lw}; //01:lw 10:jal jalr
	assign WriteRegDst = {jal,addu|subu|xor|nor|jalr|clo|clz};
	assign ALUOp = {clo|clz|nor,clz|ori|xor,subu|xor|clo};
	assign ExtOp = {lui,ori};//01 ori  10 lui
	assign Branch = beq;
	assign Jump = {jr|jalr,j|jal};
	assign InstrType = (addu|subu|xor|nor|clo|clz)?`R_Type:
						(lui|ori)?`I_Type:
						(beq)?`B_Type:
						(sw)?`Store_Type:
						(lw)?`Load_Type:
						(jalr|jal)?`Jl_Type:
						(jalr|jr)?`Jr_Type:0;
						

endmodule

