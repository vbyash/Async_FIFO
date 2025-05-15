module async_fifo_top #(
	parameter DATA_WIDTH = 16,
	parameter DEPTH = 16,
	parameter ADDR_WIDTH = 5
)(
	input rd_clk, wr_clk, rst_n,
	input rd_en, wr_en,
	input [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out,
	output data_valid,
	output fifo_empty,
	output fifo_full
);


wire full, empty;
wire [ADDR_WIDTH-1:0] wr_ptr_b, wr_ptr_g, wr_ptr_g_sync;
wire [ADDR_WIDTH-1:0] rd_ptr_b, rd_ptr_g, rd_ptr_g_sync;

assign fifo_empty = empty;
assign fifo_full = full;

fifo_mem #(
	.ADDR_WIDTH(ADDR_WIDTH),
	.DATA_WIDTH(DATA_WIDTH),
	.DEPTH(DEPTH)
) memory_inst (
	.wr_clk(wr_clk), 
	.rst_n(rst_n), 
	.wr_en(wr_en), 
	.rd_en(rd_en),
	.data_in(data_in),
	.fifo_full(full),
	.fifo_empty(empty),
	.wr_ptr(wr_ptr_b), 
	.rd_ptr(rd_ptr_b),
	.data_out(data_out),
	.data_valid(data_valid)
);

rd_ptr_gen #(.ADDR_WIDTH(ADDR_WIDTH)) rd_ptr_inst (
	.rd_clk(rd_clk),
	.rd_rst_n(rst_n),
	.rd_en(rd_en),
	.wr_ptr_g_sync(wr_ptr_g_sync),
	.rd_ptr_b(rd_ptr_b),
	.rd_ptr_g(rd_ptr_g),
	.fifo_empty(empty)
);

wrt_ptr_gen #(.ADDR_WIDTH(ADDR_WIDTH)) wr_ptr_inst (
    .wr_clk(wr_clk),
    .wr_rst_n(rst_n),
    .wr_en(wr_en),
    .rd_ptr_g_sync(rd_ptr_g_sync),  
    .fifo_full(full),
    .wr_ptr_b(wr_ptr_b),      
    .wr_ptr_g(wr_ptr_g)        
);

synchronizer #(.ADDR_WIDTH(ADDR_WIDTH))rd_ptr_sync_inst(
	.clk(wr_clk), 
	.rst_n(rst_n), 
	.data_in(rd_ptr_g), 
	.data_out(rd_ptr_g_sync)
);

synchronizer #(.ADDR_WIDTH(ADDR_WIDTH))wr_ptr_sync_inst(
	.clk(rd_clk), 
	.rst_n(rst_n), 
	.data_in(wr_ptr_g), 
	.data_out(wr_ptr_g_sync)
);


endmodule