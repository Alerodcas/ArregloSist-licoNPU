	jtagUart u0 (
		.clk_clk               (<connected-to-clk_clk>),               //       clk.clk
		.reset_reset_n         (<connected-to-reset_reset_n>),         //     reset.reset_n
		.jtagslave_chipselect  (<connected-to-jtagslave_chipselect>),  // jtagslave.chipselect
		.jtagslave_address     (<connected-to-jtagslave_address>),     //          .address
		.jtagslave_read_n      (<connected-to-jtagslave_read_n>),      //          .read_n
		.jtagslave_readdata    (<connected-to-jtagslave_readdata>),    //          .readdata
		.jtagslave_write_n     (<connected-to-jtagslave_write_n>),     //          .write_n
		.jtagslave_writedata   (<connected-to-jtagslave_writedata>),   //          .writedata
		.jtagslave_waitrequest (<connected-to-jtagslave_waitrequest>)  //          .waitrequest
	);

