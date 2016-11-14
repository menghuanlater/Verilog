`timescale 1ns / 1ps

module WriteRegMux(
	WriteRegDist,Source1,Source2,Source3,SelectSource
    );
	input [1:0] WriteRegDist;
	input [4:0] Source1;//Rt
	input [4:0] Source2;//Rd
	input [4:0] Source3;//$ra
	output [4:0] SelectSource;

	parameter Rt = 2'b00,Rd = 2'b01, Ra=2'b10;

	assign SelectSource = (WriteRegDist==Rd)?Source2:(
			(WriteRegDist==Ra)?Source3:Source1);

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

module MemtoRegMux(
	MemtoReg,Source1,Source2,Source3,SelectSource
	);
	input [1:0] MemtoReg;
	input [31:0] Source1;//ALU result
	input [31:0] Source2;//Mem
	input [31:0] Source3;//lui
	output [31:0] SelectSource;

	parameter ALUResult = 2'b00,MemResult = 2'b01,
				ExtResult = 2'b10;
	assign SelectSource = (MemtoReg==ALUResult)?Source1:(
					(MemtoReg==MemResult)?Source2:Source3);

endmodule

module NPCMux(
	Branch,Jump,Source1,Source2,Source3,Source4,SelectSource
	);
	input Branch;
	input [1:0] Jump;
	input [31:2] Source1;//PC+4
	input [31:2] Source2;//beq
	input [31:2] Source3;//jal
	input [31:2] Source4;//jr
	output [31:2] SelectSource;

	wire [31:2] temp;
	assign temp = (Branch)?Source2:Source1;
	assign SelectSource = (Jump==2'b00)?temp:((Jump==2'b01)?Source3:Source4);
	
endmodule
