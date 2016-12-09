`timescale 1ns / 1ps
module B_Cmp(
    RData1,RData2,zero_B,CmpSel
    );
    input signed [31:0] RData1;
    input signed [31:0] RData2;
    input [2:0]CmpSel; 
    output zero_B;

    parameter BEQ = 3'h0,BNE = 3'h1,BGTZ = 3'h2,BGEZ = 3'h3,
              BLTZ = 3'h4,BLEZ = 3'h5;
    
    assign zero_B = 
    (CmpSel == BEQ)  ? (A==B):
    (CmpSel == BNE)  ? (A!=B):
    (CmpSel == BGTZ) ? (A>0) :
    (CmpSel == BGEZ) ? (A>=0):
    (CmpSel == BLTZ) ? (A<0) :
    (CmpSel == BLEZ) ? (A<=0): 0;

endmodule