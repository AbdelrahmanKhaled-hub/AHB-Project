`timescale 1ns/1ps

module AHB_wrapper #(
    parameter REG_WIDTH = 8,
    parameter REG_DEPTH = 32,
    parameter GPIO_WIDTH = 16
)(
    input                       HCLK,
    input                       HRESETn,
    input  [31:0]               HADDR,
    input                       HWRITE,
    input  [1:0]                HSIZE,
    input  [1:0]                HTRANS,
    input  [2:0]                HBURST,
    input  [31:0]               HWDATA,
    input  [(GPIO_WIDTH/2)-1:0] GPIO_in,
    input                       Register_File_En,
    input                       GPIO_En,

    output                      HREADY,
    output                      HRESP,
    output [31:0]               HRDATA,
    output [(GPIO_WIDTH/2)-1:0] GPIO_out
    
);

    // Internal signals
    logic               HSEL_G, HSEL_T, HSEL_R;
    logic [31:0]        gpio_rd_data, timer_rd_data, register_file_rd_data;
    logic               gpio_ready, timer_ready, register_file_ready;
    logic               gpio_response, timer_response, register_file_response;

    logic [31:0] HRDATA_G, HRDATA_T, HRDATA_R;
    logic        HREADY_G, HREADY_T, HREADY_R;
    logic        HRESP_G, HRESP_T, HRESP_R;

    logic        gpio_we, timer_we, register_file_we;
    logic        gpio_re, timer_re, register_file_re;

    logic [31:0] Addr_G;
    logic [1:0]  size_G;
    logic [31:0] wd_data_G;

    logic [31:0] Addr_T;
    logic [1:0]  size_T;
    logic [31:0] wd_data_T;

    logic [31:0] Addr_R;
    logic [1:0]  size_R;
    logic [31:0] wd_data_R;
    // -------------------------------
    // Decoder: Maps address to slave
    // -------------------------------
    Decoder AHB_Decoder_block (
        .HADDR(HADDR),
        .HSEL_G(HSEL_G),
        .HSEL_T(HSEL_T),
        .HSEL_R(HSEL_R)
    );

    // ------------------------------------------------
    // AHB Slave Interface: Register File
    // ------------------------------------------------
    AHB_slave_if AHB_Register_file_Interface_block (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HWDATA(HWDATA),

        .HSEL_P(HSEL_R),

        .peripheral_rd_data(register_file_rd_data),
        .peripheral_ready(register_file_ready),
        .peripheral_response(register_file_response),

        .HRDATA_P(HRDATA_R),

        .HREADY_P(HREADY_R),

        .HRESP_P(HRESP_R),

        .peripheral_we(register_file_we),

        .peripheral_re(register_file_re),

        .Addr(Addr_R),
        .size(size_R),
        .wd_data(wd_data_R)      
    );

    // -------------------------------------------
    // Register File Slave (Address-mapped)
    // -------------------------------------------
    Register_File #(
        .REG_WIDTH(REG_WIDTH), 
        .REG_DEPTH(REG_DEPTH)
    ) Register_File_slave (
        .clk(HCLK),
        .rst_n(HRESETn),
        .en(Register_File_En),                        
        .Addr(Addr_R[$clog2(REG_DEPTH)-1:0]),  // Extract lower index bits
        .size(size_R),
        .we(register_file_we),
        .re(register_file_re),
        .wd_data(wd_data_R),
        .rd_data(register_file_rd_data),
        .done(register_file_ready),         // Slave ready signal
        .check(register_file_response)      // Slave error response
    );

    // ------------------------------------------------
    // AHB Slave Interface: GPIO
    // ------------------------------------------------
    AHB_slave_if AHB_GPIO_Interface_block (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HWDATA(HWDATA),

        .HSEL_P(HSEL_G),

        .peripheral_rd_data(gpio_rd_data),
        .peripheral_ready(gpio_ready),
        .peripheral_response(gpio_response),

        .HRDATA_P(HRDATA_G),

        .HREADY_P(HREADY_G),

        .HRESP_P(HRESP_G),

        .peripheral_we(gpio_we),

        .peripheral_re(gpio_re),

        .Addr(Addr_G),
        .size(size_G),
        .wd_data(wd_data_G)      
    );

    // -------------------------------------------
    // GPIO Slave (Address-mapped)
    // -------------------------------------------
    GPIO #(
        .GPIO_WIDTH(GPIO_WIDTH)
    ) GPIO_slave (
        .clk(HCLK),
        .rst_n(HRESETn),
        .en(GPIO_En),                        
        .Addr(Addr_G[GPIO_WIDTH-1:0]),  
        .size(size_G),
        .we(gpio_we),
        .re(gpio_re),
        .wd_data(wd_data_G[31:0]),
        .GPIO_in(GPIO_in),
        .rd_data(gpio_rd_data[31:0]),
        .GPIO_out(GPIO_out),
        .done(gpio_ready),         // Slave ready signal
        .check(gpio_response)      // Slave error response
    );


    // ---------------------------------------
    // Multiplexer: Choose which slave returns
    // ---------------------------------------
    Mux AHB_Multiplexer_block (
        .HSEL_G(HSEL_G),
        .HSEL_T(HSEL_T),
        .HSEL_R(HSEL_R),

        .HRDATA_G(HRDATA_G),
        .HRDATA_T(HRDATA_T),
        .HRDATA_R(HRDATA_R),

        .HREADY_G(HREADY_G),
        .HREADY_T(HREADY_T),
        .HREADY_R(HREADY_R),

        .HRESP_G(HRESP_G),
        .HRESP_T(HRESP_T),   
        .HRESP_R(HRESP_R),

        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP)    
    );

endmodule
