module sdramController (
	input  logic           clk,
	input  logic           reset_n,
	
	// Simplified user interface
	input  logic           start_write,    // Pulse to start write operation
	input  logic           start_read,     // Pulse to start read operation
	input  logic [24:0]    address,        // Memory address
	input  logic [15:0]    write_data,     // Data to be written
	output logic [15:0]    read_data,      // Data read from memory
	output logic           operation_done, // Operation completed flag
	output logic           busy,           // Indicates an ongoing operation
	
	// SDRAM controller interface
	output logic [24:0]    sdram_address,
	output logic [1:0]     sdram_byteenable_n,
	output logic           sdram_chipselect,
	output logic [15:0]    sdram_writedata,
	output logic           sdram_read_n,
	output logic           sdram_write_n,
	input  logic [15:0]    sdram_readdata,
	input  logic           sdram_readdatavalid,
	input  logic           sdram_waitrequest
);

	// State machine states
	typedef enum logic [2:0] {
		IDLE,
		WRITE_START,
		WRITE_WAIT,
		READ_START,
		READ_WAIT,
		DONE
	} state_t;
	
	state_t current_state, next_state;
	
	// Internal registers
	logic [24:0] addr_reg;
	logic [15:0] data_reg;
	logic [15:0] read_data_reg;
	logic operation_done_reg;
	
	// Sequential logic
	always_ff @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			current_state <= IDLE;
			addr_reg <= 25'b0;
			data_reg <= 16'b0;
			read_data_reg <= 16'b0;
			operation_done_reg <= 1'b0;
		end else begin
			current_state <= next_state;
			
			// Capture address and data at operation start
			if ((start_write || start_read) && current_state == IDLE) begin
				addr_reg <= address;
				if (start_write) begin
					data_reg <= write_data;
				end
			end
			
			// Capture read data when valid
			if (sdram_readdatavalid) begin
				read_data_reg <= sdram_readdata;
			end
			
			// Control operation done signal
			operation_done_reg <= (next_state == DONE);
		end
	end
	
	// Combinational logic for state machine
	always_comb begin
		next_state = current_state;
		
		case (current_state)
			IDLE: begin
				if (start_write) begin
					next_state = WRITE_START;
				end else if (start_read) begin
					next_state = READ_START;
				end
			end
			
			WRITE_START: begin
				next_state = WRITE_WAIT;
			end
			
			WRITE_WAIT: begin
				if (!sdram_waitrequest) begin
					next_state = DONE;
				end
			end
			
			READ_START: begin
				next_state = READ_WAIT;
			end
			
			READ_WAIT: begin
				if (sdram_readdatavalid) begin
					next_state = DONE;
				end
			end
			
			DONE: begin
				next_state = IDLE;
			end
			
			default: begin
				next_state = IDLE;
			end
		endcase
	end
	
	// Signal assignments to SDRAM controller
	always_comb begin
		// Default (inactive) values
		sdram_address = addr_reg;
		sdram_byteenable_n = 2'b00;  // Both bytes enabled
		sdram_chipselect = 1'b0;
		sdram_writedata = data_reg;
		sdram_read_n = 1'b1;         // Read inactive
		sdram_write_n = 1'b1;        // Write inactive
		
		case (current_state)
			WRITE_START, WRITE_WAIT: begin
				sdram_chipselect = 1'b1;
				sdram_write_n = 1'b0;    // Activate write
			end
			
			READ_START, READ_WAIT: begin
				sdram_chipselect = 1'b1;
				sdram_read_n = 1'b0;     // Activate read
			end
			
			default: begin
				// Keep default values
			end
		endcase
	end
	
	// Signal assignments to user interface
	assign read_data = read_data_reg;
	assign operation_done = operation_done_reg;
	assign busy = (current_state != IDLE);

endmodule
