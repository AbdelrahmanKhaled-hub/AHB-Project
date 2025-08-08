`timescale 1ns/1ps

module GPIO #(
    parameter GPIO_WIDTH = 16  // Total GPIO pins (split: half input, half output)
)(
    input  logic                                clk,
    input  logic                                rst_n,
    input  logic                                en,                 // Slave select
    input  logic       [GPIO_WIDTH-1:0]         Addr,               // Bit-wise select mask
    input  logic       [1:0]                    size,               // 00: byte, 01: halfword, 10: word (not used)
    input  logic                                we,                 // Write enable
    input  logic                                re,                 // Read enable
    input  logic       [31:0]                   wd_data,            // Write data
    input  logic       [(GPIO_WIDTH/2)-1:0]     GPIO_in,            // Input GPIOs (from outside)
    output logic       [31:0]                   rd_data,            // Read data
    output logic       [(GPIO_WIDTH/2)-1:0]     GPIO_out,           // Output GPIOs (driven by module)
    output logic                                done,               // Always ready
    output logic                                check               // Error flag (HRESP)
);

    // Drive Output GPIO Pins (Upper Half)
    always_ff @(posedge clk or negedge rst_n) begin : GPIO_Write
        if (!rst_n) begin
            GPIO_out <= '0;
        end else if (en && we) begin
            for (int i = 0; i < (GPIO_WIDTH/2); i++) begin
                if (Addr[i + GPIO_WIDTH/2])
                    GPIO_out[i] <= wd_data[i];
            end
        end
    end

    // Generate Read Data from Input Pins (Lower Half)
    always_comb begin : GPIO_Read
        rd_data = 32'b0;
        if (en && re) begin
            for (int i = 0; i < (GPIO_WIDTH/2); i++) begin
                if (Addr[i])
                    rd_data[i] = GPIO_in[i];
            end
        end
    end

    // Generate Check Signal (HRESP-like) for invalid access
    always_comb begin : Error_Check
        check = 1'b0;

        if (en && rst_n) begin
            if (we && Addr[GPIO_WIDTH/2-1:0] != '0) begin
                check = 1'b1;  // Error: trying to write to input pins
            end
            if (re && Addr[GPIO_WIDTH-1:GPIO_WIDTH/2] != '0) begin
                check = 1'b1;  // Error: trying to read from output pins
            end
        end
    end

    // Done signal is always high
    assign done = 1'b1;

endmodule
