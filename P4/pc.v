`timescale 1ns / 1ps
`define PC_INIT 0X0000_3000
module pc(
	PC_next,clk,reset,PC_current
    );
	input [31:2] PC_next;
	input clk;
	input reset;
	output reg [31:2] PC_current;

	initial begin
		PC_current <= PC_INIT;
	end

	always @(posedge clk or posedge reset)begin
		if(reset)begin
			PC_current <= PC_INIT;
		end
		else begin
			PC_current <= PC_next;
		end
	end

endmodule
