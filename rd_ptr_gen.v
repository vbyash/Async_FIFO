module rd_ptr_gen #(parameter ADDR_WIDTH = 4) (

	input rd_clk,
	input rd_rst_n,
	input rd_en,
	input [ADDR_WIDTH-1:0] wr_ptr_g_sync,
	output reg [ADDR_WIDTH-1:0] rd_ptr_b,
	output reg [ADDR_WIDTH-1:0] rd_ptr_g,
	output reg fifo_empty
);

wire empty;
wire [ADDR_WIDTH-1:0] rd_ptr_b_next;
wire [ADDR_WIDTH-1:0] wr_ptr_b_sync;

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


assign rd_ptr_b_next = rd_ptr_b + ((~(fifo_empty) && rd_en)? 1'b1 : 1'b0);
assign wr_ptr_b_sync = gray_to_bin(wr_ptr_g_sync);
assign empty =(rd_ptr_b_next == wr_ptr_b_sync);

always @(posedge rd_clk) begin
	
	if(~rd_rst_n) begin
		rd_ptr_b <= 0;
		rd_ptr_g <= 0;
		fifo_empty <= 1'b1;
	end 
	else begin
		if(!fifo_empty && rd_en) begin
			rd_ptr_b <= rd_ptr_b_next;
			rd_ptr_g <= bin_to_gray(rd_ptr_b_next);
		end
		
		fifo_empty <= empty;
	end

end

endmodule