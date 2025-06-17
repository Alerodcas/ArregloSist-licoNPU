	component jtagUart is
		port (
			clk_clk               : in  std_logic                     := 'X';             -- clk
			reset_reset_n         : in  std_logic                     := 'X';             -- reset_n
			jtagslave_chipselect  : in  std_logic                     := 'X';             -- chipselect
			jtagslave_address     : in  std_logic                     := 'X';             -- address
			jtagslave_read_n      : in  std_logic                     := 'X';             -- read_n
			jtagslave_readdata    : out std_logic_vector(31 downto 0);                    -- readdata
			jtagslave_write_n     : in  std_logic                     := 'X';             -- write_n
			jtagslave_writedata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			jtagslave_waitrequest : out std_logic                                         -- waitrequest
		);
	end component jtagUart;

	u0 : component jtagUart
		port map (
			clk_clk               => CONNECTED_TO_clk_clk,               --       clk.clk
			reset_reset_n         => CONNECTED_TO_reset_reset_n,         --     reset.reset_n
			jtagslave_chipselect  => CONNECTED_TO_jtagslave_chipselect,  -- jtagslave.chipselect
			jtagslave_address     => CONNECTED_TO_jtagslave_address,     --          .address
			jtagslave_read_n      => CONNECTED_TO_jtagslave_read_n,      --          .read_n
			jtagslave_readdata    => CONNECTED_TO_jtagslave_readdata,    --          .readdata
			jtagslave_write_n     => CONNECTED_TO_jtagslave_write_n,     --          .write_n
			jtagslave_writedata   => CONNECTED_TO_jtagslave_writedata,   --          .writedata
			jtagslave_waitrequest => CONNECTED_TO_jtagslave_waitrequest  --          .waitrequest
		);

