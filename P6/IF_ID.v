`timescale 1ns / 1ps

module IF_ID(
    input clk,
	input reset,
    input en,
    input Busy,
    input [31:0] IR_In,
    input [31:0] PC8_In,
    output [31:0] IR_Out,
    output [31:0] PC8_Out
    );

    reg [31:0] D_IR;
    reg [31:0] D_PC8;

    assign IR_Out = D_IR;
    assign PC8_Out = D_PC8;

    initial begin
        D_IR = 0;
        D_PC8 = 0;
    end

    always @(posedge clk) begin
		if(reset)begin
			D_IR <= 0;
            D_PC8 <= 0;
		end
        else if(en & !Busy)begin
            D_IR <= IR_In;
            D_PC8 <= PC8_In;
        end
    end

endmodule
