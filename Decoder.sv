`timescale 1ns/1ps

module Decoder(
    input [31:0]    HADDR,
    output          HSEL_G,
    output          HSEL_T,
    output          HSEL_R
);

// Address decode logic for slave selection
assign HSEL_G = (HADDR[31:16] == 16'h0000);  //(32'h0000 0000 -> 32'h0000 FFFF)
assign HSEL_T = (HADDR[31:16] == 16'h0001);  //(32'h0001 0000 -> 32'h0001 FFFF)
assign HSEL_R = (HADDR[31:16] == 16'h0002);  //(32'h0002 0000 -> 32'h0002 FFFF)

endmodule