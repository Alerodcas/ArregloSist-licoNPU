module arithmeticIntensityCalculator(
	input  logic [31:0] numOperations,  // Total floating-point operations (FLOPs)
	input  logic [31:0] numBytes,       // Total bytes transferred
	output logic [31:0] arithmeticIntensity  // Result in Q8.8 fixed-point format
);

	always_comb begin
		if (numBytes != 0)
			// Multiply by 256 (1 << 8) to simulate Q8.8 fixed-point division
			arithmeticIntensity = (numOperations << 8) / numBytes;
		else
			arithmeticIntensity = 32'd0;
	end

endmodule