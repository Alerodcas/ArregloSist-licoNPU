`timescale 1ns / 1ps

module peTestbench;

    // Parameters for the Device Under Test (DUT)
    // Ensure these match the parameters of your 'pe' module
    localparam int wA = 16; // Input data width for A/B
    localparam int wP = 32; // Accumulator (psum) width

    // Testbench signals (wires and registers)
    logic           clk;
    logic           rstN;

    logic signed [wA-1:0] inA;
    logic signed [wA-1:0] inB;
    logic           loadA;
    logic           loadB;

    logic signed [wA-1:0] shiftAIn;
    logic signed [wA-1:0] shiftBIn;

    logic signed [wA-1:0] shiftAOut;
    logic signed [wA-1:0] shiftBOut;
    logic signed [wP-1:0] psumOut;

    // Instantiate the Device Under Test (DUT)
    pe #(
        .wA (wA),
        .wP (wP)
    ) dut (
        .clk        (clk),
        .rstN       (rstN),
        .inA        (inA),
        .inB        (inB),
        .loadA      (loadA),
        .loadB      (loadB),
        .shiftAIn   (shiftAIn),
        .shiftBIn   (shiftBIn),
        .shiftAOut  (shiftAOut),
        .shiftBOut  (shiftBOut),
        .psumOut    (psumOut)
    );

    // Clock generation
    localparam int CLOCK_PERIOD = 10; // 10 ns period -> 100 MHz clock
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize all inputs to known safe values
        rstN        = 0;
        inA         = 0;
        inB         = 0;
        loadA       = 0;
        loadB       = 0;
        shiftAIn    = 0;
        shiftBIn    = 0;

        // Apply reset
        #CLOCK_PERIOD; // Wait one clock cycle
        rstN = 1;      // De-assert reset
        $display("--------------------------------------");
        $display("Starting Test: Reset Released");
        $display("--------------------------------------");

        // --- Test Case 1: Load initial values and perform MAC ---
        $display("--- Test Case 1: Load and initial MAC ---");
        inA   = 5;
        inB   = 3;
        loadA = 1;
        loadB = 1;
        shiftAIn = 0; // Not used when loadA/B are 1
        shiftBIn = 0; // Not used when loadA/B are 1
        #CLOCK_PERIOD; // At posedge clk, inA/inB are loaded, MAC 0 + (5*3) = 15
        $display("Time %0t: inA=%0d, inB=%0d, loadA=%0d, loadB=%0d, psumOut=%0d",
                 $time, inA, inB, loadA, loadB, psumOut);
        // Expected: psumOut should still be 0 here, it updates on the next clock edge after values are loaded.
        // It will be 15 AFTER the next clock edge.

        #CLOCK_PERIOD; // Values are loaded. Now check psumOut
        $display("Time %0t: aReg=%0d, bReg=%0d, psumOut=%0d, shiftAOut=%0d, shiftBOut=%0d",
                 $time, dut.aReg, dut.bReg, psumOut, shiftAOut, shiftBOut);
        // Expected: aReg = 5, bReg = 3, psumOut = 15, shiftAOut = 5, shiftBOut = 3

        // --- Test Case 2: Shift new values and perform MAC ---
        $display("--- Test Case 2: Shift and subsequent MAC ---");
        inA   = 0; // Don't load from inA
        inB   = 0; // Don't load from inB
        loadA = 0; // Take from shiftAIn
        loadB = 0; // Take from shiftBIn
        shiftAIn = 10;
        shiftBIn = 2;
        #CLOCK_PERIOD; // At posedge clk, aReg=10, bReg=2. MAC: 15 + (5*3) = 30
                       // Note: psum calculation uses *previous* cycle's aReg and bReg
        $display("Time %0t: shiftAIn=%0d, shiftBIn=%0d, psumOut=%0d",
                 $time, shiftAIn, shiftBIn, psumOut);
        // Expected: psumOut will be 30 after this cycle (15 from previous + 15 from last aReg*bReg)

        #CLOCK_PERIOD; // Check updated values
        $display("Time %0t: aReg=%0d, bReg=%0d, psumOut=%0d, shiftAOut=%0d, shiftBOut=%0d",
                 $time, dut.aReg, dut.bReg, psumOut, shiftAOut, shiftBOut);
        // Expected: aReg = 10, bReg = 2, psumOut = 15 + (5*3) + (10*2) = 15 + 15 + 20 = 50.
        // Wait, psumReg <= psumReg + aReg * bReg;
        // Cycle 1: rstN=0, aReg=0,bReg=0,psumReg=0
        // Cycle 2: rstN=1, loadA=1,inA=5,loadB=1,inB=3
        //          aReg <= 5, bReg <= 3, psumReg <= 0 + (0*0) = 0
        // Cycle 3: loadA=0,shiftAIn=10,loadB=0,shiftBIn=2
        //          aReg <= 10, bReg <= 2, psumReg <= 0 + (5*3) = 15
        // Cycle 4:
        //          aReg <= ..., bReg <= ..., psumReg <= 15 + (10*2) = 35
        // So, after the second #CLOCK_PERIOD of TC2, psumOut should be 35.

        // --- Test Case 3: More shifts and MAC operations ---
        $display("--- Test Case 3: Chaining MAC operations ---");
        shiftAIn = -1;
        shiftBIn = 7;
        #CLOCK_PERIOD; // aReg=-1, bReg=7. MAC: 35 + (10*2) = 55
        $display("Time %0t: psumOut=%0d", $time, psumOut);
        // Expected: psumOut = 35 + 20 = 55

        #CLOCK_PERIOD; // Check updated values
        $display("Time %0t: aReg=%0d, bReg=%0d, psumOut=%0d, shiftAOut=%0d, shiftBOut=%0d",
                 $time, dut.aReg, dut.bReg, psumOut, shiftAOut, shiftBOut);
        // Expected: aReg = -1, bReg = 7, psumOut = 55 + (-1*7) = 48

        // --- Test Case 4: Reset during operation ---
        $display("--- Test Case 4: Reset ---");
        rstN = 0; // Assert reset
        #CLOCK_PERIOD;
        $display("Time %0t: After reset: psumOut=%0d", $time, psumOut);
        // Expected: psumOut = 0

        #CLOCK_PERIOD; // Release reset and re-initialize
        rstN = 1;
        inA = 1; inB = 2; loadA = 1; loadB = 1;
        #CLOCK_PERIOD; // Load 1, 2
        $display("Time %0t: Re-init: psumOut=%0d", $time, psumOut);
        // Expected: psumOut = 0 (still, because MAC uses previous cycle's A/B)
        #CLOCK_PERIOD; // First MAC after re-init
        $display("Time %0t: Re-init: psumOut=%0d", $time, psumOut);
        // Expected: psumOut = 0 + (1*2) = 2

        $display("--------------------------------------");
        $display("Test Complete.");
        $display("--------------------------------------");
        $stop; // Terminate simulation
    end

    // Optional: Monitor signals for waveform viewing
    initial begin
        $dumpfile("pe.vcd"); // Creates a Value Change Dump file
        $dumpvars(0, peTestbench); // Dumps all signals in the current scope
    end

endmodule