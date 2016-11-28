`timescale 1ns / 1ps

module MEM_WB(
    clk,IR_In,IR_Out,
    PC8_In,PC8_Out,
    AO_In,AO_Out,
    DR_In,DR_Out,
    RegWrite_In,RegWrite_Out,
    InstrType_In,InstrType_Out
    );
    input clk;
    input [31:0] IR_In;
    input [31:0] PC8_In;
    input [31:0] AO_In;
    input [31:0] DR_In;
    input [4:0] RegWrite_In;
    input [6:0] InstrType_In;
    output [31:0] IR_Out;
    output [31:0] PC8_Out;
    output [31:0] AO_Out;
    output [31:0] DR_Out;
    output [4:0] RegWrite_Out;
    output [6:0] InstrType_Out;

    reg [31:0] W_IR;
    reg [31:0] W_PC8;
    reg [31:0] W_AO;
    reg [31:0] W_DR;
    reg [4:0] W_RegWrite;
     reg [6:0] W_Instr_Type;

    assign IR_Out = W_IR;
    assign PC8_Out = W_PC8;
    assign AO_Out = W_AO;
    assign DR_Out = W_DR;
    assign RegWrite_Out = W_RegWrite;
    assign InstrType_Out = W_Instr_Type;

    initial begin
    	W_IR = 0;
    	W_PC8 = 0;
    	W_AO = 0;
    	W_DR = 0;
        W_RegWrite = 0;
        W_Instr_Type = 0;
    end

    always @(posedge clk) begin
    	W_IR <= IR_In;
    	W_PC8 <= PC8_In;
    	W_AO <= AO_In;
    	W_DR <= DR_In;
        W_RegWrite <= RegWrite_In;
        W_Instr_Type <= InstrType_In;
    end

endmodule
