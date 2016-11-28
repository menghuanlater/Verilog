`timescale 1ns / 1ps

module ID_EXE(
    clk,clr,
    IR_In,IR_Out,
    PC8_In,PC8_Out,
    RData1_In,RData1_Out,
    RData2_In,RData2_Out,
    EXT_In,EXT_Out,
    Rs_In,Rs_Out,
    Rt_In,Rt_Out,
    Rd_In,Rd_Out,
    InstrType_In,InstrType_Out
    );
    input clk;
    input clr;
    input [31:0] IR_In;
    input [31:0] PC8_In;
    input [31:0] RData1_In;
    input [31:0] RData2_In;
    input [31:0] EXT_In;
    input [4:0] Rs_In;
    input [4:0] Rt_In;
    input [4:0] Rd_In;
    input [6:0]  InstrType_In;
    output [31:0] IR_Out;
    output [31:0] PC8_Out;
    output [31:0] RData1_Out;
    output [31:0] RData2_Out;
    output [31:0] EXT_Out;
    output [4:0] Rs_Out;
    output [4:0] Rt_Out;
    output [4:0] Rt_Out;
    output [6:0] InstrType_Out;

    reg [31:0] E_IR;
    reg [31:0] E_PC8;
    reg [31:0] E_RData1;
    reg [31:0] E_RData2;
    reg [31:0] E_EXT;
    reg [4:0] E_Rs;
    reg [4:0] E_Rt;
    reg [4:0] E_Rd;
    reg [6:0] E_Instr_Type;
    
    assign IR_Out = E_IR;
    assign PC8_Out = E_PC8;
    assign RData1_Out = E_RData1;
    assign RData2_Out = E_RData2;
    assign EXT_Out = E_EXT;
    assign Rs_Out = E_Rs;
    assign Rt_Out = E_Rt;
    assign Rd_Out = E_Rd;
    assign InstrType_Out = E_Instr_Type;

    initial begin
        E_IR = 0;
        E_PC8 = 0;
        E_RData1 = 0;
        E_RData2 = 0;
        E_EXT = 0;
        E_Rs = 0;
        E_Rt = 0;
        E_Rd = 0;
        E_Instr_Type = 0;
    end

    always @(posedge clk) begin
        if(clr)begin
            E_IR <= 0;
            E_PC8 <= 0;
            E_RData1 <= 0;
            E_RData2 <= 0;
            E_EXT <= 0;
            E_Rs <= 0;
            E_Rt <= 0;
            E_Rd <= 0;
            E_Instr_Type <= 0;
        end
        else begin
            E_IR <= IR_In;
            E_PC8 <= PC8_In;
            E_RData1 <= RData1_In;
            E_RData2 <= RData2_In;
            E_EXT <= EXT_In;
            E_Rs <= Rs_In;
            E_Rt <= Rs_In;
            E_Rd <= Rs_In;
            E_Instr_Type <= InstrType_In;
        end
    end


endmodule
