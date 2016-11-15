`timescale 1ns / 1ps
`include "pc.v"
`include "ctrl.v"
`include "im.v"
`include "mux.v"
`include "ext.v"
`include "dm.v"
`include "grf.v"
`include "alu.v"
//define
`define Operation 31:26
`define function 5:0
`define Rs 25:21
`define Rt 20:16
`define Rd 15:11
`define Imm16 15:0
`define Imm26 25:0
//support mips instructions0:
// nop,jal,jr,addu,subu,ori,lw,sw,beq,lui
//care [31:2] [11:2]
//when clock up comming,first execute write functions then 
//do decode and calculate the next instrucions
module mips(
	clk,reset
    );
	input clk;
	input reset;

	//instruction fetch
	wire [31:0] PC;
	wire [31:0] PC4;
	wire [31:0] BPC;
	wire [31:0] JPC; 
	wire [31:0] JRPC;
	wire [31:0] PC_next;
	wire [31:0] Instr;

	//decode instruction
	wire [5:0] Opcode;
	wire [5:0] Func;
	wire [4:0] Rs;
	wire [4:0] Rt;
	wire [4:0] Rd;
	wire [15:0] Imm16;
	wire [25:0] Imm26;

	//Control signals
	wire [1:0] Jump;
	wire Branch;
	wire ALUSrc;
	wire [1:0] ALUOp;
	wire ExtOp;
	wire MemWrite;
	wire [1:0] MemtoReg;
	wire WriteEn;
	wire [1:0] WriteRegDist;

	//GRF
	wire [5:0] ReadReg1;
	wire [5:0] ReadReg2;
	wire [31:0] RData1;
	wire [31:0] RData2;

	//Ext ///just use imm16 or imm26 is ok
	wire [31:0] ExtH_Imm32;// for ALU B
	wire [31:0] ExtL_Imm32;// for "lui" instr
	wire [27:0] ExtJ_Imm28;//for j

	//////////////////////////when extend instructions//////////
	assign ReadReg1 = Rs;
	assign ReadReg2 = Rt;
	assign JRPC = RData1; 
	//////////////////////////need modify///////////////////////

	//ALU
	wire [31:0] A;
	wire [31:0] B;
	wire [31:0] outcome; 
	wire zero;

	//Dynamic Memory
	wire [11:2] DMAddr;
	wire [31:0] SData;
	wire [31:0] MData;
	assign SData = RData2;

	//Write back
	wire [4:0] RegWrite;
	wire [31:0] WData;
	wire [4:0] ra;
	assign ra = 0x1f; 

 
	//assign
	assign Opcode = Instr[`Operation];
	assign Func = Instr[`function];
	assign Rs = Instr[`Rs];
	assign Rt = Instr[`Rt];
	assign Rd = Instr[`Rd];
	assign Imm16 = Instr[`Imm16];
	assign Imm26 = Instr[`Imm26];  
	//instance and //execute first instruction except write operation
	pc myPC(.reset(reset),.PC_current(PC));
	/////////////////////////////////////////////////
	im_4k myIM(.addr(PC[11:2],.dout(Instr)));
	/////////////////////////////////////////////////
	ctrl MyController(.Op(Opcode),.Func(Func),.Jump(Jump),.Branch(Branch),
		.ALUSrc(ALUSrc),.ALUOp(ALUOp),.ExtOp(ExtOp),.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),.WriteEn(WriteEn),.WriteRegDist(WriteRegDist));
	/////////////////////////////////////////////////
	grf myGRF(.ReadReg1(ReadReg1),.ReadReg2(ReadReg2),.RData1(RData1),
		.RData2(RData2),.reset(reset));
	////////////////////////////////////////////////
	ext myEXT(.Imm16(Imm16),.Imm26(Imm26),.ExtOp(ExtOp),.ExtH_Imm32(ExtH_Imm32),
		.ExtL_Imm32(ExtL_Imm32),.ExtJ_Imm28(ExtJ_Imm28));
	assign JPC = {PC[31:28],ExtJ_Imm28};
	assign PC4 = PC+4;
	assign BPC = PC4+ExtH_Imm32<<2;
	//////////////////////////////////////////////
	ALUSrcMux myALUSrc(.ALUSrc(ALUSrc),.Source1(RData2),.Source2(ExtH_Imm32),
		.SelectSource(B));
	assign A = RData1;
	//////////////////////////////////////////////
	alu myALU(.A(A),.B(B),.ALUOp(ALUOp),.outcome(outcome).zero(zero));
	//////////////////////////////////////////////
	dm_4k myDM(.reset(reset),.addr(outcome[11:2]),.dout(MData));
	//////////////////////////////////////////////
	MemtoRegMux myMemtoReg(.MemtoReg(MemtoReg),.Source1(outcome),.Source2(MData),
		.Source3(ExtL_Imm32),.Source4(PC4),.SelectSource(WData));
	//////////////////////////////////////////////
	WriteRegMux myWriteReg(.WriteRegDist(WriteRegDist),.Source1(Rt),.Source2(Rd),
		.Source3(ra),.SelectSource(RegWrite));
	//////////////////////////////////////////////
	NPCMux myNPC();

	always@(posedge clk or posedge reset)begin
		if(reset)begin
			myPC(.clk(clk),.reset(reset),.PC_current(PC));
			myDM(.clk(clk),.reset(reset));
			myGRF(.clk(clk),.reset(reset));
		end
		else begin
			myNPC(.Branch(Branch),.zero(zero),.Jump(Jump),.Source1(PC4),.Source2(BPC),
				.Source3(JPC),.Source4(JRPC),.SelectSource(PC_next));
			myPC(.clk(clk),.reset(reset),.PC_current(PC),.PC_next(PC_next));
			myGRF(.clk(clk),.reset(reset),.WriteEn(WriteEn),.WData(WData));
			myDM(.clk(clk),.reset(reset),.we(MemWrite),.din(SData));

			//next procedure
		    myIM(.addr(PC[11:2],.dout(Instr)));
			MyController(.Op(Opcode),.Func(Func),.Jump(Jump),.Branch(Branch),
				.ALUSrc(ALUSrc),.ALUOp(ALUOp),.ExtOp(ExtOp),.MemWrite(MemWrite),
				.MemtoReg(MemtoReg),.WriteEn(WriteEn),.WriteRegDist(WriteRegDist));
			myGRF(.ReadReg1(ReadReg1),.ReadReg2(ReadReg2),.RData1(RData1),
				.RData2(RData2),.clk(clk),.reset(reset));
			myEXT(.Imm16(Imm16),.Imm26(Imm26),.ExtOp(ExtOp),.ExtH_Imm32(ExtH_Imm32),
				.ExtL_Imm32(ExtL_Imm32),.ExtJ_Imm28(ExtJ_Imm28));
			myALUSrc(.ALUSrc(ALUSrc),.Source1(RData2),.Source2(ExtH_Imm32),
				.SelectSource(B));
			myALU(.A(A),.B(B),.ALUOp(ALUOp),.outcome(outcome).zero(zero));
			myDM(.reset(reset),.addr(outcome[11:2]),.dout(MData));
			myMemtoReg(.MemtoReg(MemtoReg),.Source1(outcome),.Source2(MData),
				.Source3(ExtL_Imm32),.Source4(PC4),.SelectSource(WData));
			myWriteReg(.WriteRegDist(WriteRegDist),.Source1(Rt),.Source2(Rd),
				.Source3(ra),.SelectSource(RegWrite));
		end
	end

endmodule