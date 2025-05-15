module fifo_mem #(
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 16,
	parameter DEPTH = 8
) (
	input wr_clk, rst_n, wr_en, rd_en,
	input [DATA_WIDTH-1:0] data_in,
	input fifo_full, fifo_empty,
	input [ADDR_WIDTH-1:0] wr_ptr, rd_ptr,
	output [DATA_WIDTH-1:0] data_out,
	output data_valid
);

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
integer i;

always @(posedge wr_clk) begin
	if(~rst_n) begin
		for (i = 0; i < DEPTH; i = i + 1)begin
			memory[i] <= 0;
        end
	end
	
	else begin
	    if(~fifo_full && wr_en) begin
			memory[wr_ptr[ADDR_WIDTH-2:0]] <= data_in;
		end
	end
	
end

assign data_out = memory[rd_ptr[ADDR_WIDTH-2:0]];
assign data_valid = rd_en && ~fifo_empty;

endmodule
