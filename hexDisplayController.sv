module hexDisplayController (
	input  logic        clk,
	input  logic        resetN,
	input  logic        nextButton,              // Botón para avanzar al siguiente número
	input  logic [15:0] outputMatrixC [0:15],    // Matriz de salida

	output logic [6:0]  hex0,                    // Dígito menos significativo
	output logic [6:0]  hex1,
	output logic [6:0]  hex2,
	output logic [6:0]  hex3                     // Dígito más significativo
);

	// Internal index (0 to 15)
	logic [3:0] currentIndex;

	// Register to store debounced button and allow one step per press
	logic prevButtonState;

	// Extract current value
	logic [15:0] currentValue;

	assign currentValue = outputMatrixC[currentIndex];

	// Segment decoders (hex to 7-segment)
	function logic [6:0] hexTo7Segment(input logic [3:0] hexDigit);
		case (hexDigit)
			4'h0: hexTo7Segment = 7'b1000000;
			4'h1: hexTo7Segment = 7'b1111001;
			4'h2: hexTo7Segment = 7'b0100100;
			4'h3: hexTo7Segment = 7'b0110000;
			4'h4: hexTo7Segment = 7'b0011001;
			4'h5: hexTo7Segment = 7'b0010010;
			4'h6: hexTo7Segment = 7'b0000010;
			4'h7: hexTo7Segment = 7'b1111000;
			4'h8: hexTo7Segment = 7'b0000000;
			4'h9: hexTo7Segment = 7'b0010000;
			4'hA: hexTo7Segment = 7'b0001000;
			4'hB: hexTo7Segment = 7'b0000011;
			4'hC: hexTo7Segment = 7'b1000110;
			4'hD: hexTo7Segment = 7'b0100001;
			4'hE: hexTo7Segment = 7'b0000110;
			4'hF: hexTo7Segment = 7'b0001110;
			default: hexTo7Segment = 7'b1111111; // Apagado
		endcase
	endfunction

	// Button press detector (simple falling edge)
	always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			currentIndex     <= 4'd0;
			prevButtonState  <= 1'b0;
		end else begin
			if (nextButton && !prevButtonState) begin
				currentIndex <= (currentIndex == 4'd15) ? 4'd0 : currentIndex + 4'd1;
			end
			prevButtonState <= nextButton;
		end
	end

	// Output 4 digits (MSB to LSB)
	always_comb begin
		hex0 = hexTo7Segment(currentValue[3:0]);
		hex1 = hexTo7Segment(currentValue[7:4]);
		hex2 = hexTo7Segment(currentValue[11:8]);
		hex3 = hexTo7Segment(currentValue[15:12]);
	end

endmodule
