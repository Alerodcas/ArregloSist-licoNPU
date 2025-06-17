module controlRegisters #(
	parameter [24:0] MATRIX_DEBUG_BASE = 25'h0000C0  // Start address in SDRAM for debug registers
)(
	input  logic        clk,
	input  logic        resetN,

	output logic [15:0] debugOutput 
);

	// Base addresses for each register block (not used but declared for clarity)
	parameter [24:0] DEBUG_BASE_ADDR   = 25'h0000C0;  // after MATRIX_C (0x80)
	parameter [24:0] CONTROL_BASE_ADDR = 25'h000100;  // +64 bytes
	parameter [24:0] STATUS_BASE_ADDR  = 25'h000140;  // +64 bytes
	parameter [24:0] PERF_BASE_ADDR    = 25'h000180;  // +64 bytes

	// Internal dummy registers
	logic [15:0] debug;
	logic [15:0] control;
	logic [15:0] status;
	logic [15:0] performance;

	// Update values
	always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			debug       <= 16'hDEAD;
			control     <= 16'h0000;
			status      <= 16'h0000;
			performance <= 16'h0000;
		end else begin
			// Behavior
			control     <= control + 16'd1;
			status      <= status ^ 16'h00FF;
			performance <= performance + (control[3:0] & status[3:0]);
			debug       <= debug;  // remains unchanged
		end
	end

	// Combine for debug output
	assign debugOutput = debug ^ control ^ status ^ performance;

endmodule
