`timescale 1ns / 1ps

module MEM_WB(
    input clk,
    input reset,
    input [31:0] IR_In,
    input [31:0] PC8_In,
    input [31:0] AO_In,
    input [31:0] DR_In,
    input WriteEn_In,
    output [31:0] IR_Out,
    output [31:0] PC8_Out,
    output [31:0] AO_Out,
    output [31:0] DR_Out,
    output WriteEn_Out
    );
    

    reg [31:0] W_IR;
    reg [31:0] W_PC8;
    reg [31:0] W_AO;
    reg [31:0] W_DR;
    reg W_WriteEn;

    assign IR_Out = W_IR;
    assign PC8_Out = W_PC8;
    assign AO_Out = W_AO;
    assign DR_Out = W_DR;
    assign WriteEn_Out = W_WriteEn;

    initial begin
    	W_IR = 0;
    	W_PC8 = 0;
    	W_AO = 0;
    	W_DR = 0;
        W_WriteEn = 0;
    end

    always @(posedge clk) begin
        if(reset)begin
            W_IR <= 0;
    	    W_PC8 <= 0;
    	    W_AO <= 0;
    	    W_DR <= 0;
            W_WriteEn <= 0;
        end
        else begin
    	    W_IR <= IR_In;
    	    W_PC8 <= PC8_In;
    	    W_AO <= AO_In;
    	    W_DR <= DR_In;
		    if(IR_In != 32'b0)
			    W_WriteEn <= WriteEn_In;
		    else
			    W_WriteEn <= 0;
        end
    end

endmodule
