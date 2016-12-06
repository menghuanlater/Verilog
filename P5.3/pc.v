`timescale 1ns / 1ps
`define PC_INIT 32'h0000_3000
module pc(
	clk,reset,PC_current,PC_next,UpdateEn
    );
	input [31:0] PC_next;
	input clk;
	input reset;
	input UpdateEn;
	output reg [31:0] PC_current;

	initial begin
		PC_current <= `PC_INIT;
	end

	always@(posedge clk)begin
		if(reset)begin
			PC_current <= `PC_INIT;
		end
		else if(UpdateEn) begin
			PC_current <= PC_next; 
		end
	end

endmodule