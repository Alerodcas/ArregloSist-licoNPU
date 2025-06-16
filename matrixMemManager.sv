module matrixMemManager (
	input	 logic		  clk,
	input	 logic		  resetN,

	// External matrix input (4x4 values)
	input	 logic [15:0] inputMatrix [0:15],

	// Output matrices (read from SDRAM)
	output logic [15:0] outputMatrixA [0:15],
	output logic [15:0] outputMatrixB [0:15],
	output logic [15:0] outputMatrixC [0:15],

	// Simplified SDRAM interface
	output logic		  startWrite,
	output logic		  startRead,
	output logic [24:0] address,
	output logic [15:0] writeData,
	input	 logic [15:0] readData,
	input	 logic		  operationDone,
	input	 logic		  busy
);

	// Internal FSM state
	typedef enum logic [2:0] {
		IDLE,
		WRITE_MAT1,
		WRITE_MAT2,
		WRITE_INPUT,
		WAIT_WR,
		READ_ALL,
		WAIT_RD
	} state_t;

	state_t currentState, nextState;

	logic [4:0] index;
	logic [15:0] mat1 [0:15];
	logic [15:0] mat2 [0:15];

	// Init fixed matrices
	initial begin
		mat1 = '{16'h0001, 16'h0002, 16'h0003, 16'h0004,
		         16'h0005, 16'h0006, 16'h0007, 16'h0008,
		         16'h0009, 16'h000A, 16'h000B, 16'h000C,
		         16'h000D, 16'h000E, 16'h000F, 16'h0010};

		mat2 = '{16'h0001, 16'h0005, 16'h0009, 16'h000D,
		         16'h0002, 16'h0006, 16'h000A, 16'h000E,
		         16'h0003, 16'h0007, 16'h000B, 16'h000F,
		         16'h0004, 16'h0008, 16'h000C, 16'h0010};
	end

	// FSM state register
	always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			currentState <= IDLE;
			index <= 0;
		end else begin
			currentState <= nextState;

			if ((currentState == WRITE_MAT1 || currentState == WRITE_MAT2 || currentState == WRITE_INPUT) && operationDone)
				index <= index + 1;

			if (currentState == READ_ALL && operationDone)
				index <= index + 1;

			if (currentState == IDLE)
				index <= 0;
		end
	end

	// FSM next state logic
	always_comb begin
		startWrite = 0;
		startRead = 0;
		address = 0;
		writeData = 0;

		nextState = currentState;

		case (currentState)
			IDLE: nextState = WRITE_MAT1;

			WRITE_MAT1: if (!busy) begin
				startWrite = 1;
				address = index;
				writeData = mat1[index];
				nextState = WAIT_WR;
			end

			WRITE_MAT2: if (!busy) begin
				startWrite = 1;
				address = 16 + index;
				writeData = mat2[index];
				nextState = WAIT_WR;
			end

			WRITE_INPUT: if (!busy) begin
				startWrite = 1;
				address = 32 + index;
				writeData = inputMatrix[index];
				nextState = WAIT_WR;
			end

			WAIT_WR: if (operationDone) begin
				if (index == 15) begin
					case (currentState)
						WRITE_MAT1:  nextState = WRITE_MAT2;
						WRITE_MAT2:  nextState = WRITE_INPUT;
						WRITE_INPUT: nextState = READ_ALL;
						default:     nextState = IDLE;
					endcase
				end else begin
					nextState = currentState;
				end
			end

			READ_ALL: if (!busy) begin
				startRead = 1;
				address = index;
				nextState = WAIT_RD;
			end

			WAIT_RD: if (operationDone) begin
				nextState = (index == 47) ? IDLE : READ_ALL;
			end

			default: nextState = IDLE;
		endcase
	end

	// Update output matrices
	always_ff @(posedge clk) begin
		if (currentState == WAIT_RD && operationDone) begin
			if (index < 16)
				outputMatrixA[index] <= readData;
			else if (index < 32)
				outputMatrixB[index - 16] <= readData;
			else
				outputMatrixC[index - 32] <= readData;
		end
	end

endmodule
