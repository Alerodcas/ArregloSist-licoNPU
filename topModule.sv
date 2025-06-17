module topModule(
    input  logic        clock,
    input  logic        resetN,

    input  logic        nextButton,
	 input  logic        stepEnableSwitch,
    input  logic        stepButton,

    // Physical pins to the SDRAM (conduit "wire_*")
    output logic [12:0] wireAddress,
    output logic [1:0]  wireBa,
    output logic        wireCasN,
    output logic        wireCke,
    output logic        wireCsN,
    inout  logic [15:0] wireDq,
    output logic [1:0]  wireDqm,
    output logic        wireRasN,
    output logic        wireWeN,

    // 7-segment display (4 digits)
    output logic [6:0]  hex0, // Least significant digit
    output logic [6:0]  hex1, // Second least significant digit
    output logic [6:0]  hex2, // Third least significant digit
    output logic [6:0]  hex3  // Most significant digit
);

    parameter WA = 16;
    parameter WP = 32;

    // Base addresses in SDRAM
    parameter [24:0] MATRIX_A_BASE = 25'h000000;
    parameter [24:0] MATRIX_B_BASE = 25'h000040;
    parameter [24:0] MATRIX_C_BASE = 25'h000080;

    // SDRAM Avalon-MM interface signals
    logic [24:0] sdramAddress;
    logic [1:0]  sdramByteEnableN;
    logic        sdramChipSelect;
    logic [15:0] sdramWriteData;
    logic        sdramReadN, sdramWriteN;
    logic [15:0] sdramReadData;
    logic        sdramReadDataValid;
    logic        sdramWaitRequest;

    // SDRAM simplified interface control signals
    logic        startWrite;
    logic        startRead;
    logic [24:0] currentAddress;
    logic [15:0] currentWriteData;
    logic [15:0] currentReadData;
    logic        operationDone;
    logic        busy;

    // Instantiate systolic array related signals
    logic signed [15:0] injectA [0:3][0:3];
    logic signed [15:0] injectB [0:3][0:3];
    logic signed [15:0] resultMatrix [0:3][0:3];
    logic               systolicStart;
    logic               systolicBusy;
    logic               systolicDone;

    // Main states
    typedef enum logic [3:0] {
        idle,
        loadMatrixA,
        loadMatrixB,
        systolicCompute,
        storeResults,
        displayResults
    } MainState;

    MainState currentMainState, nextMainState;

    // Performance counters
    logic [63:0] cycleCounter;
    logic [31:0] memOpsCounter;
    logic [31:0] computeCycles;
    logic [31:0] flopCounter;

    // Auxiliary counters
    logic [4:0]  matrixIndex;  // For 4x4 = 16 elements
    logic [4:0]  resultIndex;
    logic [3:0]  displayMode;
    logic [4:0]  displayResultIndex;

    // Temporary matrices for loading/storing
    logic signed [15:0] matrixA [0:3][0:3];
    logic signed [15:0] matrixB [0:3][0:3];

    // Display control
    logic        nextButtonPrev, nextButtonEdge;
    logic [31:0] displayValue;
    logic [31:0] arithmeticIntensity;

    // Initialization delay
    logic [25:0] initDelayCounter;
    logic        initDelayDone;

    // Debug signals
    logic        matricesInitialized;
	 
	 // Stepping signals
	 logic stepButtonPrev, stepButtonEdge;
	 logic allowProgression;

    // Connect to physical SDRAM
    sdram sdramCore (
        .clk_clk(clock),
        .reset_reset_n(resetN),
        .sdram_address(sdramAddress),
        .sdram_byteenable_n(sdramByteEnableN),
        .sdram_chipselect(sdramChipSelect),
        .sdram_writedata(sdramWriteData),
        .sdram_read_n(sdramReadN),
        .sdram_write_n(sdramWriteN),
        .sdram_readdata(sdramReadData),
        .sdram_readdatavalid(sdramReadDataValid),
        .sdram_waitrequest(sdramWaitRequest),
        .wire_addr(wireAddress),
        .wire_ba(wireBa),
        .wire_cas_n(wireCasN),
        .wire_cke(wireCke),
        .wire_cs_n(wireCsN),
        .wire_dq(wireDq),
        .wire_dqm(wireDqm),
        .wire_ras_n(wireRasN),
        .wire_we_n(wireWeN)
    );

    // SDRAM controller
    sdramController sdramInt (
        .clk(clock),
        .reset_n(resetN),
        .start_write(startWrite),
        .start_read(startRead),
        .address(currentAddress),
        .write_data(currentWriteData),
        .read_data(currentReadData),
        .operation_done(operationDone),
        .busy(busy),
        .sdram_address(sdramAddress),
        .sdram_byteenable_n(sdramByteEnableN),
        .sdram_chipselect(sdramChipSelect),
        .sdram_writedata(sdramWriteData),
        .sdram_read_n(sdramReadN),
        .sdram_write_n(sdramWriteN),
        .sdram_readdata(sdramReadData),
        .sdram_readdatavalid(sdramReadDataValid),
        .sdram_waitrequest(sdramWaitRequest)
    );

    // Systolic array controller
    systolicController systolicController (
        .clk(clock),
        .rst_n(resetN),
        .start(systolicStart),
        .matrix_a(injectA),
        .matrix_b(injectB),
        .busy(systolicBusy),
        .done(systolicDone),
        .result(resultMatrix)
    );
	 
	     // Step Button edge detection
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            stepButtonPrev <= 1'b0;
            stepButtonEdge <= 1'b0;
        end else begin
            stepButtonPrev <= stepButton;
            stepButtonEdge <= stepButton & ~stepButtonPrev;
        end
    end

    // Delay counter for initialization
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            initDelayCounter <= 26'b0;
            initDelayDone <= 1'b0;
        end else begin
            if (initDelayCounter < 26'd50000000) begin // ~1 second at 50MHz
                initDelayCounter <= initDelayCounter + 1;
            end else begin
                initDelayDone <= 1'b1;
            end
        end
    end

    // Performance counters
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            cycleCounter <= 64'b0;
            memOpsCounter <= 32'b0;
            computeCycles <= 32'b0;
            flopCounter <= 32'b0;
        end else begin
            cycleCounter <= cycleCounter + 1;

            if (startWrite || startRead) begin
                memOpsCounter <= memOpsCounter + 1;
            end

            if (currentMainState == systolicCompute && systolicBusy) begin
                computeCycles <= computeCycles + 1;
                // 4x4 = 16 MAC operations per active cycle, each MAC = 2 FLOPs
                flopCounter <= flopCounter + 32;
            end
        end
    end

    // Arithmetic intensity calculation
    always_comb begin
        if (memOpsCounter > 0) begin
            // FLOPs / (Memory Operations * bytes per operation)
            // Total FLOPs for 4x4 matrix mult = 4*4*4*2 = 128 FLOPs
            // Total memory operations = 16+16+16 = 48 operations * 2 bytes = 96 bytes
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

    // Control of display mode and display result index
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            displayMode <= 4'b0; // Start showing matrix elements
            displayResultIndex <= 5'b0; // Initialize to first element (0,0)
        end else if (nextButtonEdge) begin
            if (displayMode == 4'b0) begin // Currently showing matrix elements
                if (displayResultIndex == 5'd15) begin // If it's the last element
                    displayResultIndex <= 5'b0; // Reset index
                    displayMode <= 4'b1; // Switch to show arithmetic intensity
                end else begin
                    displayResultIndex <= displayResultIndex + 1; // Go to next matrix element
                end
            end else begin // Currently showing arithmetic intensity (displayMode == 4'b1)
                displayMode <= 4'b0; // Switch back to show matrix elements
                displayResultIndex <= 5'b0; // Start from the first element of the matrix
            end
        end
    end

    // Matrix Initialization
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            matricesInitialized <= 1'b0;

            // Matrix A - VALUES
            matrixA[0][0] <= 16'd1; matrixA[0][1] <= 16'd2; matrixA[0][2] <= 16'd3; matrixA[0][3] <= 16'd4;
            matrixA[1][0] <= 16'd5; matrixA[1][1] <= 16'd6; matrixA[1][2] <= 16'd7; matrixA[1][3] <= 16'd8;
            matrixA[2][0] <= 16'd9; matrixA[2][1] <= 16'd10; matrixA[2][2] <= 16'd11; matrixA[2][3] <= 16'd12;
            matrixA[3][0] <= 16'd13; matrixA[3][1] <= 16'd14; matrixA[3][2] <= 16'd15; matrixA[3][3] <= 16'd16;

            // Matrix B - VALUES
            matrixB[0][0] <= 16'd1; matrixB[0][1] <= 16'd5; matrixB[0][2] <= 16'd9; matrixB[0][3] <= 16'd13;
            matrixB[1][0] <= 16'd2; matrixB[1][1] <= 16'd6; matrixB[1][2] <= 16'd10; matrixB[1][3] <= 16'd14;
            matrixB[2][0] <= 16'd3; matrixB[2][1] <= 16'd7; matrixB[2][2] <= 16'd11; matrixB[2][3] <= 16'd15;
            matrixB[3][0] <= 16'd4; matrixB[3][1] <= 16'd8; matrixB[3][2] <= 16'd12; matrixB[3][3] <= 16'd16;

            // Initialize internal matrices
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    injectA[i][j] <= 16'b0;
                    injectB[i][j] <= 16'b0;
                end
            end
        end else if (!matricesInitialized) begin
            // Copy to internal matrices in the first cycle after reset
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    injectA[i][j] <= matrixA[i][j];
                    injectB[i][j] <= matrixB[i][j];
                end
            end
            matricesInitialized <= 1'b1;
        end
    end

    // Main state machine
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            currentMainState <= idle;
            matrixIndex <= 5'b0;
            resultIndex <= 5'b0;
        end else begin
            currentMainState <= nextMainState;

            case (currentMainState)
                loadMatrixA, loadMatrixB: begin
                    if (operationDone && matrixIndex < 15) begin
                        matrixIndex <= matrixIndex + 1;
                    end else if (operationDone && matrixIndex == 15) begin
                        matrixIndex <= 5'b0;
                    end
                end

                storeResults: begin
                    if (operationDone && resultIndex < 15) begin
                        resultIndex <= resultIndex + 1;
                    end else if (operationDone && resultIndex == 15) begin
                        resultIndex <= 5'b0;
                    end
                end
                default: begin
                    // No index change for other states, or reset if needed
                end
            endcase
        end
    end

    // State transition logic
    always_comb begin
        nextMainState = currentMainState;
		  
        allowProgression = !stepEnableSwitch || stepButtonEdge;
		  
        case (currentMainState)
            idle: begin
                if (initDelayDone && matricesInitialized && allowProgression) begin
                    nextMainState = loadMatrixA;
                end
            end

            loadMatrixA: begin
                if (operationDone && matrixIndex == 15 && allowProgression) begin
                    nextMainState = loadMatrixB;
                end
            end

            loadMatrixB: begin
                if (operationDone && matrixIndex == 15 && allowProgression) begin
                    nextMainState = systolicCompute;
                end
            end

            systolicCompute: begin
                if (systolicDone && allowProgression) begin
                    nextMainState = storeResults;
                end
            end

            storeResults: begin
                if (operationDone && resultIndex == 15 && allowProgression) begin
                    nextMainState = displayResults;
                end
            end

            displayResults: begin
                nextMainState = displayResults; // Stay here
            end

            default: begin
                nextMainState = idle;
            end
        endcase
    end

    // Memory operations control
    always_comb begin
        startWrite = 1'b0;
        startRead = 1'b0;
        currentAddress = 25'b0;
        currentWriteData = 16'b0;

        case (currentMainState)
            loadMatrixA: begin
                if (!busy) begin // Only start if not busy
                    startWrite = 1'b1;
                    currentAddress = MATRIX_A_BASE + matrixIndex;
                    currentWriteData = matrixA[matrixIndex >> 2][matrixIndex & 3];
                end
            end

            loadMatrixB: begin
                if (!busy) begin // Only start if not busy
                    startWrite = 1'b1;
                    currentAddress = MATRIX_B_BASE + matrixIndex;
                    currentWriteData = matrixB[matrixIndex >> 2][matrixIndex & 3];
                end
            end

            storeResults: begin
                if (!busy) begin // Only start if not busy
                    startWrite = 1'b1;
                    currentAddress = MATRIX_C_BASE + resultIndex;
                    currentWriteData = resultMatrix[resultIndex >> 2][resultIndex & 3][15:0];
                end
            end
            default: begin
                // No memory operation
            end
        endcase
    end

    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            systolicStart <= 1'b0;
        end else begin
            case (currentMainState)
                systolicCompute: begin
                    if (!systolicStart && !systolicBusy && !systolicDone) begin
                        // Start the systolic computation
                        systolicStart <= 1'b1;
                    end else if (systolicStart) begin
                        // Deactivate start after one cycle
                        systolicStart <= 1'b0;
                    end
                end

                default: begin
                    systolicStart <= 1'b0;
                end
            endcase
        end
    end

    // Value selection for display
    always_comb begin
        logic [3:0] row;
        logic [3:0] col;

        if (displayMode == 4'b0) begin // Showing matrix elements
            row = displayResultIndex >> 2;
            col = displayResultIndex & 3;
            displayValue = resultMatrix[row][col];
        end else begin // Showing arithmetic intensity
            displayValue = arithmeticIntensity;
        end
    end

    // 7-segment decoding function
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

    // Assign to 7-segment displays - SHOW IN HEXADECIMAL
    assign hex0 = hexTo7Seg(displayValue[3:0]);
    assign hex1 = hexTo7Seg(displayValue[7:4]);
    assign hex2 = hexTo7Seg(displayValue[11:8]);
    assign hex3 = hexTo7Seg(displayValue[15:12]);

endmodule