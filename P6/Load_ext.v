`timescale 1ns / 1ps
// for different load instructions
module Load_ext(
    input [3:0] BRE,
    input [31:0] DR,
    input LoadUnSign,
    output [31:0] LoadData
    );

    assign LoadData = 
    (BRE == 4'b1111)      ? DR :
    (BRE == 4'b0011)      ? (LoadUnSign ? {16'h0,DR[15:0]}:{{16{DR[15]}},DR[15:0]}) :
    (BRE == 4'b1100)      ? (LoadUnSign ? {16'h0,DR[31:16]}:{{16{DR[31]}},DR[31:16]}) :
    (BRE == 4'b0001)      ? (LoadUnSign ? {24'h0,DR[7:0]}:{{24{DR[7]}},DR[7:0]}) :
    (BRE == 4'b0010)      ? (LoadUnSign ? {24'h0,DR[15:8]}:{{24{DR[15]}},DR[15:8]}) :
    (BRE == 4'b0100)      ? (LoadUnSign ? {24'h0,DR[23:16]}:{{24{DR[23]}},DR[23:16]}) :
    (BRE == 4'b1000)      ? (LoadUnSign ? {24'h0,DR[31:24]}:{{24{DR[31]}},DR[31:24]}) : 0;


endmodule
