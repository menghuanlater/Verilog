`timescale 1ns / 1ps

`define R_Type 7'b0000001
`define I_Type 7'b0000010
`define B_Type 7'b0000100
`define Store_Type 7'b0001000
`define Load_Type 7'b0010000
`define Jl_Type 7'b0100000
`define Jr_Type 7'b1000000

module Stall(
    D_InstrType,E_InstrType,
    M_InstrType,Update_En,RS_D,
    RT_D,RegWrite_E,RegWrite_M,
    IF_ID_EN,ID_EXE_CLR
    );
    input [6:0] D_InstrType;
    input [6:0] E_InstrType;
    input [6:0] M_InstrType;
    input [4:0] RS_D;
    input [4:0] RT_D;
    input [4:0] RegWrite_E;
    input [4:0] RegWrite_M;
    output Update_En;
    output IF_ID_EN;
    output ID_EXE_CLR;

    wire Stall_Cal_R,Stall_B,Stall_Cal_I,Stall_Load,Stall_Store_Rs,
    	Stall_Jr,Stall;

    assign Stall_Cal_R = (D_InstrType==`R_Type & E_InstrType==`Load_Type) \
    					& ((RS_D!=0 & RS_D==RegWrite_E) | (RT_D!=0 & RT_D==RegWrite_E));
    assign Stall_B = (D_InstrType==`B_Type & (E_InstrType==`R_Type | E_InstrType == `I_Type | \
    					E_InstrType==`Load_Type | E_InstrType==`Jl_Type) & ((RS_D!=0 & \ 
    					RS_D==RegWrite_E)|(RT_D!=0 & RT_D==RegWrite_E))) | \
    				 (D_InstrType==`B_Type & M_InstrType==`Load_Type & ((RS_D!=0 & RS_D== RegWrite_M)|\
    				 	(RT_D!=0 & RT_D==RegWrite_M)));
    assign Stall_Cal_I = (D_InstrType==`I_Type & E_InstrType==`Load_Type) & (RS_D!=0 & RS_D==RegWrite_E);
    assign Stall_Load = (D_InstrType==`Load_Type & E_InstrType==`Load_Type) & (RS_D!=0 & RS_D==RegWrite_E);
    assign Stall_Store_Rs = (D_InstrType==`Store_Type & E_InstrType==`Load_Type) & (RS_D!=0 & RS_D==RegWrite_E);
    assign Stall_Jr = (D_InstrType==`Jr_Type & (E_InstrType==`R_Type | E_InstrType == `I_Type | \
    					E_InstrType==`Load_Type | E_InstrType==`Jl_Type) & ((RS_D!=0 & \ 
    					RS_D==RegWrite_E)|(RT_D!=0 & RT_D==RegWrite_E))) | \
    				 (D_InstrType==`Jr_Type & M_InstrType==`Load_Type & ((RS_D!=0 & RS_D== RegWrite_M)|\
    				 	(RT_D!=0 & RT_D==RegWrite_M)));
    assign Stall = Stall_Cal_R|Stall_Cal_I|Stall_B|Stall_Load|Stall_Store_Rs|Stall_Jr;

    assign Update_En = !Stall;
    assign IF_ID_EN = !Stall;
    assign ID_EXE_CLR = Stall;
	

endmodule

module Forward(
    D_InstrType,E_InstrType,M_InstrType,W_InstrType,
    RS_D,RT_D,RS_E,RT_E,RT_M,RegWrite_M,RegWrite_W,
    ForwardRSD,ForwardRTD,ForwardRSE,ForwardRTE,ForwardRTM
    );
    input [6:0] D_InstrType;
    input [6:0] E_InstrType;
    input [6:0] M_InstrType;
    input [6:0] W_InstrType;
    input [4:0] RS_D;
    input [4:0] RT_D;
    input [4:0] RS_E;
    input [4:0] RT_E;
    input [4:0] RT_M;
    input [4:0] RegWrite_M;
    input [4:0] RegWrite_W;
    output [1:0] ForwardRSD;
    output [1:0] ForwardRTD;
    output [1:0] ForwardRSE;
    output [1:0] ForwardRTE;
    output ForwardRTM;

    parameter In_Zero = 2'b00,In_One = 2'b01,In_Two = 2'b10, In_Three = 2'b11;
    //for Decoder
    assign ForwardRSD = ((D_InstrType==`B_Type | D_InstrType==`Jr_Type) & M_InstrType!=`Jl_Type \
                             & RS_D!=0 & RS_D==RegWrite_M)?2'b01:
                        ((D_InstrType==`B_Type | D_InstrType==`Jr_Type) & M_InstrType==`Jl_Type \
                             & RS_D!=0 & RS_D==RegWrite_M)?2'b10:2'b00;
    assign ForwardRTD = ((D_InstrType==`B_Type | D_InstrType==`Jr_Type) & M_InstrType!=`Jl_Type \
                             & RT_D!=0 & RT_D==RegWrite_M)?2'b01:
                        ((D_InstrType==`B_Type | D_InstrType==`Jr_Type) & M_InstrType==`Jl_Type \
                             & RT_D!=0 & RT_D==RegWrite_M)?2'b10:2'b00;

    //for Execute
    assign ForwardRSE = (E_InstrType==`R_Type | E_InstrType==`I_Type | E_InstrType==`Load_Type | E_InstrType==`Store_Type)\
                        & (W_InstrType==`R_Type | W_InstrType==`I_Type | W_InstrType==`Jl_Type | W_InstrType==`Load_Type) \
                        & (RS_E!=0 & RS_E==RegWrite_W)?2'b01:
                        (E_InstrType==`R_Type | E_InstrType==`I_Type | E_InstrType==`Load_Type | E_InstrType==`Store_Type)\
                        & (M_InstrType==`R_Type | M_InstrType==`I_Type) \
                        & (RS_E!=0 & RS_E==RegWrite_M)?2'b10:
                        (E_InstrType==`R_Type | E_InstrType==`I_Type | E_InstrType==`Load_Type | E_InstrType==`Store_Type)\
                        & (M_InstrType==`Jl_Type) & (RS_E!=0 & RS_E==RegWrite_M)?2'b11:2'b00;
    assign ForwardRTE = (E_InstrType==`R_Type | E_InstrType==`Store_Type)\
                        & (W_InstrType==`R_Type | W_InstrType==`I_Type | W_InstrType==`Jl_Type | W_InstrType==`Load_Type) \
                        & (RT_E!=0 & RT_E==RegWrite_W)?2'b01:
                        (E_InstrType==`R_Type | E_InstrType==`Store_Type) & (M_InstrType==`R_Type | M_InstrType==`I_Type) \
                        & (RT_E!=0 & RT_E==RegWrite_M)?2'b10:
                        (E_InstrType==`R_Type | E_InstrType==`Store_Type)\
                        & (M_InstrType==`Jl_Type) & (RT_E!=0 & RT_E==RegWrite_M)?2'b11:2'b00;

    //for Memory
    assign ForwardRTM = (M_InstrType==`Store_Type & RegWrite_W & RT_M!=0 & RT_M==RegWrite_W); 

endmodule