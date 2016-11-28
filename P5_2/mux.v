`timescale 1ns / 1ps

module WriteRegMux(
	WriteRegDst,Source1,Source2,Source3,SelectSource
    );
	input [1:0] WriteRegDst;
	input [4:0] Source1;//Rt
	input [4:0] Source2;//Rd
	input [4:0] Source3;//$ra
	output [4:0] SelectSource;

	parameter Rt = 2'b00,Rd = 2'b01, Ra=2'b10;

	assign SelectSource = (WriteRegDst==Rd)?Source2:(
			(WriteRegDst==Ra)?Source3:Source1);

endmodule

module ALUSrcMux(
	ALUSrc,Source1,Source2,SelectSource
	);
	input ALUSrc;
	input [31:0] Source1;//RData2
	input [31:0] Source2;//EXT
	output [31:0] SelectSource;

	assign SelectSource = ALUSrc?Source2:Source1;

endmodule

module ResultToRegMux(
	ResultToReg,Source1,Source2,Source3,SelectSource
	);
	input [1:0] ResultToReg;
	input [31:0] Source1;//ALU result
	input [31:0] Source2;//Mem
	input [31:0] Source3;//PC+4
	output [31:0] SelectSource;

	parameter ALUResult = 2'b00,MemResult = 2'b01,PCSave = 2'b10;
	assign SelectSource = ResultToReg==ALUResult ?Source1:
						  ResultToReg==MemResult ?Source2:
						  ResultToReg==PCSave    ?Source3:0;

endmodule

module NPCMux(
	Branch,zero,Jump,Source1,Source2,Source3,Source4,SelectSource
	);
	input Branch;
	input zero;
	input [1:0] Jump;
	input [31:0] Source1;//PC+4
	input [31:0] Source2;//beq
	input [31:0] Source3;//jal
	input [31:0] Source4;//jr
	output [31:0] SelectSource;

	wire [31:0] temp;
	assign temp = (Branch & zero)?Source2:Source1;
	assign SelectSource = (Jump==2'b00)?temp:((Jump==2'b01)?Source3:Source4);

endmodule

module EX_ForwardMux(
	ForwardRSE,ForwardRTE,
    RData1,RData2,W_RData,
    M_RData,M_PC8,SelectSource1,SelectSource2
	);
	input [1:0] ForwardRSE;
    input [1:0] ForwardRTE;
    input [31:0] RData1;
    input [31:0] RData2;
    input [31:0] W_RData;
    input [31:0] M_RData;
	input [31:0] M_PC8;
	output [31:0] SelectSource1;
	output [31:0] SelectSource2;

	assign SelectSource1 = (ForwardRSE==2'b00)?RData1:
						   (ForwardRSE==2'b01)?W_RData:
						   (ForwardRSE==2'b10)?M_RData:M_PC8;
	assign SelectSource2 = (ForwardRTE==2'b00)?RData2:
						   (ForwardRTE==2'b01)?W_RData:
						   (ForwardRTE==2'b10)?M_RData:M_PC8;
						   

endmodule

module MEM_ForwardMux(
	ForwardRTM,RData2,W_RData,SelectSource
	);
	input [31:0] RData2;
	input [31:0] W_RData;
	input ForwardRTM;
	output [31:0] SelectSource;
	
	assign SelectSource = (ForwardRTM)?RData2:W_RData;

endmodule

module B_ForwardMux(
	ForwardRSD,ForwardRTD,
	RData1,RData2,M_RData,M_PC8,
	SelectSource1,SelectSource2
	);
	input [1:0]ForwardRSD;
    input [1:0]ForwardRTD;
    input [31:0] RData1;
    input [31:0] RData2;
    input [31:0] M_RData;
    input [31:0] M_PC8;
	output [31:0] SelectSource1;
	output [31:0] SelectSource2;

	assign SelectSource1 = (ForwardRSD==2'b00)?RData1:
						   (ForwardRSD==2'b01)?M_RData:
						   (ForwardRSD==2'b10)?M_PC8:0;
	assign SelectSource2 = (ForwardRTD==2'b00)?RData2:
						   (ForwardRTD==2'b01)?M_RData:
						   (ForwardRTD==2'b10)?M_PC8:0;

endmodule