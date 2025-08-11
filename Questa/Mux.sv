`timescale 1ns/1ps

module Mux (

    input           HSEL_G,
    input           HSEL_T,
    input           HSEL_R,

    input [31:0]    HRDATA_G,
    input [31:0]    HRDATA_T,
    input [31:0]    HRDATA_R,

    input           HREADY_G,
    input           HREADY_T,
    input           HREADY_R,

    input           HRESP_G,
    input           HRESP_T,   
    input           HRESP_R,

    output [31:0]   HRDATA,
    output          HREADY,
    output          HRESP            
);

// Mux to select the data the master reads
assign HRDATA = HSEL_G ? HRDATA_G :
                HSEL_T ? HRDATA_T :
                HSEL_R ? HRDATA_R :
                32'h0000_0000;

// Mux to select the READY info that the master needs
assign HREADY = HSEL_G ? HREADY_G :
                HSEL_T ? HREADY_T :
                HSEL_R ? HREADY_R :
                1'b1;  // default ready

// Mux to select the RESP info that the master needs
assign HRESP  = HSEL_G ? HRESP_G :
                HSEL_T ? HRESP_T :
                HSEL_R ? HRESP_R :
                1'b0;  // default: OKAY response (HRESP = 0)

endmodule