module synchronizer #(parameter ADDR_WIDTH = 3)(clk, rst_n, data_in, data_out);

input clk, rst_n;
input [ADDR_WIDTH-1:0] data_in;
output reg [ADDR_WIDTH-1:0] data_out;

reg [ADDR_WIDTH-1:0] data_1d;

always @(posedge clk)
begin
	if(~rst_n) begin
		data_1d <= 0;
		data_out <= 0;
	end
	 
	else begin
		data_1d <= data_in;
		data_out <= data_1d;	
	end

end

endmodule