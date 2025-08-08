module Timer #(
    parameter COUNTER_WIDTH = 32
)(
    input                               clk,
    input                               rst_n,
    input                               en,                 // Slave select
    input       [31:0]                  ADDR,               // Address (unused here)
    input       [31:0]                  load,               // Write data
    input                               we,                 // Write enable
    input                               re,                 // Read enable
    input       [1:0]                   size,               // 00: byte, 01: halfword, 10: word

    output      [31:0]                  counter_value,      // Output
    output                              done,               // HREADY equivalent
    output                              check               // HRESP equivalent
);

    logic [COUNTER_WIDTH-1:0] counter;
    logic wait_cycle;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter       <= 0;
            counter_value <= 0;
            done          <= 1;
            check         <= 0;
            wait_cycle    <= 0;

        end else if (en) begin
            if (we) begin
                if (wait_cycle) begin
                    // Parity check only over valid bits written
                    case (size)
                        2'b00:   check <= ~(^counter[6:0] == load[7]);
                        2'b01:   check <= ~(^counter[14:0] == load[15]);
                        2'b10:   check <= ~(^counter[30:0] == load[31]);
                        default: check <= 0;
                    endcase
                    done       <= 1;
                    wait_cycle <= 0;

                end else begin
                    // Load counter
                    case (size)
                        2'b00:   counter <= {25'h000000, load[6:0]};
                        2'b01:   counter <= {17'h0000, load[14:0]};
                        2'b10:   counter <= {1'b0, load[30:0]};  
                        default: counter <= {{(33-COUNTER_WIDTH){1'b0}}, load[COUNTER_WIDTH-2:0]};
                    endcase
                    done       <= 0;
                    wait_cycle <= 1;
                end

            end else if (re) begin
                case (size)
                    2'b00:   counter_value <= {24'h000000, (^counter[6:0]), counter[6:0] };
                    2'b01:   counter_value <= {16'h0000, (^counter[14:0]), counter[14:0] };
                    2'b10:   counter_value <= {(^counter[30:0]), counter[30:0]};
                    default: counter_value <= {{(32-COUNTER_WIDTH){1'b0}},(^counter[COUNTER_WIDTH-2:0]), counter[COUNTER_WIDTH-2:0]};
                endcase
                done       <= 1;
                check      <= 0;
                wait_cycle <= 0;   

            end else if (counter > 0) //control
                counter <= counter - 1;
        end 
    end
endmodule
