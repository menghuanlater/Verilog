`timescale 1ns / 1ps
//add,addi,addiu,addu,sub,subu,beq,bne,j,jal,jr,lw,sw,sll,srl,And
//lui,or,ori,xor

/***define,may be different bit-width***/
`define ADD   12'b000000_100000
`define ADDI  6'b001000
`define ADDIU 6'b001001
`define ADDU  12'b000000_100001
`define AND   12'b000000_100100
`define BEQ   6'b000100
`define BNE   6'b000101
`define J     6'b000010
`define JAL   6'b000011
`define JR    12'b000000_001000
`define LUI   6'b001111
`define LW    6'b100011
`define OR    12'b000000_100101
`define ORI   6'b001101
`define SLL   12'b000000_000000
`define SRL   12'b000000_000010
`define SUB   12'b000000_100010
`define SUBU  12'b000000_100011
`define SW    6'b101011
`define XOR   12'b000000_100110

module Func_ctrl(
	input  [5:0] Op,
	input  [5:0] Func,
	output MemWrite,
	output [1:0] ResultToReg,
	output [1:0] WriteRegDst,
	output [2:0] ALUOp,
	output ALUSrcA,
	output ALUSrcB,
	output CmpSel,
	output Branch,
	output [1:0] Jump,
	output WriteEn,
	output [1:0] ExtOp
    );
	//definition
	wire add;    assign add   = ({Op,Func}==`ADD);
	wire addi;   assign addi  = (Op==`ADDI);
	wire addiu;  assign addiu = (Op==`ADDIU);
	wire addu;   assign addu  = ({Op,Func}==`ADDU);
	wire _and;   assign _and  = ({Op,Func}==`AND);
	wire beq;    assign beq   = (Op==`BEQ);
	wire bne;    assign bne   = (Op==`BNE);
	wire j;      assign j     = (Op==`J);
	wire jal;    assign jal   = (Op==`JAL);
	wire jr;     assign jr    = ({Op,Func}==`JR);
	wire lui;    assign lui   = (Op==`LUI);
	wire lw;     assign lw    = (Op==`LW);
	wire _or;    assign _or   = ({Op,Func}==`OR);
	wire ori;    assign ori   = (Op==`ORI);
	wire sll;    assign sll   = ({Op,Func}==`SLL);
	wire srl;    assign srl   = ({Op,Func}==`SRL);
	wire sub;    assign sub   = ({Op,Func}==`SUB);
	wire subu;   assign subu  = ({Op,Func}==`SUBU);
	wire sw;     assign sw    = (Op==`SW);
	wire _xor;   assign _xor  = ({Op,Func}==`XOR);

	//control signals
	assign MemWrite    = sw;
	assign ResultToReg = {jal,lw};
	assign WriteRegDst = {jal,add|sub|addu|subu|_or|_and|_xor|sll|srl};
	assign ALUOp       = {_xor|sll|srl,_or|ori|_and|srl,sub|subu|_and|sll};
	assign ALUSrcA     = sll|srl;
	assign ALUSrcB     = addi|addiu|sll|srl|ori|sw|lw|lui;
	assign CmpSel      = bne;
	assign Branch      = beq|bne;
	assign Jump        = {jr,j|jal};
	assign WriteEn     = !(beq|bne|sw|j|jr);
	assign ExtOp       = {sll|srl|lui,sll|srl|ori};

endmodule

