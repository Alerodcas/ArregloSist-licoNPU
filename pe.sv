module pe #(
	parameter int wA = 16,   // input data width for A/B
	parameter int wP = 32    // accumulator (psum) width
)(
	input  logic                   clk,
	input  logic                   rstN,

	// data injection (valid only in column 0 / row 0)
	input  logic signed [wA-1:0]   inA,
	input  logic signed [wA-1:0]   inB,
	input  logic                   loadA,    // 1 = inject inA; 0 = take shiftAIn
	input  logic                   loadB,    // 1 = inject inB; 0 = take shiftBIn

	// shift inputs from neighbors
	input  logic signed [wA-1:0]   shiftAIn,
	input  logic signed [wA-1:0]   shiftBIn,

	// shift outputs to neighbors
	output logic signed [wA-1:0]   shiftAOut,
	output logic signed [wA-1:0]   shiftBOut,

	// partial sum output
	output logic signed [wP-1:0]   psumOut
);

	// internal registers
	logic signed [wA-1:0] aReg, bReg;
	logic signed [wP-1:0] psumReg;

	// Sequential logic: injection/shift + MAC
	always_ff @(posedge clk or negedge rstN) begin
		if (!rstN) begin
			aReg    <= '0;
			bReg    <= '0;
			psumReg <= '0;
		end else begin
			// Inject new data if requested, or take shifted input
			aReg    <= loadA ? inA : shiftAIn;
			bReg    <= loadB ? inB : shiftBIn;
			// MAC: accumulate product
			psumReg <= psumReg + aReg * bReg;
		end
	end

	// Connect to shift outputs
	assign shiftAOut = aReg;
	assign shiftBOut = bReg;

	// Expose the partial sum
	assign psumOut   = psumReg;

endmodule