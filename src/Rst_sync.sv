module Rst_sync #(
    parameter STAGES = 2 // Minimum 2 for proper metastability reduction
)(
    input  logic clk,
    input  logic async_rst_n,  // Asynchronous external reset (active low)
    output logic sync_rst_n    // Synchronized reset (active low)
);

    logic [STAGES-1:0] sync_reg;

    always_ff @(posedge clk, negedge async_rst_n) begin
        if (!async_rst_n) begin
            // Synchronous assertion
            sync_reg <= '0;
        end
        else begin
            // Shift in ones for de-assertion synchronization
            sync_reg <= {sync_reg[STAGES-2:0], 1'b1};
        end
    end

    // Output is the MSB of the synchronizer chain
    assign sync_rst_n = sync_reg[STAGES-1];

endmodule
