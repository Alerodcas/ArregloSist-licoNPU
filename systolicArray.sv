module systolicArray #(
	parameter int wA = 16,         // input data width for A/B
	parameter int wP = 32          // accumulator (psum) width
)(
	input  logic                   clk,
	input  logic                   rstN,

	// Injection interfaces: one word per row/column per cycle
	input  logic signed [wA-1:0]   injectA [0:3],  // A[i][t−i] for i=0..3
	input  logic signed [wA-1:0]   injectB [0:3],  // B[t−j][j] for j=0..3
	output logic signed [wP-1:0]   result  [0:3][0:3]
);

	// Internal shift signals
	logic signed [wA-1:0] shiftA [0:3][0:3];
	logic signed [wA-1:0] shiftB [0:3][0:3];
	logic signed [wP-1:0] psum   [0:3][0:3];

	genvar i, j;
	generate
		for (i = 0; i < 4; i++) begin : row
			for (j = 0; j < 4; j++) begin : col
				// Instantiate a Processing Element
				pe #(
					.wA(wA),
					.wP(wP)
				) peInst (
					.clk         (clk),
					.rstN        (rstN),

					// Injected data on array edge
					.inA         ( injectA[i] ),        // only valid if j == 0
					.inB         ( injectB[j] ),        // only valid if i == 0
					.loadA       ( j == 0 ),            // inject A only in column 0
					.loadB       ( i == 0 ),            // inject B only in row 0

					// Shift-in data from neighbors
					.shiftAIn    ( (j > 0) ? shiftA[i][j-1] : '0 ),
					.shiftBIn    ( (i > 0) ? shiftB[i-1][j] : '0 ),

					// Shift-out data to neighbors
					.shiftAOut   ( shiftA[i][j] ),
					.shiftBOut   ( shiftB[i][j] ),

					// Partial sum output
					.psumOut     ( psum[i][j] )
				);

				// Connect to final result output
				assign result[i][j] = psum[i][j];
			end
		end
	endgenerate

endmodule