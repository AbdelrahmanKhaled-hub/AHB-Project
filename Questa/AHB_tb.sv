`timescale 1ns/1ps

module AHB_tb();

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter REG_WIDTH = 8;
    parameter REG_DEPTH = 32;
    parameter GPIO_WIDTH = 8;
    parameter COUNTER_WIDTH = 32;

    // Signals declaration
    logic                       HCLK;
    logic                       HRESETn;
    logic  [31:0]               HADDR;
    logic                       HWRITE;
    logic  [31:0]               HWDATA;
    logic  [GPIO_WIDTH-1:0]     GPIO_in_portA;      
    logic  [GPIO_WIDTH-1:0]     GPIO_in_portB;      
    logic  [GPIO_WIDTH-1:0]     GPIO_in_portC;      
    logic  [GPIO_WIDTH-1:0]     GPIO_in_portD;  
    logic                       Register_File_En;
    logic                       GPIO_En;
    logic                       Timer_En;

    logic                       HREADY;
    logic                       HRESP;
    logic  [31:0]               HRDATA;
    logic [GPIO_WIDTH-1:0]     GPIO_out_portA;     
    logic [GPIO_WIDTH-1:0]     GPIO_out_portB;     
    logic [GPIO_WIDTH-1:0]     GPIO_out_portC;     
    logic [GPIO_WIDTH-1:0]     GPIO_out_portD; 

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
    AHB_wrapper #(REG_WIDTH, REG_DEPTH, GPIO_WIDTH, COUNTER_WIDTH) DUT(.*);

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
        #(2*CLK_PERIOD);

    // ------------------------------------------------
    // Register File Test cases
    // ------------------------------------------------
        Register_File_En = 1;

        // Simple Write in Address 1
        Single_Write(32'h0002_0000, 1'b1, WORD, NONSEQ, SINGLE, 32'h0000_000A);
        check_write(32'h0000_000A, 1'b1, 1'b0);
        


        // Simple Read from Address 1
        Single_Read(32'h0002_0000, 1'b0, WORD, NONSEQ, SINGLE);
        check_read(32'h0000_000A, 1'b1, 1'b0);

        // Checking HRESP signal (Writing in a byte transaction more than a byte (wd_data > 8'hFF))
        Single_Write(32'h0002_0004, 1'b1, BYTE, NONSEQ, SINGLE, 32'h0000_FFFA);
        check_write(32'h0000_FFFA, 1'b1, 1'b1);

        // Incremental Write with INCR4
        Multiple_Write_Increment(32'h0002_0008, 1'b1, WORD, NONSEQ, INCR4, 32'h0000_000C);

        // Incremental Read with INCR4
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
        GPIO_in_portA = 8'b 0000_0000;
        GPIO_in_portB = 8'b 0000_0000;
        GPIO_in_portC = 8'b 0000_0000;
        GPIO_in_portD = 8'b 0000_0000;
 

    
        // Incremental Drive output pins with INCR4
        Multiple_Write_Increment(32'h0000_0004, 1'b1, BYTE, NONSEQ, INCR4, 32'h0000_000A);
        
        // Incremental Read input pins with INCR4
        GPIO_in_portA = 8'b 1000_0011;
        GPIO_in_portB = 8'b 0111_0110;
        GPIO_in_portC = 8'b 0010_0001;
        GPIO_in_portD = 8'b 0011_0011;
        Multiple_Read_Increment(32'h0000_0000, 1'b0, BYTE, NONSEQ, INCR4);

        // Testing Response signal by driving read-only pins (wrong address)
        Single_Write(32'h0000_0000, 1'b1, BYTE, NONSEQ, SINGLE, 32'h0000_000A);
        check_write(32'h0000_000A, 1'b1, 1'b1);
        

        // Testing Response signal by reading wrong pins (wrong address)
        Single_Read(32'h0000_0004, 1'b0, BYTE, NONSEQ, SINGLE);
        check_read(32'h0000_0000, 1'b1, 1'b1);

        // Testing Response signal by driving a value greater than the valid width
        Single_Write(32'h0000_0004, 1'b1, BYTE, NONSEQ, SINGLE, 32'h0000_ABCD);
        check_write(32'h0000_ABCD, 1'b1, 1'b1);


    // ------------------------------------------------
    // Timer Test cases
    // ------------------------------------------------
        Timer_En = 1;


        // Simple Write load value to start from for the timer counter
        Single_Write(32'h0001_0000, 1'b1, WORD, NONSEQ, SINGLE, 32'h0000_000A);
        check_write(32'h0000_000A, 1'b1, 1'b0);

        // Simple Write the Mode type of the timer
        Single_Write(32'h0001_0001, 1'b1, WORD, NONSEQ, SINGLE, 32'h0000_0002);
        check_write(32'h0000_0002, 1'b1, 1'b0);

        HTRANS = IDLE;
        #(11*CLK_PERIOD);

        Single_Read(32'h0001_0000, 1'b0, WORD, NONSEQ, SINGLE);
        check_read(32'h0000_0000, 1'b1, 1'b0);


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
        HTRANS = IDLE;
        #CLK_PERIOD;
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
        HTRANS = IDLE;
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
            check_write(DATA + (32'h10 * (i-1)), 1'b1, 1'b0);
            HWDATA = HWDATA + 32'h10; // Increment data (e.g., +10)
        end
        HTRANS = IDLE;
        #CLK_PERIOD;
        check_write(DATA + (32'h10 * (i-1)), 1'b1, 1'b0);
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
        automatic int i1, i2;
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

        for (i1 = 1; i1 < wrapping_range; i1++) begin
            HADDR = HADDR + wrapping_size; // increment by word (assuming 32-bit word = 4 bytes)
            HTRANS = SEQ;
            #CLK_PERIOD;
            check_write(DATA + (32'h10 * (i1-1)), 1'b1, 1'b0);
            HWDATA = HWDATA + 32'h10; // Increment data (e.g., +100)
        end
        HADDR = HADDR - (2 * wrapping_size + 2 * wrapping_range); // increment by word (assuming 32-bit word = 4 bytes)
        for (i2 = 1; i2 < wrapping_range + 1; i2++) begin
            HTRANS = SEQ;
            #CLK_PERIOD;
            check_write(DATA + (32'h10 * (i1-1)) + (32'h10 * (i2-1)), 1'b1, 1'b0);
            HADDR = HADDR + wrapping_size;
            HWDATA = HWDATA + 32'h10; // Increment data (e.g., +10)
        end
        HTRANS = IDLE;
        #CLK_PERIOD;
        check_write(DATA + (32'h10 * (i1-1)) + (32'h10 * (i2-1)), 1'b1, 1'b0);
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

    // Check functions

    //Check write
    task check_write(
        input logic [31:0] HWDATA_expected,
        input logic        HREADY_expected,
        input logic        HRESP_expected
    );
    begin
        if (HWDATA == HWDATA_expected &&
            HRESP  == HRESP_expected  &&
            HREADY == HREADY_expected) begin
            
            $display("[%0t] write test case passed successfully", $time);
            $display("  HWDATA: %0h (expected %0h)", HWDATA, HWDATA_expected);
            $display("  HREADY: %0d (expected %0d)", HREADY, HREADY_expected);
            $display("  HRESP : %0d (expected %0d)", HRESP,  HRESP_expected);
        end
        else begin
            $display("[%0t] write test case FAILED", $time);
            $display("  HWDATA: %0h (expected %0h)", HWDATA, HWDATA_expected);
            $display("  HREADY: %0d (expected %0d)", HREADY, HREADY_expected);
            $display("  HRESP : %0d (expected %0d)", HRESP,  HRESP_expected);
        end
    end
    endtask

    // Check Read
    task check_read(
        input logic [31:0] HRDATA_expected,
        input logic        HREADY_expected,
        input logic        HRESP_expected
    );
    begin
        if (HRDATA == HRDATA_expected &&
            HRESP  == HRESP_expected  &&
            HREADY == HREADY_expected) begin
            
            $display("[%0t] Read test case passed successfully", $time);
            $display("  HRDATA: %0h (expected %0h)", HRDATA, HRDATA_expected);
            $display("  HREADY: %0d (expected %0d)", HREADY, HREADY_expected);
            $display("  HRESP : %0d (expected %0d)", HRESP,  HRESP_expected);
        end
        else begin
            $display("[%0t] write test case FAILED", $time);
            $display("  HRDATA: %0h (expected %0h)", HRDATA, HRDATA_expected);
            $display("  HREADY: %0d (expected %0d)", HREADY, HREADY_expected);
            $display("  HRESP : %0d (expected %0d)", HRESP,  HRESP_expected);
        end
    end
    endtask

endmodule
