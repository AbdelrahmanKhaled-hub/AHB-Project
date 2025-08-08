`timescale 1ns/1ps

module Register_File #(
    parameter REG_WIDTH = 8,
    parameter REG_DEPTH = 32
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        en,                 // Slave select
    input  logic[$clog2(REG_DEPTH)-1:0] Addr,               // Address (index)
    input  logic       [1:0]            size,               // 00: byte, 01: halfword, 10: word
    input  logic                        we,                 // Write enable
    input  logic                        re,                 // Read enable
    input  logic       [31:0]           wd_data,            // Write data

    output logic       [31:0]           rd_data,            // Read data
    output logic                        done,               // HREADY equivalent
    output logic                        check               // HRESP equivalent
);

    logic [REG_WIDTH-1:0] Reg_file [REG_DEPTH-1:0];
    logic [31:0]   data_check;

    // Write + control
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            for (int i = 0; i < REG_DEPTH; i++ ) 
                Reg_file[i] <= 0;
        end else if (en) begin
            if (we) begin
                case (size)
                    2'b00:      Reg_file[Addr] <= wd_data[7:0];
                    2'b01: begin
                                Reg_file[Addr]     <=  wd_data[7:0];
                                Reg_file[Addr + 1] <= wd_data[15:8];
                    end
                    2'b10: begin
                                Reg_file[Addr]     <= wd_data[7:0]; 
                                Reg_file[Addr + 1] <= wd_data[15:8]; 
                                Reg_file[Addr + 2] <= wd_data[23:16];
                                Reg_file[Addr + 3] <= wd_data[31:24];
                    end
                    default:    Reg_file[Addr]        <= wd_data[7:0];
                endcase
            end
        end
    end

    // Combinational read logic
    always_comb begin
        if (!rst_n)
            rd_data = '0;
        else if (en && re) begin
            case (size)
                2'b00:   rd_data = Reg_file[Addr];
                2'b01:   rd_data = {Reg_file[Addr + 1], Reg_file[Addr]};
                2'b10:   rd_data = {Reg_file[Addr + 3], Reg_file[Addr + 2], Reg_file[Addr + 1], Reg_file[Addr]};
                default: rd_data = Reg_file[Addr];
            endcase
        end else
            rd_data = '0;
    end

    // always for check signal
    always_comb begin : check_block
        check = 0;

        if (rst_n && en) begin
            data_check = we ? wd_data : (re ? rd_data : 0);

            case (size)
                2'b00: check = (data_check > 8'hFF);
                2'b01: check = (data_check > 16'hFFFF);
                default: check = 0;
            endcase
        end
    end

    //always for done signal
    assign done = 1;
endmodule
