`timescale 1ns/1ps

module AHB_tb();

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter REG_WIDTH = 8;
    parameter REG_DEPTH = 32;
    parameter GPIO_WIDTH = 16;

    // Signals declaration
    logic                       HCLK;
    logic                       HRESETn;
    logic  [31:0]               HADDR;
    logic                       HWRITE;
    logic  [31:0]               HWDATA;
    logic  [(GPIO_WIDTH/2)-1:0] GPIO_in;
    logic                       Register_File_En;
    logic                       GPIO_En;

    logic                       HREADY;
    logic                       HRESP;
    logic  [31:0]               HRDATA;
    logic  [(GPIO_WIDTH/2)-1:0] GPIO_out;

    // HTRANS declaration
    typedef enum logic [1:0] {IDLE, BUSY, NONSEQ, SEQ} Transfer_state;
    Transfer_state HTRANS;

    // HBURST declaration
    typedef enum logic [2:0] {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} Burst_state;
    Burst_state HBURST;

    // HSIZE declaration
    typedef enum logic [1:0] {BYTE, HALFWORD, WORD} Size_state;
    Size_state HSIZE;

    // DUT instantiation
    AHB_wrapper #(REG_WIDTH, REG_DEPTH, GPIO_WIDTH) DUT(.*);

    // Clock generation
    initial begin
        HCLK = 0;
        forever #(CLK_PERIOD/2) HCLK = ~HCLK;
    end

    // Test sequence
    initial begin

        $dumpfile("AHB_Lite.vcd");
        $dumpvars(0,AHB_tb);
        
        // Reset the Design
        HRESETn = 0;
        #CLK_PERIOD;
        HRESETn = 1;

    // ------------------------------------------------
    // Register File Test cases
    // ------------------------------------------------
        Register_File_En = 1;

        // Simple Write in Address 1
        Single_Write(32'h0002_0000, 1'b1, WORD, NONSEQ, SINGLE, 32'h0000_000A);

        // Simple Read from Address 1
        Single_Read(32'h0002_0000, 1'b0, WORD, NONSEQ, SINGLE);

        // Checking HRESP signal (Writing in a byte transaction more than a byte (wd_data > 8'hFF))
        Single_Write(32'h0002_0004, 1'b1, BYTE, NONSEQ, SINGLE, 32'h0000_FFFA);

        // Incremental Write with INCR4
        Multiple_Write_Increment(32'h0002_0008, 1'b1, WORD, NONSEQ, INCR4, 32'h0000_000C);

        // Incremental Write with INCR4
        Multiple_Read_Increment(32'h0002_0008, 1'b0, WORD, NONSEQ, INCR4);

        // Wrapping write with WRAP4
        Multiple_Write_Wrapping(32'h0002_0008, 1'b1, WORD, NONSEQ, WRAP4, 32'h0000_000D);

        // Wrapping read with WRAP4
        Multiple_Read_Wrapping(32'h0002_0008, 1'b0, WORD, NONSEQ, WRAP4);

        Register_File_En = 0;

        #(2*CLK_PERIOD);

    // ------------------------------------------------
    // GPIO Test cases
    // ------------------------------------------------
        GPIO_En = 1;
        GPIO_in = 8'b 0000_0000;
 
        // Simple Drive to the 5 output pins Address: (16'b 1000_1111_xxxx_xxxx)
        Single_Write(16'h8F00, 1'b1, BYTE, NONSEQ, SINGLE, 8'b1000_1010); 

        GPIO_in = 8'b 1111_0100;
        // Checking HRESP signal (Driving the pins while writing a wrong address)
        Single_Write(16'h0025, 1'b1, BYTE, NONSEQ, SINGLE, 8'b1000_1010); 

        // Simple Read the 8 input pins Address: (16'b xxxx_xxxx_1111_1111)
        Single_Read(16'h00FF, 1'b0, BYTE, NONSEQ, SINGLE);

        // Checking HRESP signal (Read driven pins while writing a wrong address)
        Single_Read(16'h5600, 1'b0, BYTE, NONSEQ, SINGLE);
        HTRANS = IDLE;

        #(2*CLK_PERIOD);
        $stop;
        $finish;
    end

    // Write Task
    task Single_Write(
        input logic [31:0]      Address,
        input logic             Write,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type,
        input logic [31:0]      DATA
    );
    begin
        HADDR  = Address;
        HWRITE = Write;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;
        HWDATA = DATA;
    end
    endtask

    // Read Task
    task Single_Read(
        input logic [31:0]      Address,
        input logic             Readn,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type
    );
    begin
        HADDR  = Address;
        HWRITE = Readn;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;
    end
    endtask

    // Multiple Write Task with Burst increment
    task automatic Multiple_Write_Increment(
        input logic [31:0]      Address,
        input logic             Write,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type,
        input logic [31:0]      DATA
    );
        automatic int i;
        automatic int increment_range;
        automatic int increment_size;

    begin
        case (BURST_type)
            INCR4, WRAP4:   increment_range = 4;
            INCR8, WRAP8:   increment_range = 8;
            INCR16, WRAP16: increment_range = 16;
        endcase

        case (Size)
            BYTE:           increment_size = 1;
            HALFWORD:       increment_size = 2;
            WORD:           increment_size = 4;            
        endcase

        HADDR  = Address;
        HWRITE = Write;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;
        HWDATA = DATA;

        for (i = 1; i < increment_range; i++) begin
            HADDR = HADDR + increment_size; // increment by word (assuming 32-bit word = 4 bytes)
            HTRANS = SEQ;
            #CLK_PERIOD;
            HWDATA = HWDATA + 32'h64; // Increment data (e.g., +100)
        end
        HTRANS = IDLE;
        #CLK_PERIOD;
    end
    endtask

    // Multiple Read Task with Burst increment
    task automatic Multiple_Read_Increment(
        input logic [31:0]      Address,
        input logic             Readn,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type
    );
        automatic int i;
        automatic int increment_range;
        automatic int increment_size;

    begin
        case (BURST_type)
            INCR4:   increment_range = 4;
            INCR8:   increment_range = 8;
            INCR16: increment_range = 16;
        endcase

        case (Size)
            BYTE:           increment_size = 1;
            HALFWORD:       increment_size = 2;
            WORD:           increment_size = 4;            
        endcase

        HADDR  = Address;
        HWRITE = Readn;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;

        for (i = 1; i < increment_range; i++) begin
            HADDR = HADDR + increment_size; // increment by word (assuming 32-bit word = 4 bytes)
            HTRANS = SEQ;
            #CLK_PERIOD;
        end
        HTRANS = IDLE;
        #CLK_PERIOD;
    end
    endtask

    // Multiple Write Task with Burst wrapping
    task automatic Multiple_Write_Wrapping(
        input logic [31:0]      Address,
        input logic             Write,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type,
        input logic [31:0]      DATA
    );
        automatic int i;
        automatic int wrapping_range;
        automatic int wrapping_size;

    begin
        case (BURST_type)
            WRAP4:   wrapping_range = 2;
            WRAP8:   wrapping_range = 4;
            WRAP16: wrapping_range  = 8;
        endcase

        case (Size)
            BYTE:           wrapping_size = 1;
            HALFWORD:       wrapping_size = 2;
            WORD:           wrapping_size = 4;            
        endcase

        HADDR  = Address;
        HWRITE = Write;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;
        HWDATA = DATA;

        for (i = 1; i < wrapping_range; i++) begin
            HADDR = HADDR + wrapping_size; // increment by word (assuming 32-bit word = 4 bytes)
            HTRANS = SEQ;
            #CLK_PERIOD;
            HWDATA = HWDATA + 32'h64; // Increment data (e.g., +100)
        end
        HADDR = HADDR - (2 * wrapping_size + 2 * wrapping_range); // increment by word (assuming 32-bit word = 4 bytes)
        for (i = 1; i < wrapping_range + 1; i++) begin
            HTRANS = SEQ;
            #CLK_PERIOD;
            HADDR = HADDR + wrapping_size;
            HWDATA = HWDATA + 32'h64; // Increment data (e.g., +100)
        end
        HTRANS = IDLE;
        #CLK_PERIOD;
    end
    endtask

    // Multiple Read Task with Burst wrapping
    task automatic Multiple_Read_Wrapping(
        input logic [31:0]      Address,
        input logic             Readn,
        input Size_state        Size,
        input Transfer_state    transfer_type,
        input Burst_state       BURST_type
    );
        automatic int i;
        automatic int wrapping_range;
        automatic int wrapping_size;

    begin
        case (BURST_type)
            WRAP4:   wrapping_range = 2;
            WRAP8:   wrapping_range = 4;
            WRAP16: wrapping_range  = 8;
        endcase

        case (Size)
            BYTE:           wrapping_size = 1;
            HALFWORD:       wrapping_size = 2;
            WORD:           wrapping_size = 4;            
        endcase

        HADDR  = Address;
        HWRITE = Readn;
        HSIZE  = Size;
        HTRANS = transfer_type;
        HBURST = BURST_type;
        #CLK_PERIOD;

        for (i = 1; i < wrapping_range; i++) begin
            HADDR = HADDR + wrapping_size; // increment by word (assuming 32-bit word = 4 bytes)
            HTRANS = SEQ;
            #CLK_PERIOD;
        end
        HADDR = HADDR - (2 * wrapping_size + 2 * wrapping_range); // increment by word (assuming 32-bit word = 4 bytes)
        for (i = 1; i < wrapping_range + 1; i++) begin
            HTRANS = SEQ;
            #CLK_PERIOD;
            HADDR = HADDR + wrapping_size;
        end

        HTRANS = IDLE;
        #CLK_PERIOD;
    end
    endtask
endmodule
