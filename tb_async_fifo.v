`timescale 1ns / 1ps

module async_fifo_tb;

    parameter DATA_WIDTH = 16;
    parameter DEPTH = 8;
    parameter ADDR_WIDTH = 4;

    reg rd_clk = 0;
    reg wr_clk = 0;
    reg rst_n;
    reg rd_en;
    reg wr_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire data_valid;
    wire fifo_empty;
    wire fifo_full;

    // Instantiate DUT
    async_fifo_top #( 
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .rd_clk(rd_clk),
        .wr_clk(wr_clk),
        .rst_n(rst_n),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .data_in(data_in),
        .data_out(data_out),
        .data_valid(data_valid),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full)
    );

    // Clocks
    always #5 wr_clk = ~wr_clk;  // 100 MHz
    always #7 rd_clk = ~rd_clk;  // ~71 MHz

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        rd_en = 0;
        wr_en = 0;
        data_in = 16'h0000;
        #50;
        rst_n = 1;
        #50;

        $display("---- Scenario 1: WRITE UNTIL FULL ----");
        repeat (DEPTH + 4) begin
            @(posedge wr_clk);
            if (!fifo_full) begin
                wr_en <= 1;
                data_in <= data_in + 1;
            end else begin
                wr_en <= 0;
            end
        end
        wr_en <= 0;

        #100;

        $display("---- Scenario 2: READ UNTIL EMPTY ----");
        repeat (DEPTH + 4) begin
            @(posedge rd_clk);
            if (!fifo_empty)
                rd_en <= 1;
            else
                rd_en <= 0;
        end
        rd_en <= 0;

        #100;

        $display("---- Scenario 3: SIMULTANEOUS WRITE/READ ----");
        repeat (20) begin
            @(posedge wr_clk);
            if (!fifo_full) begin
                wr_en <= 1;
                data_in <= data_in + 1;
            end else begin
                wr_en <= 0;
            end

            @(posedge rd_clk);
            if (!fifo_empty)
                rd_en <= 1;
            else
                rd_en <= 0;
        end
        wr_en <= 0;
        rd_en <= 0;

        #100;

        $display("---- Scenario 4: READ WHEN EMPTY ----");
        repeat (4) begin
            @(posedge rd_clk);
            rd_en <= 1;
        end
        rd_en <= 0;

        #50;

        $display("---- Scenario 5: WRITE WHEN FULL ----");
        repeat (DEPTH) begin
            @(posedge wr_clk);
            wr_en <= 1;
            data_in <= data_in + 1;
        end
        wr_en <= 0;

        repeat (4) begin
            @(posedge wr_clk);
            wr_en <= 1;
            data_in <= data_in + 1;
        end
        wr_en <= 0;

        #100;

        $display("---- Scenario 6: BURST WRITES and BURST READS ----");
        repeat (10) begin
            // Burst write
            repeat (4) begin
                @(posedge wr_clk);
                if (!fifo_full) begin
                    wr_en <= 1;
                    data_in <= data_in + 1;
                end
            end
            wr_en <= 0;

            // Burst read
            repeat (4) begin
                @(posedge rd_clk);
                if (!fifo_empty)
                    rd_en <= 1;
            end
            rd_en <= 0;
        end

        #200;
        $display("Testbench completed.");
        $stop;
    end

    // Optional Monitor
    initial begin
        $monitor("Time=%0t | wr_en=%b data_in=%h | rd_en=%b data_out=%h | valid=%b | empty=%b full=%b",
                 $time, wr_en, data_in, rd_en, data_out, data_valid, fifo_empty, fifo_full);
    end

endmodule
