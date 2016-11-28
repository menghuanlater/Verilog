`timescale 1ns / 1ps
module B_Cmp(
    RData1,RData2,equal
    );
    input [31:0] RData1;
    input [31:0] RData2;
    output equal;

    assign equal = (RData1==RData2)?1:0; 

endmodule