`timescale 1ns / 1ps
/*
add   addu   addi   addiu   and   andi   sub   subu   or   ori   
xor   xori   nor    sll     srl   sra    sllv  srlv   srav lui
slt   slti   sltiu  sltu    beq   bne    blez  bgtz   bltz bgez
j     jal    jalr   jr      mfhi  mflo   mthi  mtlo   mult multu
div   divu   lb     lbu     lh    lhu    lw    sb     sh   sw 
**/

/***define,may be different bit-width***/
`define ADD   12'b000000_100000
`define ADDI  6'b001000
`define ADDIU 6'b001001
`define ADDU  12'b000000_100001
`define AND   12'b000000_100100
`define ANDI  6'b001100
`define BEQ   6'b000100
`define BGEZ  11'b000001_00001
`define BGTZ  11'b000111_00000
`define BLEZ  11'b000110_00000
`define BLTZ  11'b000001_00000
`define BNE   6'b000101
`define DIV   12'b000000_011010
`define DIVU  12'b000000_011011
`define J     6'b000010
`define JAL   6'b000011
`define JR    12'b000000_001000
`define JALR  12'b000000_001001
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
`define XORI  6'b001110
`define LB    6'b100000
`define LBU   6'b100100
`define LH    6'b100001
`define LHU   6'b100101
`define MFHI  12'b000000_010000
`define MFLO  12'b000000_010010
`define MTHI  12'b000000_010001
`define MTLO  12'b000000_010011
`define MULT  12'b000000_011000
`define MULTU 12'b000000_011001
`define NOR   12'b000000_100111
`define SB    6'b101000
`define SH    6'b101001
`define SLLV  12'b000000_000100
`define SLT   12'b000000_101010
`define SLTI  6'b001010
`define SLTIU 6'b001011
`define SLTU  12'b000000_101011
`define SRA   12'b000000_000011
`define SRAV  12'b000000_000111
`define SRLV  12'b000000_000110

module Func_ctrl(
	input [5:0] Op,
	input [5:0] Func,
	input [5:0] BID,
	input [1:0] Addr,
	output [1:0] WriteRegDst,
	output [1:0] ResultToReg,
	output Branch,
	output [1:0] Jump,
	output [1:0] ExtOp,
	output [3:0] ALUOp,
	output [3:0] BWE,
	output [3:0] BRE,
	output ALUSrcA,
	output ALUSrcB,
	output WriteEn,
	output MemWrite,
	output [2:0] CmpSel,
	output LoadUnSign,
	output Start,
	output [1:0] AOSelect,
	output [3:0] MD_OP
    ); // BID is for identify bgtz\bltz\bgez\blez...
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
	wire jalr;   assign jalr  = ({Op,Func}==`JALR);
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
	wire _nor;   assign _nor  = ({Op,Func}==`NOR);
	wire andi;   assign andi  = (Op==`ANDI);
	wire xori;   assign xori  = (Op==`XORI);
	wire lb;     assign lb    = (Op==`LB);
	wire lbu;    assign lbu   = (Op==`LBU);
	wire lh;     assign lh    = (Op==`LH);
	wire lhu;    assign lhu   = (Op==`LHU);
	wire sb;     assign sb    = (Op==`SB);
	wire sh;     assign sh    = (Op==`SH);
	wire bgtz;   assign bgtz  = ({Op,BID}==`BGTZ);
	wire bltz;   assign bltz  = ({Op,BID}==`BLTZ);
	wire bgez;   assign bgez  = ({Op,BID}==`BGEZ);
	wire blez;   assign blez  = ({Op,BID}==`BLEZ);
	wire mfhi;   assign mfhi  = ({Op,Func}==`MFHI);
	wire mflo;   assign mflo  = ({Op,Func}==`MFLO);
	wire mthi;   assign mthi  = ({Op,Func}==`MTHI);
	wire mtlo;   assign mtlo  = ({Op,Func}==`MTLO);
	wire mult;   assign mult  = ({Op,Func}==`MULT);
	wire multu;  assign multu = ({Op,Func}==`MULTU);
	wire div;    assign div   = ({Op,Func}==`DIV);
	wire divu;   assign div   = ({Op,Func}==`DIVU);
	wire sllv;   assign sllv  = ({Op,Func}==`SLLV);
	wire srlv;   assign srlv  = ({Op,Func}==`SRLV);
	wire sra;    assign sra   = ({Op,Func}==`SRA);
	wire srav;   assign srav  = ({Op,Func}==`SRAV);
	wire slt;    assign slt   = ({Op,Func}==`SLT);
	wire slti;   assign slti  = (Op==`SLTI);
	wire sltiu;  assign sltiu = (Op==`SLTIU);
	wire sltu;   assign sltu  = ({Op,Func}==`SLTU);

	//control signals
	//just for ALUOp
	parameter ALU_ADD = 4'h0,ALU_SUB = 4'h1,ALU_OR = 4'h2,ALU_AND = 4'h3,
    ALU_XOR = 4'h4,ALU_NOR = 4'h5,ALU_SLL = 4'h6,ALU_SLLV = 4'h7,
    ALU_SRL = 4'h8,ALU_SRLV = 4'h9,ALU_SRA = 4'ha,ALU_SRAV =  4'hb,
    ALU_SLT = 4'hc,ALU_SLTU = 4'hd;
    //****************************************//
	assign ALUOp = 
	(sub|subu)    ? ALU_SUB  : 
	(_or|ori)     ? ALU_OR   :
	(_and|andi)   ? ALU_AND  :
	(_xor|xori)   ? ALU_XOR  :
	(_nor)        ? ALU_NOR  :
	(sll)         ? ALU_SLL  :
	(sllv)        ? ALU_SLLV :
	(srl)         ? ALU_SRL  :
	(srlv)		  ? ALU_SRLV :
	(sra)		  ? ALU_SRA  :
	(srav)		  ? ALU_SRAV :
	(slt|slti)    ? ALU_SLT  :
	(sltu|sltiu)  ? ALU_SLTU : 0;

	// BWE represent some memory's bytes can be writen 
	assign BWE = 
	(sw)                  ? 4'b1111 :
	(sh & Addr == 2'b00)  ? 4'b0011 :
	(sh & Addr == 2'b10)  ? 4'b1100 :
	(sb & Addr == 2'b00)  ? 4'b0001 :
	(sb & Addr == 2'b01)  ? 4'b0010 :
	(sb & Addr == 2'b10)  ? 4'b0100 :
	(sb & Addr == 2'b11)  ? 4'b1000 : 0;
	//BRE represent some data's bytes can be read into grf
	assign BRE =
	(lw)                     ? 4'b1111 :
	(lh|lhu) & Addr == 2'b00 ? 4'b0011 :
	(lh|lhu) & Addr == 2'b10 ? 4'b1100 :
	(lb|lbu) & Addr == 2'b00 ? 4'b0001 :
	(lb|lbu) & Addr == 2'b01 ? 4'b0010 :
	(lb|lbu) & Addr == 2'b10 ? 4'b0100 :
	(lb|lbu) & Addr == 2'b11 ? 4'b1000 : 0; 
	//load is unsigned
	assign LoadUnSign = (lbu | lhu);
	// AO select
	assign AOSelect = (mthi) ? 2'b01 : (mtlo) ? 2'b10 : 2'b00;
	//memory WriteEn
	assign MemWrite = sw|sb|sh;
	//for Branch
	assign Branch = beq|bne|bgtz|bgez|bltz|blez;
	//for Jump
	assign Jump = (j|jal) ? 2'b01: (jalr|jr) ? 2'b10 : 2'b00;
	//for ExtOp
	assign ExtOp = 
	(ori|andi|xori|sltiu|lbu|lhu) ? 2'b01 :
	(lui)						  ? 2'b10 :
	(sll|srl|sra)				  ? 2'b11 : 2'b00;
	//for ALUSrcA
	assign ALUSrcA = sll|srl|sra;
	//for ALUSrcB
	assign ALUSrcB = addi|addiu|ori|andi|xori|sll|srl|sra|slti|sltiu|
	lui|lb|lbu|lh|lhu|lw|sw|sb|sh;
	//for WriteEn
	assign WriteEn = !(sb|sh|sw|beq|bne|bgtz|bgez|bltz|blez|j|jr|
	mult|multu|div|divu|mtlo|mthi);
	//for CmpSel
	assign CmpSel =
	beq  ? 3'h0 : bne  ? 3'h1 :
	bgtz ? 3'h2 : bgez ? 3'h3 :
	bltz ? 3'h4 : blez ? 3'h5 : 0;
	//for Start
	assign Start = mult|multu|div|divu; 
	//for WriteRegDst
	assign WriteRegDst = 
	(addu|add|sub|subu|_or|_and|_xor|_nor|sll|sllv|srl|srlv|
	sra|srav|slt|sltu|jalr|mflo|mfhi) ? 2'b01 :
	(jal)                             ? 2'b10 : 2'b00;
	//for ResultToReg
	assign ResultToReg = 
	(lw|lb|lbu|lh|lhu)   ? 2'b01 :
	(jalr|jal)			 ? 2'b10 : 2'b00;
	//for MD_OP
	assign MD_OP = 
	mult  ? 4'd1 :
	multu ? 4'd2 :
	div   ? 4'd3 :
	divu  ? 4'd4 :
	mthi  ? 4'd5 :
	mtlo  ? 4'd6 : 4'd0;

endmodule

