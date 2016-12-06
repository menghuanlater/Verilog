`timescale 1ns / 1ps

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
    //PC module 
    wire [31:0] PC;  wire [31:0] PC_next; 
    wire UpdateEn;//PC control
    
    //NPC
    wire [31:0] PC4;      assign PC4 = PC + 4;
    wire [31:0] PC8;      assign PC8 = PC + 8;
    wire [31:0] BPC;      assign BPC = (PC8_D-4) + (Ext_Imm32<<2);
    wire [31:0] JPC;      assign JPC = {PC_temp[31:28],Ext_Imm28};
    wire [31:0] JRPC;     assign JRPC = RData1_D;
    wire [31:0] PC_temp;  assign PC_temp = PC8_D-8;
    
    wire [31:0] Instr;

    wire [31:0] IR_D; wire [31:0] PC8_D;
    wire IF_ID_EN;

    //Decode and Read Register
    wire [31:0] Ext_Imm32; wire [27:0] Ext_Imm28;

    wire [31:0] RData1_D_Init;
    wire [31:0] RData2_D_Init;
    wire [31:0] RData1_D;
    wire [31:0] RData2_D;

    /**********************************************************
    parameter ----> for CmpSel
    ***********************************************************/

    //D contrlo signal
    wire Branch; wire [1:0] Jump; wire [1:0] ExtOp;
    wire CmpSel; //CmpSel is use for different compare
    wire zero_B; // only for B types
    wire zero_R; // only for some special R types
    wire WriteEn_D;  
    //
    wire [1:0]ForwardRSD; 
    wire [1:0]ForwardRTD;
    
    //ID_EXE 
    wire [31:0] IR_E; wire [31:0] PC8_E; wire [31:0] RData1_E; wire [31:0] RData2_E;
    wire [31:0] EXT_E; wire WriteEn_E;
    wire ID_EXE_CLR;

    //Execute
    wire [31:0] OP_A; wire [31:0] OP_A_Temp;
    wire [31:0] OP_B; wire [31:0] OP_B_Temp;
    wire [31:0] AO_E;
    //E contrlo signal
    wire ALUSrcB; wire [2:0] ALUOp; // ALUOp will be contact with movz; movz is 3'b110
    wire [1:0] ForwardRSE;
    wire [1:0] ForwardRTE;

    //EXE_MEM 
    wire [31:0] IR_M; wire [31:0] PC8_M; wire [31:0] AO_M; wire [31:0] RData2_M; wire WriteEn_M;
    
    //Memory
    wire [31:0] WMData; 
    wire [31:0] DR_M; 
    wire MemWrite;
    wire ForwardRTM;

    //MEM_WB
    wire [31:0] IR_W; wire [31:0] PC8_W; wire [31:0] AO_W; wire [31:0] DR_W; wire WriteEn_W;
    //the finally write signal
   
    //WB
    wire [31:0] WData;
    wire [4:0] RegWrite;

    wire [1:0] ResultToReg;
    wire [1:0] WriteRegDst;
    wire [4:0] RA;
    assign RA = 5'h1f;
    /**************************************************
    **************************************************/
	//P
    pc U_PC(
        .clk(clk),
        .reset(reset),
        .PC_current(PC),
        .UpdateEn(UpdateEn),
        .PC_next(PC_next));
    //IM
    im U_IM(
        .addr(PC[11:2]),
        .dout(Instr));
    //IF_ID
    IF_ID U_IF_ID(
        .clk(clk),
        .reset(reset),
        .en(IF_ID_EN),
        .PC8_In(PC8),
        .PC8_Out(PC8_D),
        .IR_In(Instr),
        .IR_Out(IR_D));
    //D       
    Func_ctrl D_Func_ctrl(
        .Op(IR_D[`OPCODE]),
        .Func(IR_D[`FUNCTION]),
        .Branch(Branch),
        .Jump(Jump),
        .ExtOp(ExtOp),
        .WriteEn(WriteEn_D),
        .CmpSel(CmpSel));
        
    grf U_GRF(
        .clk(clk),
        .reset(reset),
        .ReadReg1(IR_D[`RS]),
        .ReadReg2(IR_D[`RT]),
        .RegWrite(RegWrite),
        .WriteEn(WriteEn_W),
        .WData(WData),
        .RData1(RData1_D_Init),
        .RData2(RData2_D_Init));
    //MUX
    B_ForwardMux MFRSD_MFRTD(
        .ForwardRSD(ForwardRSD),
        .ForwardRTD(ForwardRTD),
        .RData1(RData1_D_Init),
        .RData2(RData2_D_Init),
        .M_RData(AO_M),
        .M_PC8(PC8_M),
        .SelectSource1(RData1_D),
        .SelectSource2(RData2_D));
    
    B_Cmp U_B_Cmp(
        .RData1(RData1_D),
        .RData2(RData2_D),
		.CmpSel(CmpSel),
        .zero_B(zero_B));
    //NPC
    NPCMux U_NPC(
        .Branch(Branch),
        .zero_B(zero_B),
        .Jump(Jump),
        .Source1(PC4),
        .Source2(BPC),
        .Source3(JPC),
        .Source4(JRPC),
        .SelectSource(PC_next));
    
    ext U_EXT(
        .Imm16(IR_D[`IMM16]),
        .Imm26(IR_D[`IMM26]),
        .ExtOp(ExtOp),
        .Ext_Imm32(Ext_Imm32),
        .Ext_Imm28(Ext_Imm28));
    
    ID_EXE U_ID_EXE(
        .clk(clk),
        .reset(reset),
        .clr(ID_EXE_CLR),
        .IR_In(IR_D),
        .IR_Out(IR_E),
        .PC8_In(PC8_D),
        .PC8_Out(PC8_E),
        .RData1_In(RData1_D),
        .RData1_Out(RData1_E),
        .RData2_In(RData2_D),
        .RData2_Out(RData2_E),
        .EXT_In(Ext_Imm32),
        .EXT_Out(EXT_E),
        .WriteEn_In(WriteEn_D),
        .WriteEn_Out(WriteEn_E));
    
     //E
     Func_ctrl E_Func_ctrl(
        .Op(IR_E[`OPCODE]),
        .Func(IR_E[`FUNCTION]),
        .ALUOp(ALUOp),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB));
    //E
    EX_ForwardMux MFRSE_MFRTE(
        .ForwardRSE(ForwardRSE),
        .ForwardRTE(ForwardRTE),
        .RData1(RData1_E),
        .RData2(RData2_E),
        .M_RData(AO_M),
        .M_PC8(PC8_M),
        .W_RData(WData),
        .SelectSource1(OP_A_Temp),
        .SelectSource2(OP_B_Temp));
    //A pot
    ALUSrcMux U_ALUSrcA(
        .ALUSrc(ALUSrcA),
        .Source1(OP_A_Temp),
        .Source2(OP_B_Temp),
        .SelectSource(OP_A)
        );
    //B pot
    ALUSrcMux U_ALUSrcB(
        .ALUSrc(ALUSrcB),
        .Source1(OP_B_Temp),
        .Source2(EXT_E),
        .SelectSource(OP_B));

    alu U_ALU(
        .A(OP_A),
        .B(OP_B),
        .ALUOp(ALUOp),
        .outcome(AO_E));
    
    EXE_MEM U_EXE_MEM(
        .clk(clk),
        .reset(reset),
        .IR_In(IR_E),
        .IR_Out(IR_M),
        .PC8_In(PC8_E),
        .PC8_Out(PC8_M),
        .AO_In(AO_E),
        .AO_Out(AO_M),
        .RData2_In(OP_B_Temp),
        .RData2_Out(RData2_M),
        .WriteEn_In(WriteEn_E),
        .WriteEn_Out(WriteEn_M));

    
    Func_ctrl M_Func_ctrl(
        .Op(IR_M[`OPCODE]),
        .Func(IR_M[`FUNCTION]),
        .MemWrite(MemWrite));
    
    MEM_ForwardMux MFRTM(
        .ForwardRTM(ForwardRTM),
        .RData2(RData2_M),
        .W_RData(WData),
        .SelectSource(WMData));
    
    dm U_DM(
        .clk(clk),
        .reset(reset),
        .addr(AO_M[11:2]),
        .din(WMData),
        .we(MemWrite),
        .dout(DR_M));
    
    MEM_WB U_MEM_WB(
        .clk(clk),
        .reset(reset),
        .IR_In(IR_M),
        .IR_Out(IR_W),
        .PC8_In(PC8_M),
        .PC8_Out(PC8_W),
        .AO_In(AO_M),
        .AO_Out(AO_W),
        .DR_In(DR_M),
        .DR_Out(DR_W),
        .WriteEn_In(WriteEn_M),
        .WriteEn_Out(WriteEn_W));

    
    Func_ctrl W_Func_ctrl(
        .Op(IR_W[`OPCODE]),
        .Func(IR_W[`FUNCTION]),
        .ResultToReg(ResultToReg),
        .WriteRegDst(WriteRegDst));

    
    ResultToRegMux U_ResultToReg(
        .ResultToReg(ResultToReg),
        .Source1(AO_W),
        .Source2(DR_W),
        .Source3(PC8_W),
        .SelectSource(WData));

    WriteRegMux U_WriteReg(
        .WriteRegDst(WriteRegDst),
        .Source1(IR_W[`RT]),
        .Source2(IR_W[`RD]),
        .Source3(RA),
        .SelectSource(RegWrite));
    
    Stall U_Stall(
        .IR_D(IR_D),
        .IR_E(IR_E),
        .IR_M(IR_M),
        .WriteEn_E(WriteEn_E),
        .WriteEn_M(WriteEn_M),
        .UpdateEn(UpdateEn),
        .IF_ID_EN(IF_ID_EN),
        .ID_EXE_CLR(ID_EXE_CLR)); 
    
    Forward U_Forward(
        .IR_D(IR_D),
        .IR_E(IR_E),
        .IR_M(IR_M),
        .IR_W(IR_W),
        .WriteEn_M(WriteEn_M),
        .WriteEn_W(WriteEn_W),
        .ForwardRSD(ForwardRSD),
        .ForwardRSE(ForwardRSE),
        .ForwardRTD(ForwardRTD),
        .ForwardRTE(ForwardRTE),
        .ForwardRTM(ForwardRTM));

endmodule
