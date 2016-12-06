`timescale 1ns / 1ps
module B_Cmp(
    RData1,RData2,zero_B,CmpSel
    );
    input [31:0] RData1;
    input [31:0] RData2;
    input CmpSel; 
    output zero_B;

    assign zero_B = CmpSel?(RData1!=RData2):(RData1==RData2);

endmodule