`timescale 1ns / 1ps

module mul_div(
	input clk,
	input reset,
	input Start,
	input signed [31:0] RData1,
	input signed [31:0] RData2,
	input [3:0] Op,
	output reg Busy,
	output [31:0] HI_Outcome,
	output [31:0] LO_Outcome
    );
	
	reg [31:0] HI;
	reg [31:0] LO;
	reg [3:0] Count;

	parameter MULT = 4'd1, MULTU = 4'd2, DIV = 4'd3, DIVU = 4'd4,
			  MTHI = 4'd5, MTLO  = 4'd6;

	assign HI_Outcome = HI;
	assign LO_Outcome = LO;

	initial begin
		HI = 32'h0;
		LO = 32'h0;
		Busy = 0;
		Count = 0;
	end

	always @(posedge clk) begin
		if(reset)begin
			HI <= 0;
			LO <= 0;
			Busy <= 0;
			Count <= 0;
		end
		else begin
			if(Start)begin    // for Busy
				Busy = 1;
				Count = Count + 1;
				if((Op==MULT | Op == MULTU) & Count == 5)begin
					Busy = 0;
					Count = 0;
				end
				else if((Op==DIV | Op==DIVU) & Count == 10)begin
					Busy = 0;
					Count = 0;
				end
			end
		//********************//
			case(Op)
				MULT :{HI,LO} = RData1 * RData2;
				MULTU:{HI,LO} = {1'b0,RData1} * {1'b0,RData2};
				DIV  :begin
					if(RData2!=0)begin
						HI <= RData1 % RData2;
						LO <= RData1 / RData2;
					end
				end
				DIVU :begin
					if(RData2 !=0)begin
						HI <= {1'b0,RData1} % {1'b0,RData2};
						LO <= {1'b0,RData1} / {1'b0,RData2};
					end
				end
				MTHI:HI <= RData1;
				MTLO:LO <= RData2;
				default:; // do nothing
			endcase
		end
	end
	
endmodule
