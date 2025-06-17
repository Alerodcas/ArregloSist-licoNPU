
// Control Stepping Module
module stepController(
    input  logic clock,
    input  logic resetN,
    input  logic stepButton,
    input  logic stepEnableSwitch,
    output logic stepButtonEdge,
    output logic allowProgression
);

    logic stepButtonPrev;

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

    // Allow progression logic
    always_comb begin
        allowProgression = !stepEnableSwitch || stepButtonEdge;
    end

endmodule