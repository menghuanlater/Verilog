`timescale 1ns / 1ps

`define OPCODE 31:26
`define RS 25:21
`define RT 20:16
`define BID 20:16
`define RD 15:11
`define FUNCTION 5:0

////////////////instructions///////
`define ADD   12'b000000_100000
`define ADDI  6'b001000
`define ADDIU 6'b001001
`define ADDU  12'b000000_100001
`define AND   12'b000000_100100
`define ANDI  6'b001100
`define BEQ   6'b000100
`define BGEZ  11'b000001_00001
`define BGTZ  11'b000111_00000
`define BLEZ  11'b000110_00000
`define BLTZ  11'b000001_00000
`define BNE   6'b000101
`define DIV   12'b000000_011010
`define DIVU  12'b000000_011011
`define J     6'b000010
`define JAL   6'b000011
`define JR    12'b000000_001000
`define JALR  12'b000000_001001
`define LUI   6'b001111
`define LW    6'b100011
`define OR    12'b000000_100101
`define ORI   6'b001101
`define SLL   12'b000000_000000
`define SRL   12'b000000_000010
`define SUB   12'b000000_100010
`define SUBU  12'b000000_100011
`define SW    6'b101011
`define XOR   12'b000000_100110
`define XORI  6'b001110
`define LB    6'b100000
`define LBU   6'b100100
`define LH    6'b100001
`define LHU   6'b100101
`define MFHI  12'b000000_010000
`define MFLO  12'b000000_010010
`define MTHI  12'b000000_010001
`define MTLO  12'b000000_010011
`define MULT  12'b000000_011000
`define MULTU 12'b000000_011001
`define NOR   12'b000000_100111
`define SB    6'b101000
`define SH    6'b101001
`define SLLV  12'b000000_000100
`define SLT   12'b000000_101010
`define SLTI  6'b001010
`define SLTIU 6'b001011
`define SLTU  12'b000000_101011
`define SRA   12'b000000_000011
`define SRAV  12'b000000_000111
`define SRLV  12'b000000_000110
////************************///////

////instruction Types//////////////
`define CAL_R 8'h01
`define CAL_I 8'h02
`define BNL   8'h03
`define LOAD  8'h04
`define STORE 8'h05
`define _JR   8'h06
`define _JAL  8'h07
`define BL    8'h08
`define _JALR 8'h09
///////////////////////////////////

