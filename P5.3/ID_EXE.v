`timescale 1ns / 1ps

module ID_EXE(
    input clk,
    input clr,
    input reset,
    input [31:0] IR_In,
    input [31:0] PC8_In,
    input [31:0] RData1_In,
    input [31:0] RData2_In,
    input [31:0] EXT_In,
    input WriteEn_In,
    output [31:0] IR_Out,
    output [31:0] PC8_Out,
    output [31:0] RData1_Out,
    output [31:0] RData2_Out,
    output [31:0] EXT_Out,
    output WriteEn_Out
    );

    reg [31:0] E_IR;
    reg [31:0] E_PC8;
    reg [31:0] E_RData1;
    reg [31:0] E_RData2;
    reg [31:0] E_EXT;
    reg E_WriteEn;
    
    assign IR_Out = E_IR;
    assign PC8_Out = E_PC8;
    assign RData1_Out = E_RData1;
    assign RData2_Out = E_RData2;
    assign EXT_Out = E_EXT;
    assign WriteEn_Out = E_WriteEn;

    initial begin
        E_IR = 0;
        E_PC8 = 0;
        E_RData1 = 0;
        E_RData2 = 0;
        E_EXT = 0;
        E_WriteEn = 0;
	end
    always @(posedge clk) begin
        if(clr|reset)begin
            E_IR <= 0;
            E_PC8 <= 0;
            E_RData1 <= 0;
            E_RData2 <= 0;
            E_EXT <= 0;
            E_WriteEn <= 0;
		end
        else begin
            E_IR <= IR_In;
            E_PC8 <= PC8_In;
            E_RData1 <= RData1_In;
            E_RData2 <= RData2_In;
            E_EXT <= EXT_In;
            E_WriteEn <= WriteEn_In;
        end
    end


endmodule
