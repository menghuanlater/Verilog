`timescale 1ns / 1ps

module EXE_MEM(
    clk,IR_In,IR_Out,
    PC8_In,PC8_Out,
    AO_In,AO_Out,
    RData2_In,RData2_Out,
    Rt_In,Rt_Out,
    RegWrite_In,RegWrite_Out,
    InstrType_In,InstrType_Out
    );
    input clk;
    input [31:0] IR_In;
    input [31:0] PC8_In;
    input [31:0] AO_In;
    input [31:0] RData2_In;
    input [4:0] Rt_In;
    input [6:0] InstrType_In;
    input [4:0] RegWrite_In;
    output [31:0] IR_Out;
    output [31:0] PC8_Out;
    output [31:0] AO_Out;
    output [31:0] RData2_Out;
    output [4:0] Rt_Out;
    output [4:0] RegWrite_Out;
    output [6:0] InstrType_Out;

    reg [31:0] M_IR;
    reg [31:0] M_PC8;
    reg [31:0] M_AO;
    reg [31:0] M_RData2;
    reg [4:0] M_Rt;
    reg [4:0] M_RegWrite;
    reg [6:0] M_Instr_Type;

    assign IR_Out = M_IR;
    assign PC8_Out = M_PC8;
    assign AO_Out = M_AO;
    assign RData2_Out = M_RData2;
    assign Rt_Out = M_Rt;
    assign RegWrite_Out = M_RegWrite;
    assign InstrType_Out = M_Instr_Type;

    initial begin
        M_IR = 0;
        M_PC8 = 0;
        M_AO = 0;
        M_RData2 = 0;
        M_Rt = 0;
        M_RegWrite = 0;
        M_Instr_Type = 0;
    end

    always @(posedge clk)begin
        M_IR <= IR_In;
        M_PC8 <= PC8_In;
        M_AO <= AO_In;
        M_RData2 <= RData2_In;
        M_Rt <= Rt_In;
        M_RegWrite <= RegWrite_In;
        M_Instr_Type <= InstrType_In;
    end


endmodule
