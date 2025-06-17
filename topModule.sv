// Módulo principal simplificado
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
    output logic [6:0]  hex0, hex1, hex2, hex3
);

    // Parameters
    parameter [24:0] MATRIX_A_BASE = 25'h000000;
    parameter [24:0] MATRIX_B_BASE = 25'h000040;
    parameter [24:0] MATRIX_C_BASE = 25'h000080;

    // Internal signals
    logic [24:0] sdramAddress;
    logic [1:0]  sdramByteEnableN;
    logic        sdramChipSelect;
    logic [15:0] sdramWriteData;
    logic        sdramReadN, sdramWriteN;
    logic [15:0] sdramReadData;
    logic        sdramReadDataValid;
    logic        sdramWaitRequest;

    logic        startWrite, startRead;
    logic [24:0] currentAddress;
    logic [15:0] currentWriteData;
    logic [15:0] currentReadData;
    logic        operationDone;
    logic        busy;

    logic signed [15:0] injectA [0:3][0:3];
    logic signed [15:0] injectB [0:3][0:3];
    logic signed [15:0] resultMatrix [0:3][0:3];
    logic               systolicStart;
    logic               systolicBusy;
    logic               systolicDone;

    logic [31:0] displayValue;
    logic        stepButtonEdge;
    logic        allowProgression;

    // Main state machine signals
    typedef enum logic [3:0] {
        idle,
        loadMatrixA,
        loadMatrixB,
        systolicCompute,
        storeResults,
        displayResults
    } MainState;

    MainState currentMainState, nextMainState;
    logic [4:0] matrixIndex, resultIndex;

    // SDRAM Core
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

    // SDRAM Controller
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

    // Systolic Array Controller
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

    // Step Control Module
    stepController stepCtrl (
        .clock(clock),
        .resetN(resetN),
        .stepButton(stepButton),
        .stepEnableSwitch(stepEnableSwitch),
        .stepButtonEdge(stepButtonEdge),
        .allowProgression(allowProgression)
    );

    // Matrix Initialization Module
    matrixInitializer matrixInit (
        .clock(clock),
        .resetN(resetN),
        .injectA(injectA),
        .injectB(injectB)
    );

    // Main State Machine Module
    mainStateMachine stateMachine (
        .clock(clock),
        .resetN(resetN),
        .allowProgression(allowProgression),
        .operationDone(operationDone),
        .systolicDone(systolicDone),
        .currentMainState(currentMainState),
        .nextMainState(nextMainState),
        .matrixIndex(matrixIndex),
        .resultIndex(resultIndex)
    );

    // Memory Operations Controller
    memoryController memCtrl (
        .currentMainState(currentMainState),
        .matrixIndex(matrixIndex),
        .resultIndex(resultIndex),
        .busy(busy),
        .injectA(injectA),
        .injectB(injectB),
        .resultMatrix(resultMatrix),
        .MATRIX_A_BASE(MATRIX_A_BASE),
        .MATRIX_B_BASE(MATRIX_B_BASE),
        .MATRIX_C_BASE(MATRIX_C_BASE),
        .startWrite(startWrite),
        .startRead(startRead),
        .currentAddress(currentAddress),
        .currentWriteData(currentWriteData)
    );

    // Systolic Control Module
    systolicControl systCtrl (
        .clock(clock),
        .resetN(resetN),
        .currentMainState(currentMainState),
        .systolicBusy(systolicBusy),
        .systolicDone(systolicDone),
        .systolicStart(systolicStart)
    );

    // Display Controller
    displayController dispCtrl (
        .clock(clock),
        .resetN(resetN),
        .nextButton(nextButton),
        .resultMatrix(resultMatrix),
        .displayValue(displayValue),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

endmodule