module Stall(
    input [31:0] IR_D,
    input [31:0] IR_E,
    input [31:0] IR_M,
    input WriteEn_E,
    input WriteEn_M,
    output UpdateEn,
    output IF_ID_EN,
    output ID_EXE_CLR
    );
    //to recognize instr types
    wire [7:0] D_Type; InstrType One(IR_D,D_Type);
    wire [7:0] E_Type; InstrType two(IR_E,E_Type);
    wire [7:0] M_Type; InstrType three(IR_M,M_Type);

    //to realize stall function
    wire Stall_BNL_Rs,Stall_BNL_Rt;  //for BNL
    wire Stall_CAL_R_Rs,Stall_CAL_R_Rt; //for CAL_R
    wire Stall_CAL_I_Rs; //for CAL_I
    wire Stall_LOAD_Rs;  // for LOAD
    wire Stall_STORE_Rs; //for STORE
    wire Stall_JR_Rs;    //for _JR
    wire Stall_JALR_Rs; //for _JALR

    assign Stall_BNL_Rs = 
    (D_Type == `BNL & E_Type == `CAL_R & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RD] & WriteEn_E) | 
    (D_Type == `BNL & E_Type == `CAL_I & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) |
    (D_Type == `BNL & E_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) | 
    (D_Type == `BNL & M_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RT] & WriteEn_M);

    assign Stall_BNL_Rt = 
    (D_Type == `BNL & E_Type == `CAL_R & IR_D[`RT]!=0 & IR_D[`RT] == IR_E[`RD] & WriteEn_E) |
    (D_Type == `BNL & E_Type == `CAL_I & IR_D[`RT]!=0 & IR_D[`RT] == IR_E[`RT] & WriteEn_E) |
    (D_Type == `BNL & E_Type == `LOAD  & IR_D[`RT]!=0 & IR_D[`RT] == IR_E[`RT] & WriteEn_E) | 
    (D_Type == `BNL & M_Type == `LOAD  & IR_D[`RT]!=0 & IR_D[`RT] == IR_M[`RT] & WriteEn_M);

    assign Stall_CAL_R_Rs =
    (D_Type == `CAL_R & E_Type == `LOAD & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E);

    assign Stall_CAL_R_Rt =
    (D_Type == `CAL_R & E_Type == `LOAD & IR_D[`RT]!=0 & IR_D[`RT] == IR_E[`RT] & WriteEn_E);

    assign Stall_CAL_I_Rs =
    (D_Type == `CAL_I & E_Type == `LOAD & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E);
    
    assign Stall_LOAD_Rs  =
    (D_Type == `LOAD  & E_Type == `LOAD & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E);

    assign Stall_STORE_Rs =
    (D_Type == `STORE & E_Type == `LOAD & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E);

    assign Stall_JR_Rs = 
    (D_Type == `_JR & E_Type == `CAL_R & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RD] & WriteEn_E) | 
    (D_Type == `_JR & E_Type == `CAL_I & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) |
    (D_Type == `_JR & E_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) | 
    (D_Type == `_JR & M_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RT] & WriteEn_M);

    assign Stall_JALR_Rs = 
    (D_Type == `_JALR & E_Type == `CAL_R & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RD] & WriteEn_E) |
    (D_Type == `_JALR & E_Type == `CAL_I & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) |
    (D_Type == `_JALR & E_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_E[`RT] & WriteEn_E) | 
    (D_Type == `_JALR & M_Type == `LOAD  & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RT] & WriteEn_M);
    
    //charge some signals
    wire Stall; 
    assign Stall = Stall_BNL_Rs | Stall_BNL_Rt | Stall_CAL_R_Rs | Stall_CAL_R_Rt | Stall_CAL_I_Rs |
    Stall_LOAD_Rs | Stall_STORE_Rs | Stall_JR_Rs | Stall_JALR_Rs;
    assign UpdateEn = !Stall;
    assign IF_ID_EN = !Stall;
    assign ID_EXE_CLR = Stall;
	

endmodule

module Forward(
    input [31:0] IR_D,
    input [31:0] IR_E,
    input [31:0] IR_M,
    input [31:0] IR_W,
    input WriteEn_M,
    input WriteEn_W,
    output [1:0] ForwardRSD,
    output [1:0] ForwardRTD,
    output [1:0] ForwardRSE,
    output [1:0] ForwardRTE,
    output ForwardRTM
    );
    
    wire [7:0] D_Type; InstrType four(IR_D,D_Type);
    wire [7:0] E_Type; InstrType five(IR_E,E_Type);
    wire [7:0] M_Type; InstrType six(IR_M,M_Type);
    wire [7:0] W_Type; InstrType seven(IR_W,W_Type);

    parameter FR_INIT = 2'b00,FR_AO = 2'b01,FR_PC8 = 2'b10, FR_WB = 2'b11;
   
    //for Decoder 
    assign ForwardRSD = !(D_Type == `BNL | D_Type == `_JR | D_Type == `_JALR) ? 0 :
    (M_Type == `CAL_R & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RD] & WriteEn_M) ? 2'b01 :
    (M_Type == `CAL_I & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RT] & WriteEn_M) ? 2'b01 :
    (M_Type == `_JAL  & IR_D[`RS]!=0 & IR_D[`RS] == 5'h1f     & WriteEn_M) ? 2'b10 :
    (M_Type == `_JALR & IR_D[`RS]!=0 & IR_D[`RS] == IR_M[`RD] & WriteEn_M) ? 2'b10 : 0;    
   
    //FOR Decoder 
    assign ForwardRTD = !(D_Type == `BNL) ? 0 :
    (M_Type == `CAL_R & IR_D[`RT]!=0 & IR_D[`RT] == IR_M[`RD] & WriteEn_M) ? 2'b01 :
    (M_Type == `CAL_I & IR_D[`RT]!=0 & IR_D[`RT] == IR_M[`RT] & WriteEn_M) ? 2'b01 :
    (M_Type == `_JAL  & IR_D[`RT]!=0 & IR_D[`RT] == 5'h1f     & WriteEn_M) ? 2'b10 :
    (M_Type == `_JALR & IR_D[`RT]!=0 & IR_D[`RT] == IR_M[`RD] & WriteEn_M) ? 2'b10 : 0;

    //for Execute
    assign ForwardRSE = !(E_Type == `CAL_R | E_Type == `CAL_I | E_Type == `LOAD | E_Type == `STORE) ? 0 :
    (M_Type == `CAL_R & IR_E[`RS]!=0 & IR_E[`RS] == IR_M[`RD] & WriteEn_M) ? 2'b01 :
    (M_Type == `CAL_I & IR_E[`RS]!=0 & IR_E[`RS] == IR_M[`RT] & WriteEn_M) ? 2'b01 :
    (M_Type == `_JAL  & IR_E[`RS]!=0 & IR_E[`RS] == 5'h1f     & WriteEn_M) ? 2'b10 :
    (M_Type == `_JALR & IR_E[`RS]!=0 & IR_E[`RS] == IR_M[`RD] & WriteEn_M) ? 2'b10 :
    (W_Type == `CAL_R & IR_E[`RS]!=0 & IR_E[`RS] == IR_W[`RD] & WriteEn_W) ? 2'b11 :
    (W_Type == `CAL_I & IR_E[`RS]!=0 & IR_E[`RS] == IR_W[`RT] & WriteEn_W) ? 2'b11 :
    (W_Type == `_JAL  & IR_E[`RS]!=0 & IR_E[`RS] == 5'h1f     & WriteEn_W) ? 2'b11 :
	(W_Type == `_JALR & IR_E[`RS]!=0 & IR_E[`RS] == IR_W[`RD] & WriteEn_W) ? 2'b11 :
    (W_Type == `LOAD  & IR_E[`RS]!=0 & IR_E[`RS] == IR_W[`RT] & WriteEn_W) ? 2'b11 : 0;
    

    //for Execute
    assign ForwardRTE = !(E_Type == `CAL_R | E_Type == `STORE) ? 0 :
    (M_Type == `CAL_R & IR_E[`RT]!=0 & IR_E[`RT] == IR_M[`RD] & WriteEn_M) ? 2'b01 :
    (M_Type == `CAL_I & IR_E[`RT]!=0 & IR_E[`RT] == IR_M[`RT] & WriteEn_M) ? 2'b01 :
    (M_Type == `_JAL  & IR_E[`RT]!=0 & IR_E[`RT] == 5'h1f     & WriteEn_M) ? 2'b10 :
    (M_Type == `_JALR & IR_E[`RT]!=0 & IR_E[`RT] == IR_M[`RD] & WriteEn_M) ? 2'b10 :
    (W_Type == `CAL_R & IR_E[`RT]!=0 & IR_E[`RT] == IR_W[`RD] & WriteEn_W) ? 2'b11 :
    (W_Type == `CAL_I & IR_E[`RT]!=0 & IR_E[`RT] == IR_W[`RT] & WriteEn_W) ? 2'b11 :
    (W_Type == `_JAL  & IR_E[`RT]!=0 & IR_E[`RT] == 5'h1f     & WriteEn_W) ? 2'b11 :
    (W_Type == `_JALR & IR_E[`RT]!=0 & IR_E[`RT] == IR_W[`RD] & WriteEn_W) ? 2'b11 :
	(W_Type == `LOAD  & IR_E[`RT]!=0 & IR_E[`RT] == IR_W[`RT] & WriteEn_W) ? 2'b11 : 0;

    //for Memory
    assign ForwardRTM = !(M_Type == `STORE) ? 0 :
    (W_Type == `CAL_R & IR_M[`RT]!=0 & IR_M[`RT] == IR_W[`RD] & WriteEn_W) ?     1 : 
    (W_Type == `CAL_I & IR_M[`RT]!=0 & IR_M[`RT] == IR_W[`RT] & WriteEn_W) ?     1 :
    (W_Type == `_JAL  & IR_M[`RT]!=0 & IR_M[`RT] == 5'h1f     & WriteEn_W) ?     1 :
    (W_Type == `_JALR & IR_M[`RT]!=0 & IR_M[`RT] == IR_W[`RD] & WriteEn_W) ?     1 : 
	(W_Type == `LOAD  & IR_M[`RT]!=0 & IR_M[`RT] == IR_W[`RT] & WriteEn_W) ? 	 1 : 0;

endmodule

//identify the type of an instruction
module InstrType(
    input [31:0] IR,
    output [7:0] Type
    );
    //j doesn't need!
    assign Type = 
    {IR[`OPCODE],IR[`FUNCTION]} == `ADD   ? `CAL_R :
    {IR[`OPCODE]}               == `ADDI  ? `CAL_I :
    {IR[`OPCODE]}               == `ADDIU ? `CAL_I :
    {IR[`OPCODE],IR[`FUNCTION]} == `ADDU  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `AND   ? `CAL_R :
    {IR[`OPCODE]}               == `ANDI  ? `CAL_I :
    {IR[`OPCODE]}               == `BEQ   ? `BNL   :
    {IR[`OPCODE]}               == `BNE   ? `BNL   :
    {IR[`OPCODE],IR[`BID]}      == `BGTZ  ? `BNL   :
    {IR[`OPCODE],IR[`BID]}      == `BGEZ  ? `BNL   :
    {IR[`OPCODE],IR[`BID]}      == `BLTZ  ? `BNL   :
    {IR[`OPCODE],IR[`BID]}      == `BLEZ  ? `BNL   :
    {IR[`OPCODE]}               == `JAL   ? `_JAL  :
    {IR[`OPCODE],IR[`FUNCTION]} == `JR    ? `_JR   :
    {IR[`OPCODE],IR[`FUNCTION]} == `JALR  ? `_JALR :
    {IR[`OPCODE]}               == `LUI   ? `CAL_I :
    {IR[`OPCODE]}               == `LW    ? `LOAD  :
    {IR[`OPCODE]}               == `LB    ? `LOAD  :
    {IR[`OPCODE]}               == `LBU   ? `LOAD  :
    {IR[`OPCODE]}               == `LH    ? `LOAD  :
    {IR[`OPCODE]}               == `LHU   ? `LOAD  :
    {IR[`OPCODE],IR[`FUNCTION]} == `OR    ? `CAL_R :
    {IR[`OPCODE]}               == `ORI   ? `CAL_I :
    {IR[`OPCODE],IR[`FUNCTION]} == `SUB   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SUBU  ? `CAL_R :
    {IR[`OPCODE]}               == `SW    ? `STORE :
    {IR[`OPCODE]}               == `SB    ? `STORE :
    {IR[`OPCODE]}               == `SH    ? `STORE :
    {IR[`OPCODE],IR[`FUNCTION]} == `XOR   ? `CAL_R :
    {IR[`OPCODE]}               == `XORI  ? `CAL_I :
    {IR[`OPCODE],IR[`FUNCTION]} == `NOR   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SLL   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SLLV  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SRL   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SRLV  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SRA   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SRAV  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `SLT   ? `CAL_R :
    {IR[`OPCODE]}               == `SLTI  ? `CAL_I :
    {IR[`OPCODE],IR[`FUNCTION]} == `SLTU  ? `CAL_R :
    {IR[`OPCODE]}               == `SLTIU ? `CAL_I :
    {IR[`OPCODE],IR[`FUNCTION]} == `MULT  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `MULTU ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `DIV   ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `DIVU  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `MFHI  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `MFLO  ? `CAL_R :
    {IR[`OPCODE],IR[`FUNCTION]} == `MTHI  ? `CAL_I :    //we can  control writeEn to realize
    {IR[`OPCODE],IR[`FUNCTION]} == `MTLO  ? `CAL_I : 0; //we can  control writeEn to realize
    


endmodule