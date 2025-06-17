
module jtagUart (
	clk_clk,
	reset_reset_n,
	jtagslave_chipselect,
	jtagslave_address,
	jtagslave_read_n,
	jtagslave_readdata,
	jtagslave_write_n,
	jtagslave_writedata,
	jtagslave_waitrequest);	

	input		clk_clk;
	input		reset_reset_n;
	input		jtagslave_chipselect;
	input		jtagslave_address;
	input		jtagslave_read_n;
	output	[31:0]	jtagslave_readdata;
	input		jtagslave_write_n;
	input	[31:0]	jtagslave_writedata;
	output		jtagslave_waitrequest;
endmodule
