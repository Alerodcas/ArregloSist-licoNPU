// Principal State Machine 
module mainStateMachine(
    input  logic clock,
    input  logic resetN,
    input  logic allowProgression,
    input  logic operationDone,
    input  logic systolicDone,
    output logic [3:0] currentMainState,
    output logic [3:0] nextMainState,
    output logic [4:0] matrixIndex,
    output logic [4:0] resultIndex
);

    // State definitions
    typedef enum logic [3:0] {
        idle,
        loadMatrixA,
        loadMatrixB,
        systolicCompute,
        storeResults,
        displayResults
    } MainState;

    MainState currentState, nextState;
    logic [25:0] initDelayCounter;
    logic        initDelayDone;
    logic        matricesInitialized;

    // Assign outputs
    assign currentMainState = currentState;
    assign nextMainState = nextState;

    // Initialization delay counter
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            initDelayCounter <= 26'b0;
            initDelayDone <= 1'b0;
            matricesInitialized <= 1'b0;
        end else begin
            if (initDelayCounter < 26'd50000000) begin // ~1 second at 50MHz
                initDelayCounter <= initDelayCounter + 1;
            end else begin
                initDelayDone <= 1'b1;
                matricesInitialized <= 1'b1; // Assume matrices are initialized
            end
        end
    end

    // State register
    always_ff @(posedge clock or negedge resetN) begin
        if (!resetN) begin
            currentState <= idle;
            matrixIndex <= 5'b0;
            resultIndex <= 5'b0;
        end else begin
            currentState <= nextState;

            case (currentState)
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
                    // No index change for other states
                end
            endcase
        end
    end

    // Next state logic
    always_comb begin
        nextState = currentState;

        case (currentState)
            idle: begin
                if (initDelayDone && matricesInitialized && allowProgression) begin
                    nextState = loadMatrixA;
                end
            end

            loadMatrixA: begin
                if (operationDone && matrixIndex == 15 && allowProgression) begin
                    nextState = loadMatrixB;
                end
            end

            loadMatrixB: begin
                if (operationDone && matrixIndex == 15 && allowProgression) begin
                    nextState = systolicCompute;
                end
            end

            systolicCompute: begin
                if (systolicDone && allowProgression) begin
                    nextState = storeResults;
                end
            end

            storeResults: begin
                if (operationDone && resultIndex == 15 && allowProgression) begin
                    nextState = displayResults;
                end
            end

            displayResults: begin
                nextState = displayResults; // Stay here
            end

            default: begin
                nextState = idle;
            end
        endcase
    end

endmodule