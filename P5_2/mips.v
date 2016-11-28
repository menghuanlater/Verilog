`timescale 1ns / 1ps

`include "pc.v"
`include "mux.v"
`include "grf.v"
`include "dm.v"
`include "im.v"
`include "alu.v"
`include "B_Cmp.v"
`include "EXE_MEM.v"
`include "ext.v"
`include "Func_ctrl.v"
`include "ID_EXE.v"
`include "IF_ID.v"
`include "MEM_WB.v"
`include "Hazard.v"

`define OPCODE 31:26
`define RS 25:21
`define RT 20:16
`define RD 15:11
`define FUNCTION 5:0
`define IMM16 15:0
`define IMM26 25:0

module mips(
    clk,reset
    );
    input clk;
    input reset;
    //Instruction Fetch
    wire [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] PC4;
    wire [31:0] PC8;
    wire UpdateEn;
    assign PC4 = PC + 4;
    assign PC8 = PC + 8;
    wire [31:0] BPC;
    wire [31:0] JPC;
    wire [31:0] JRPC;
    assign BPC = (PC8_D-4) + (Ext_Imm32<<2);
    assign JPC = {{(PC8_D-8)[31:28]},Ext_Imm28};
    assign JRPC = RData1_D;
    wire [31:0] Instr;

    //IF/ID
    wire [31:0] IR_D;
    wire [31:0] PC8_D;
    wire IF_ID_EN;

    //Decode and Read Register
    wire [4:0] RS_D;
    wire [4:0] RT_D;
    wire [4:0] RD_D;
    wire [15:0] Imm16;
    wire [25:0] Imm26;
    assign RS_D = IR_D[`RS];
    assign RT_D = IR_D[`RT];
    assign RD_D = IR_D[`RD];
    assign Imm16 = IR_D[`IMM16];
    assign Imm26 = IR_D[`IMM26];

    wire [31:0] Ext_Imm32;
    wire [27:0] Ext_Imm28;

    wire [4:0] ReadReg1;
    wire [4:0] ReadReg2;
    assign ReadReg1 = RS_D;
    assign ReadReg2 = RT_D;
    wire [31:0] RData1_D_Init;
    wire [31:0] RData2_D_Init;
    wire [31:0] RData1_D;
    wire [31:0] RData2_D;
    
    wire Branch;
    wire [1:0] Jump;
    wire [1:0] ExtOp;
    wire zero;
    wire [1:0]ForwardRSD;
    wire [1:0]ForwardRTD;
    
    //ID_EXE
    wire [31:0] IR_E;
    wire [31:0] PC8_E;
    wire [31:0] RData1_E;
    wire [31:0] RData2_E;
    wire [31:0] EXT_E;
    wire [4:0] RS_E;
    wire [4:0] RT_E;
    wire [4:0] RD_E;
    wire ID_EXE_CLR;

    //Execute
    wire [31:0] OP_A;
    wire [31:0] OP_B_Temp;
    wire [31:0] OP_B;
    wire [31:0] AO_E;
    wire [4:0] RegWrite_E;
    wire ALUSrc;
    wire [1:0] WriteRegDst;
    wire [1:0] ALUOp;
    wire [1:0] ForwardRSE;
    wire [1:0] ForwardRTE;

    //EXE_MEM
    wire [31:0] IR_M;
    wire [31:0] PC8_M;
    wire [31:0] AO_M;
    wire [31:0] RData2_M;
    wire [4:0] RegWrite_M;
    wire [4:0] RT_M;
    
    //Memory
    wire [31:0] WMData;
    wire [31:0] DR_M;
    wire MemWrite;
    wire ForwardRTM;

    //MEM_WB
    wire [31:0] IR_W;
    wire [31:0] PC8_W;
    wire [31:0] AO_W;
    wire [31:0] DR_W;
    wire [4:0] RegWrite_W;
    
    wire [31:0] WData;

    wire [1:0] ResultToReg;
    wire WriteEn;
    wire [4:0] RA;
    assign RA = 5'h1f;

    //Instruction Type
    wire [6:0] D_InstrType;
    wire [6:0] E_InstrType;
    wire [6:0] M_InstrType;
    wire [6:0] W_InstrType;

    pc U_PC(.clk(clk),.reset(reset),.PC_current(PC),.UpdateEn(UpdateEn),.PC_next(PC_next));
    
    im U_IM(.addr(PC[11:2]),.dout(Instr));
    
    IF_ID U_IF_ID(.clk(clk),.en(IF_ID_EN),.PC8_In(PC8),.PC8_Out(PC8_D),.IR_In(Instr),.IR_Out(IR_D));
    //Func instance            
    Func_ctrl D_Func_ctrl(.Op(IR_D[`OPCODE]),.Func(IR_D[`FUNCTION]),.InstrType(D_InstrType),
                          .Branch(Branch),.Jump(JUmp),.ExtOp(ExtOp));
    Func_ctrl E_Func_ctrl(.Op(IR_E[`OPCODE]),.Func(IR_E[`FUNCTION]),.ALUOp(ALUOp),.ALUSrc(ALUSrc),
                          .WriteRegDst(WriteRegDst));
    Func_ctrl M_Func_ctrl(.Op(IR_M[`OPCODE]),.Func(IR_M[`FUNCTION]),.MemWrite(MemWrite));
    
    Func_ctrl W_Func_ctrl(.Op(IR_W[`OPCODE]),.Func(IR_W[`FUNCTION]),.WriteEn(WriteEn),.ResultToReg(ResultToReg));
    			
    grf U_GRF(.clk(clk),.reset(reset),.ReadReg1(ReadReg1),.ReadReg2(ReadReg2),.RegWrite(RegWrite_W),
              .WriteEn(WriteEn),.WData(WData),.RData1(RData1_D_Init),.RData2(RData2_D_Init));

    B_ForwardMux MFRSD_MFRTD(.ForwardRSD(ForwardRSD),.ForwardRTD(ForwardRTD),.RData1(RData1_D_Init),
                             .RData2(RData2_D_Init),.M_RData(AO_M),.M_PC8(PC8_M),.SelectSource1(RData1_D),
                             .SelectSource2(RData2_D));

    B_Cmp U_B_Cmp(.RData1(RData1_D),.RData2(RData2_D),.equal(zero));

    NPCMux U_NPC(.Branch(Branch),.zero(zero),.Jump(Jump),.Source1(PC4),.Source2(BPC),.Source3(JPC),.Source4(JRPC),
                 .SelectSource(PC_next));
    
    ext U_EXT(.Imm16(Imm16),.Imm26(Imm26),.ExtOp(ExtOp),.Ext_Imm32(Ext_Imm32),.Ext_Imm28(Ext_Imm28));

    ID_EXE U_ID_EXE(.clk(clk),.clr(ID_EXE_CLR),.IR_In(IR_D),.IR_Out(IR_E),.PC8_In(PC8_D),.PC8_Out(PC8_E),
                    .RData1_In(RData1_D),.RData1_Out(RData1_E),.RData2_In(RData2_D),.RData2_Out(RData2_E),
                    .EXT_In(Ext_Imm32),.EXT_Out(EXT_E),.Rs_In(RS_D),.Rs_Out(RS_E),.Rt_In(RT_D),.Rt_Out(RT_E),
                    .Rd_In(RD_D),.Rd_Out(RD_E),.InstrType_In(D_InstrType),.InstrType_Out(E_InstrType));
    
    EX_ForwardMux MFRSE_MFRTE(.ForwardRSE(ForwardRSE),.ForwardRTE(ForwardRTE),.RData1(RData1_E),.RData2(RData2_E),
                              .M_RData(AO_M),.M_PC8(M_PC8),.W_RData(WData),.SelectSource1(OP_A),.SelectSource2(OP_B_Temp));
    
    ALUSrcMux U_ALUSrcB(.ALUSRc(ALUSrc),.Source1(OP_B_Temp),.Source2(EXT_E),.SelectSource(OP_B));

    WriteRegMux U_WriteReg(.WriteRegDst(WriteRegDst),.Source1(RT_E),.Source2(RD_E),.Source3(RA),.SelectSource(RegWrite_E));

    alu U_ALU(.A(OP_A),.B(OP_B),.ALUOp(ALUOp),.outcome(AO_E));

    EXE_MEM U_EXE_MEM(.clk(clk),.IR_In(IR_E),.IR_Out(IR_M),.PC8_In(PC8_E),.PC8_Out(PC8_M),.AO_In(AO_E),.AO_Out(AO_M),
                      .RData2_In(OP_B),.RData2_Out(RData2_M),.Rt_In(RT_E),.Rt_Out(RT_M),.RegWrite_In(RegWrite_E),
                      .RegWrite_Out(RegWrite_M),.InstrType_In(E_InstrType),.InstrType_Out(M_InstrType));
    
    MEM_ForwardMux MFRTM(.ForwardRTM(ForwardRTM),.RData2(RData2_M),.W_Data(WData),.SelectSource(WMData));

    dm U_DM(.clk(clk),.reset(reset),.addr(AO_M[11:2]),.din(WMData),.we(MemWrite),.dout(DR_M);

    MEM_WB U_MEM_WB(.clk(clk),.IR_In(IR_M),.IR_Out(IR_W),.PC8_In(PC8_M),.PC8_Out(PC8_W),.AO_In(AO_M),.AO_Out(AO_W),
                    .DR_In(DR_M),.DR_Out(DR_W),.RegWrite_In(RegWrite_M),.RegWrite_Out(RegWrite_W),
                    .InstrType_In(M_InstrType),.InstrType_Out(W_InstrType));

    ResultToRegMux U_ResultToReg(.ResultToReg(ResultToReg),.Source1(AO_W),.Source2(DR_W),.Source3(PC8_W),.SelectSource(WData));

    Stall U_Stall(.D_InstrType(D_InstrType),.E_InstrType(E_InstrType),.M_InstrType(M_InstrType),.UpdateEn(UpdateEn),
                  .IF_ID_EN(IF_ID_EN),.ID_EXE_CLR(ID_EXE_CLR),.RS_D(RS_D),.RT_D(RT_D),.RegWrite_E(RegWrite_E),.RegWrite_M(RegWrite_M)); 

    Forward U_Forward(.D_InstrType(D_InstrType),.E_InstrType(E_InstrType),.M_InstrType(M_InstrType),.W_InstrType(W_InstrType),
                      .RS_D(RS_D),.RT_D(RT_D),.RS_E(RS_E),.RT_E(RT_E),.RT_M(RT_M),.RegWrite_M(RegWrite_M),.RegWrite_W(RegWrite_W),
                      .ForwardRSD(ForwardRSD),.ForwardRSE(ForwardRSE),.ForwardRTD(ForwardRTD),.ForwardRTE(ForwardRTE),.ForwardRTM(ForwardRTM));

endmodule
