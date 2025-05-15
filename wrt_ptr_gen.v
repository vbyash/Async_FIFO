module wrt_ptr_gen #(parameter ADDR_WIDTH = 4) (
    input                     wr_clk,
    input                     wr_rst_n,
    input                     wr_en,
    input  [ADDR_WIDTH-1:0]     rd_ptr_g_sync,  
    output reg                fifo_full,
    output reg [ADDR_WIDTH-1:0] wr_ptr_b,      
    output reg [ADDR_WIDTH-1:0] wr_ptr_g        
);

wire [ADDR_WIDTH-1:0] wr_ptr_b_next;
wire [ADDR_WIDTH-1:0] rd_ptr_b_sync;
wire full;

function [ADDR_WIDTH-1:0] gray_to_bin;
    input [ADDR_WIDTH-1:0] gray;
    integer i;
    begin
        gray_to_bin[ADDR_WIDTH-1] = gray[ADDR_WIDTH-1];
        for (i = ADDR_WIDTH-2; i >= 0; i = i - 1)
            gray_to_bin[i] = gray[i] ^ gray_to_bin[i+1];
    end
endfunction

function [ADDR_WIDTH-1:0] bin_to_gray;
    input [ADDR_WIDTH-1:0] bin;
    begin
        bin_to_gray = (bin >> 1) ^ bin;
    end
endfunction

assign wr_ptr_b_next = wr_ptr_b + ((wr_en && !fifo_full) ? 1'b1 : 1'b0);
assign rd_ptr_b_sync = gray_to_bin(rd_ptr_g_sync);
assign full = (wr_ptr_b_next[ADDR_WIDTH-1] != rd_ptr_b_sync[ADDR_WIDTH-1]) &&
              (wr_ptr_b_next[ADDR_WIDTH-2:0] == rd_ptr_b_sync[ADDR_WIDTH-2:0]);

always @(posedge wr_clk) begin
    if (~wr_rst_n) begin
        wr_ptr_b <= 0;
        wr_ptr_g <= 0;
        fifo_full <= 0;
    end 
	else begin
        if (!fifo_full && wr_en) begin
            wr_ptr_b <= wr_ptr_b_next;
            wr_ptr_g <= bin_to_gray(wr_ptr_b_next);
        end
        fifo_full <= full;
    end
end

endmodule
