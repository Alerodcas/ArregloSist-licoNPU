module systolicArrayTestbench;

	// Parameters
	localparam int wA = 16;
	localparam int wP = 32;

	// Clock and reset
	logic clk;
	logic rstN;

	// Inputs
	logic signed [wA-1:0] injectA [0:3];
	logic signed [wA-1:0] injectB [0:3];

	// Output
	logic signed [wP-1:0] result [0:3][0:3];

	// Instantiate the DUT
	systolicArray #(.wA(wA), .wP(wP)) dut (
		.clk(clk),
		.rstN(rstN),
		.injectA(injectA),
		.injectB(injectB),
		.result(result)
	);

	// Clock generation
	initial clk = 0;
	always #5 clk = ~clk; // 10 ns period

	// Test matrices (4x4)
	logic signed [wA-1:0] matrixA [0:3][0:3];
	logic signed [wA-1:0] matrixB [0:3][0:3];

	// Clocked injection logic
	int t;
	initial begin
		// Initialize reset
		rstN = 0;
		#15;
		rstN = 1;

		// Matrix A (filas)
		matrixA = '{
			'{1, 2, 3, 4},
			'{5, 6, 7, 8},
			'{9, 10, 11, 12},
			'{13, 14, 15, 16}
		};

		// Matrix B (columnas)
		matrixB = '{
			'{1, 5, 9,  13},
			'{2, 6, 10, 14},
			'{3, 7, 11, 15},
			'{4, 8, 12, 16}
		};

		// Inject data one cycle at a time (diagonally aligned for systolic)
		for (t = 0; t < 8; t++) begin
			for (int i = 0; i < 4; i++) begin
				if (t - i >= 0 && t - i < 4)
					injectA[i] = matrixA[i][t - i];
				else
					injectA[i] = 0;
			end

			for (int j = 0; j < 4; j++) begin
				if (t - j >= 0 && t - j < 4)
					injectB[j] = matrixB[t - j][j];
				else
					injectB[j] = 0;
			end

			#10;
		end

		// Wait extra cycles for data to finish propagating
		#100;

		// Display results
		$display("Result matrix:");
		for (int i = 0; i < 4; i++) begin
			for (int j = 0; j < 4; j++)
				$write("%0d\t", result[i][j]);
			$display("");
		end

		$finish;
	end

endmodule
