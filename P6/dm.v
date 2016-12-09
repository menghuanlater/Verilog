`timescale 1ns / 1ps
//swr and swl
module dm(
	input [12:0] addr,
	input [31:0] din,
	input we,
	input [3:0] BWE,
	input clk,
	input reset,
	output [31:0] dout
    );

	reg [31:0] DM[2047:0];
	integer i;

	initial begin
		for(i=0;i<2047;i=i+1)begin
			DM[i] = 0;
		end
	end

	assign dout = DM[addr[12:2]];

	wire [31:0] _addr;
	assign _addr = {19'b0,addr};

	always @(posedge clk)begin
		if(reset)begin
			for(i=0;i<2047;i=i+1)begin
				DM[i] = 0;
			end
		end
		else if(we)begin
			case(BWE)
				4'b1111:begin
					DM[addr[12:2]] <= din;
					$display("*%h <= %h",_addr,din);
				end
				4'b0011:begin
					DM[addr[12:2]][15:0] <= din[15:0];
					$display("*%h <= %h",_addr,din[15:0]);
				end
				4'b1100:begin
					DM[addr[12:2]][31:16] <= din[15:0];
					$display("*%h <= %h",_addr,din[15:0]);
				end
				4'b0001:begin
					DM[addr[12:2]][7:0] <= din[7:0];
					$display("*%h <= %h",_addr,din[7:0]);
				end
				4'b0010:begin
					DM[addr[12:2]][15:8] <= din[7:0];
					$display("*%h <= %h",_addr,din[7:0]);
				end
				4'b0100:begin
					DM[addr[12:2]][23:16] <= din[7:0];
					$display("*%h <= %h",_addr,din[7:0]);
				end
				4'b1000:begin
					DM[addr[12:2]][31:24] <= din[7:0];
					$display("*%h <= %h",_addr,din[7:0]);
				end
			endcase
		end
	end


endmodule