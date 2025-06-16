module topModule(
	 input  logic           clk,
    input  logic           resetN,
	 
	 input  logic           nextButton,
    
    // Pines físicos hacia la SDRAM (conduit "wire_*")
    output logic [12:0]    wire_addr,
    output logic [1:0]     wire_ba,
    output logic           wire_cas_n,
    output logic           wire_cke,
    output logic           wire_cs_n,   
    inout  logic [15:0]    wire_dq,
    output logic [1:0]     wire_dqm,
    output logic           wire_ras_n,
    output logic           wire_we_n,
	 
	 // Pines para el Jtag
	 input              [3:0]        KEY,
	 output             [7:0]        LEDG,
    output             [9:0]        LEDR,
    
    // Display de 7 segmentos (2 dígitos)
    output logic [6:0]     hex0,           // Dígito menos significativo
    output logic [6:0]     hex1,           // Dígito más significativo
	 output logic [6:0]     hex2,           // Dígito menos significativo
    output logic [6:0]     hex3           // Dígito más significativo
);

	// SDRAM control signals
	logic				startWrite, startRead;
	logic [24:0]	address;
	logic [15:0]	writeData;
	logic [15:0]	readData;
	logic				operationDone;
	logic				busy;

	// SDRAM Avalon-MM interface
	logic [24:0] sdram_address;
	logic [1:0]	 sdram_byteenable_n;
	logic		    sdram_chipselect;
	logic [15:0] sdram_writedata;
	logic		    sdram_read_n, sdram_write_n;
	logic [15:0] sdram_readdata;
	logic		    sdram_readdatavalid;
	logic		    sdram_waitrequest;

	// Memory matrices
	logic [15:0]	inputMatrix   [0:15];
	logic [15:0]	outputMatrixA [0:15];
	logic [15:0]	outputMatrixB [0:15];
	logic [15:0]	outputMatrixC [0:15];
	
	// Instantiate systolic array
	logic signed [15:0] injectA [0:3];
	logic signed [15:0] injectB [0:3];

	// Feed inputs from A and B matrices (1 row/column per cycle)
	assign injectA[0] = outputMatrixA[0];
	assign injectA[1] = outputMatrixA[4];
	assign injectA[2] = outputMatrixA[8];
	assign injectA[3] = outputMatrixA[12];

	assign injectB[0] = outputMatrixB[0];
	assign injectB[1] = outputMatrixB[1];
	assign injectB[2] = outputMatrixB[2];
	assign injectB[3] = outputMatrixB[3];
	
	logic [31:0] resultMatrix [0:3][0:3];

	
		// Convert 2D result to 1D inputMatrix
	always_comb begin
		for (int i = 0; i < 4; i++) begin
			for (int j = 0; j < 4; j++) begin
				inputMatrix[i * 4 + j] = resultMatrix[i][j][15:0]; // truncate to 16-bit
			end
		end
	end

	systolicArray systolicCore (
		.clk(clk),
		.rstN(resetN),
		.injectA(injectA),
		.injectB(injectB),
		.result(resultMatrix),
		.systolicDone()
	);
	
	// Instantiate memory manager
	matrixMemManager memManager (
		.clk(clk),
		.resetN(resetN),
		.inputMatrix(inputMatrix),
		.outputMatrixA(outputMatrixA),
		.outputMatrixB(outputMatrixB),
		.outputMatrixC(outputMatrixC),
		.startWrite(startWrite),
		.startRead(startRead),
		.address(address),
		.writeData(writeData),
		.readData(readData),
		.operationDone(operationDone),
		.busy(busy)
	);

	// SDRAM controller
	sdramController sdramInt (
		.clk(clk),
		.reset_n(resetN),
		.start_write(startWrite),
		.start_read(startRead),
		.address(address),
		.write_data(writeData),
		.read_data(readData),
		.operation_done(operationDone),
		.busy(busy),
		.sdram_address(sdram_address),
		.sdram_byteenable_n(sdram_byteenable_n),
		.sdram_chipselect(sdram_chipselect),
		.sdram_writedata(sdram_writedata),
		.sdram_read_n(sdram_read_n),
		.sdram_write_n(sdram_write_n),
		.sdram_readdata(sdram_readdata),
		.sdram_readdatavalid(sdram_readdatavalid),
		.sdram_waitrequest(sdram_waitrequest)
	);
	
	// Connect to physical SDRAM
	sdram sdramCore (
		.clk_clk(clk),
		.reset_reset_n(resetN),
		.sdram_address(sdram_address),
		.sdram_byteenable_n(sdram_byteenable_n),
		.sdram_chipselect(sdram_chipselect),
		.sdram_writedata(sdram_writedata),
		.sdram_read_n(sdram_read_n),
		.sdram_write_n(sdram_write_n),
		.sdram_readdata(sdram_readdata),
		.sdram_readdatavalid(sdram_readdatavalid),
		.sdram_waitrequest(sdram_waitrequest),
		.wire_addr(wire_addr),
		.wire_ba(wire_ba),
		.wire_cas_n(wire_cas_n),
		.wire_cke(wire_cke),
		.wire_cs_n(wire_cs_n),
		.wire_dq(wire_dq),
		.wire_dqm(wire_dqm),
		.wire_ras_n(wire_ras_n),
		.wire_we_n(wire_we_n)
	);

	hexDisplayController displayCtrl (
		.clk(clk),
		.resetN(resetN),
		.nextButton(nextButton),
		.outputMatrixC(outputMatrixC),
		.hex0(hex0),
		.hex1(hex1),
		.hex2(hex2),
		.hex3(hex3)
	);
	
	localparam int DW = 16;
	
	wire configure;
	wire up;
	wire down;
	wire tdi;
	wire tdo;              
	wire [1:0] ir_in;
	wire virtual_state_cdr;
	wire virtual_state_sdr;
	wire virtual_state_udr;
	wire tck;
	
	assign  configure = ~KEY[0];
	assign  up        = ~KEY[1];
	assign  down      = ~KEY[2];
	assign  ready     = ~KEY[3];
	
	wire [(DW-1):0] jtag_data;
	logic [(DW-1):0] counter;
	
	always_ff @(posedge clk or negedge resetN) begin
    if(!resetN) begin
        counter <= '0;
    end
    else begin
        if(configure) begin
            counter <= jtag_data;
        end
        else begin
            if(up) begin
                counter <= counter + 1'b1;
            end
            if(down) begin
                counter <= counter - 1'b1;
            end
        end
    end
	end
	
	vjtag u_vjtag (
                    .tdi                (tdi),  // jtag.tdi
                    .tdo                (tdo),  //.tdo
                    .ir_in              (ir_in),  //.ir_in
                    .ir_out             (),  //.ir_out
                    .virtual_state_cdr  (virtual_state_cdr),  //.virtual_state_cdr
                    .virtual_state_sdr  (virtual_state_sdr),  //.virtual_state_sdr
                    .virtual_state_e1dr (),  //.virtual_state_e1dr
                    .virtual_state_pdr  (),  //.virtual_state_pdr
                    .virtual_state_e2dr (),  //.virtual_state_e2dr
                    .virtual_state_udr  (virtual_state_udr),  //.virtual_state_udr
                    .virtual_state_cir  (),  //.virtual_state_cir
                    .virtual_state_uir  (),  //.virtual_state_uir
                    .tck                (tck)   //  tck.clk
                    );

	vjtag_interface  #(.DW(DW)) u_vjtag_interface (
                        .tck(tck),
                        .tdi(tdi),
                        .aclr(resetN),
                        .ir_in(ir_in),
                        .v_sdr(virtual_state_sdr),
                        .v_cdr(virtual_state_cdr),
                        .udr(virtual_state_udr),
                        .data_out(jtag_data),
                        .data_in(counter),
                        .tdo(tdo),
                        .debug_dr1(LEDG),
                        .debug_dr2(LEDR[7:0])
                       );
	
endmodule