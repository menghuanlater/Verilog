`timescale 1ns / 1ps

module IF_ID(
    IR_In,IR_Out,
    PC8_In,PC8_Out,
    clk,en,
    );
    input clk;
    input en;
    input [31:0] IR_In;
    input [31:0] PC8_In;
    output [31:0] IR_Out;
    output [31:0] PC8_Out;

    reg [31:0] D_IR;
    reg [31:0] D_PC8;

    assign IR_Out = D_IR;
    assign PC8_Out = D_PC8;

    initial begin
        D_IR = 0;
        D_PC8 = 0;
    end

    always @(posedge clk ) begin
        if(en)begin
            D_IR <= IR_In;
            D_PC8 <= PC8_In;
        end
    end

endmodule
