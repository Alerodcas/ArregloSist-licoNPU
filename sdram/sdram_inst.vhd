	component sdram is
		port (
			clk_clk                                 : in    std_logic                     := 'X';             -- clk
			reset_reset_n                           : in    std_logic                     := 'X';             -- reset_n
			new_sdram_controller_0_s1_address       : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			new_sdram_controller_0_s1_byteenable_n  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable_n
			new_sdram_controller_0_s1_chipselect    : in    std_logic                     := 'X';             -- chipselect
			new_sdram_controller_0_s1_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			new_sdram_controller_0_s1_read_n        : in    std_logic                     := 'X';             -- read_n
			new_sdram_controller_0_s1_write_n       : in    std_logic                     := 'X';             -- write_n
			new_sdram_controller_0_s1_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
			new_sdram_controller_0_s1_readdatavalid : out   std_logic;                                        -- readdatavalid
			new_sdram_controller_0_s1_waitrequest   : out   std_logic;                                        -- waitrequest
			new_sdram_controller_0_wire_addr        : out   std_logic_vector(12 downto 0);                    -- addr
			new_sdram_controller_0_wire_ba          : out   std_logic_vector(1 downto 0);                     -- ba
			new_sdram_controller_0_wire_cas_n       : out   std_logic;                                        -- cas_n
			new_sdram_controller_0_wire_cke         : out   std_logic;                                        -- cke
			new_sdram_controller_0_wire_cs_n        : out   std_logic;                                        -- cs_n
			new_sdram_controller_0_wire_dq          : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			new_sdram_controller_0_wire_dqm         : out   std_logic_vector(1 downto 0);                     -- dqm
			new_sdram_controller_0_wire_ras_n       : out   std_logic;                                        -- ras_n
			new_sdram_controller_0_wire_we_n        : out   std_logic                                         -- we_n
		);
	end component sdram;

	u0 : component sdram
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                         clk.clk
			reset_reset_n                           => CONNECTED_TO_reset_reset_n,                           --                       reset.reset_n
			new_sdram_controller_0_s1_address       => CONNECTED_TO_new_sdram_controller_0_s1_address,       --   new_sdram_controller_0_s1.address
			new_sdram_controller_0_s1_byteenable_n  => CONNECTED_TO_new_sdram_controller_0_s1_byteenable_n,  --                            .byteenable_n
			new_sdram_controller_0_s1_chipselect    => CONNECTED_TO_new_sdram_controller_0_s1_chipselect,    --                            .chipselect
			new_sdram_controller_0_s1_writedata     => CONNECTED_TO_new_sdram_controller_0_s1_writedata,     --                            .writedata
			new_sdram_controller_0_s1_read_n        => CONNECTED_TO_new_sdram_controller_0_s1_read_n,        --                            .read_n
			new_sdram_controller_0_s1_write_n       => CONNECTED_TO_new_sdram_controller_0_s1_write_n,       --                            .write_n
			new_sdram_controller_0_s1_readdata      => CONNECTED_TO_new_sdram_controller_0_s1_readdata,      --                            .readdata
			new_sdram_controller_0_s1_readdatavalid => CONNECTED_TO_new_sdram_controller_0_s1_readdatavalid, --                            .readdatavalid
			new_sdram_controller_0_s1_waitrequest   => CONNECTED_TO_new_sdram_controller_0_s1_waitrequest,   --                            .waitrequest
			new_sdram_controller_0_wire_addr        => CONNECTED_TO_new_sdram_controller_0_wire_addr,        -- new_sdram_controller_0_wire.addr
			new_sdram_controller_0_wire_ba          => CONNECTED_TO_new_sdram_controller_0_wire_ba,          --                            .ba
			new_sdram_controller_0_wire_cas_n       => CONNECTED_TO_new_sdram_controller_0_wire_cas_n,       --                            .cas_n
			new_sdram_controller_0_wire_cke         => CONNECTED_TO_new_sdram_controller_0_wire_cke,         --                            .cke
			new_sdram_controller_0_wire_cs_n        => CONNECTED_TO_new_sdram_controller_0_wire_cs_n,        --                            .cs_n
			new_sdram_controller_0_wire_dq          => CONNECTED_TO_new_sdram_controller_0_wire_dq,          --                            .dq
			new_sdram_controller_0_wire_dqm         => CONNECTED_TO_new_sdram_controller_0_wire_dqm,         --                            .dqm
			new_sdram_controller_0_wire_ras_n       => CONNECTED_TO_new_sdram_controller_0_wire_ras_n,       --                            .ras_n
			new_sdram_controller_0_wire_we_n        => CONNECTED_TO_new_sdram_controller_0_wire_we_n         --                            .we_n
		);

