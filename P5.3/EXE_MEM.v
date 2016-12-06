`timescale 1ns / 1ps

module EXE_MEM(
    input clk,
    input reset,
    input [31:0] IR_In,
    input [31:0] PC8_In,
    input [31:0] AO_In,
    input [31:0] RData2_In,
    input WriteEn_In,
    output [31:0] IR_Out,
    output [31:0] PC8_Out,
    output [31:0] AO_Out,
    output [31:0] RData2_Out,
    output WriteEn_Out
    );
    
    reg [31:0] M_IR;
    reg [31:0] M_PC8;
    reg [31:0] M_AO;
    reg [31:0] M_RData2;
    reg M_WriteEn;

    assign IR_Out = M_IR;
    assign PC8_Out = M_PC8;
    assign AO_Out = M_AO;
    assign RData2_Out = M_RData2;
    assign WriteEn_Out = M_WriteEn;

    initial begin
        M_IR = 0;
        M_PC8 = 0;
        M_AO = 0;
        M_RData2 = 0;
        M_WriteEn = 0;
    end

    always @(posedge clk)begin
        if(reset)begin
            M_IR <= 0;
            M_PC8 <= 0;
            M_AO <= 0;
            M_RData2 <= 0;
            M_WriteEn <= 0;
        end
        else begin 
            M_IR <= IR_In;
            M_PC8 <= PC8_In;
            M_AO <= AO_In;
            M_RData2 <= RData2_In;
            M_WriteEn <= WriteEn_In;
        end
    end


endmodule
