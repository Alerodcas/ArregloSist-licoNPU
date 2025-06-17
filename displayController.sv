// 7 segments control display
module displayController(
    input  logic clock,
    input  logic resetN,
    input  logic nextButton,
    input  logic signed [15:0] resultMatrix [0:3][0:3],
    output logic [31:0] displayValue,
    output logic [6:0]  hex0, hex1, hex2, hex3
);

    // Internal signals
    logic        nextButtonPrev, nextButtonEdge;
    logic [3:0]  displayMode;
    logic [4:0]  displayResultIndex;
    logic [63:0] cycleCounter;
    logic [31:0] memOpsCounter;
    logic [31:0] flopCounter;
    logic [31:0] arithmeticIntensity;

    // Performance counters (simplified)
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            cycleCounter <= 64'b0;
            memOpsCounter <= 32'b0;
            flopCounter <= 32'b0;
        end else begin
            cycleCounter <= cycleCounter + 1;
            // Simplified counters for demonstration
            if (cycleCounter[10:0] == 0) begin // Periodic increment
                memOpsCounter <= memOpsCounter + 1;
                flopCounter <= flopCounter + 32;
            end
        end
    end

    // Arithmetic intensity calculation
    always_comb begin
        if (memOpsCounter > 0) begin
            arithmeticIntensity = 32'd128 / (memOpsCounter * 2);
        end else begin
            arithmeticIntensity = 32'b0;
        end
    end

    // Button edge detection
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            nextButtonPrev <= 1'b0;
            nextButtonEdge <= 1'b0;
        end else begin
            nextButtonPrev <= nextButton;
            nextButtonEdge <= nextButton & ~nextButtonPrev;
        end
    end

    // Display mode and index control
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            displayMode <= 4'b0;
            displayResultIndex <= 5'b0;
        end else if (nextButtonEdge) begin
            if (displayMode == 4'b0) begin
                if (displayResultIndex == 5'd15) begin
                    displayResultIndex <= 5'b0;
                    displayMode <= 4'b1;
                end else begin
                    displayResultIndex <= displayResultIndex + 1;
                end
            end else begin
                displayMode <= 4'b0;
                displayResultIndex <= 5'b0;
            end
        end
    end

    // Value selection for display
    always_comb begin
        logic [3:0] row;
        logic [3:0] col;

        if (displayMode == 4'b0) begin
            row = displayResultIndex >> 2;
            col = displayResultIndex & 3;
            displayValue = resultMatrix[row][col];
        end else begin
            displayValue = arithmeticIntensity;
        end
    end

    // 7-segment decoder
    function logic [6:0] hexTo7Seg(input logic [3:0] hex);
        case (hex)
            4'h0: hexTo7Seg = 7'b1000000; // 0
            4'h1: hexTo7Seg = 7'b1111001; // 1
            4'h2: hexTo7Seg = 7'b0100100; // 2
            4'h3: hexTo7Seg = 7'b0110000; // 3
            4'h4: hexTo7Seg = 7'b0011001; // 4
            4'h5: hexTo7Seg = 7'b0010010; // 5
            4'h6: hexTo7Seg = 7'b0000010; // 6
            4'h7: hexTo7Seg = 7'b1111000; // 7
            4'h8: hexTo7Seg = 7'b0000000; // 8
            4'h9: hexTo7Seg = 7'b0010000; // 9
            4'hA: hexTo7Seg = 7'b0001000; // A
            4'hB: hexTo7Seg = 7'b0000011; // b
            4'hC: hexTo7Seg = 7'b1000110; // C
            4'hD: hexTo7Seg = 7'b0100001; // d
            4'hE: hexTo7Seg = 7'b0000110; // E
            4'hF: hexTo7Seg = 7'b0001110; // F
        endcase
    endfunction

    // Display assignments
    assign hex0 = hexTo7Seg(displayValue[3:0]);
    assign hex1 = hexTo7Seg(displayValue[7:4]);
    assign hex2 = hexTo7Seg(displayValue[11:8]);
    assign hex3 = hexTo7Seg(displayValue[15:12]);

endmodule