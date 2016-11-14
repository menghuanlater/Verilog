`timescale 1ns / 1ps
//`define PC_INIT 0x0000_3000
`include "pc.v"
`include "ctrl.v"
`include "im.v"
`include "mux.v"
`include "ext.v"
`include "dm.v"
`include "grf.v"
`include "alu.v"
//support mips instructions:
// nop,jal,jr,addu,subu,ori,lw,sw,beq,lui
//care [31:2] [11:2]
module mips(
	clk,reset
    );
	input clk;
	input reset;
	wire [31:2] PC;
	wire [31:0] 
	//instance
	pc myPC(.PC_current(PC));
	alu myALU();
	im_4k myIM();
	dm_4k myDM();
	ctrl MyController();
	grf myGRF();
	ext myEXT();
	ALUSrcMux myALUSrc();
	MemtoRegMux myMemtoReg();
	NPCMux myNPC();
	WriteRegMux myWriteReg();
	
	//functions 
	always@(posedge clk or posedge reset)begin
		if(reset)begin
			myPC(.clk(clk),.reset(reset),.PC_current(PC));
			myDM(.clk(clk),.reset(reset));
			myGRF(.clk(clk),.reset(reset));

		end
		else begin
			
		end
	end

endmodule
