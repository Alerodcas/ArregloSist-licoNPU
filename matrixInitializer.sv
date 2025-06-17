// matrix Initialization Module
module matrixInitializer(
    input  logic clock,
    input  logic resetN,
    output logic signed [15:0] injectA [0:3][0:3],
    output logic signed [15:0] injectB [0:3][0:3]
);

    // Temporary matrices for initialization
    logic signed [15:0] matrixA [0:3][0:3];
    logic signed [15:0] matrixB [0:3][0:3];
    logic matricesInitialized;

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

            // Initialize output matrices
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    injectA[i][j] <= 16'b0;
                    injectB[i][j] <= 16'b0;
                end
            end
        end else if (!matricesInitialized) begin
            // Copy to output matrices in the first cycle after reset
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    injectA[i][j] <= matrixA[i][j];
                    injectB[i][j] <= matrixB[i][j];
                end
            end
            matricesInitialized <= 1'b1;
        end
    end

endmodule