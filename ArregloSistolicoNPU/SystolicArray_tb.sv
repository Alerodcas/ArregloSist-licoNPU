`timescale 1ns/1ps

module SystolicArray_tb;

    parameter N = 4;
    parameter WIDTH = 16;
    parameter CYCLES = 2*N + N; // Mínimo necesario para completar procesamiento

    logic clk, rst;
    logic [31:0] current_cycle;
    logic activate_results;
    logic [1:0] activation_mode;

    logic [N-1:0][N-1:0][WIDTH-1:0] A, B;
    logic [N-1:0][N-1:0][WIDTH-1:0] C;

    // Instantiate DUT
    SystolicArray #(.N(N), .WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .current_cycle(current_cycle),
        .activate_results(activate_results),
        .activation_mode(activation_mode),
        .C(C)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Stimulus
    initial begin
        rst = 1;
        current_cycle = 0;
        activate_results = 0;
        activation_mode = 2'd0; // ReLU

        // Sample matrices A and B
        A = '{ '{1, 2, 3, 4},
               '{5, 6, 7, 8},
               '{9, 10, 11, 12},
               '{13, 14, 15, 16} };

        B = '{ '{1, 0, 0, 0},
               '{0, 1, 0, 0},
               '{0, 0, 1, 0},
               '{0, 0, 0, 1} };

        #20 rst = 0;

        // Clock through processing cycles
        repeat (CYCLES) begin
            @(posedge clk);
            current_cycle++;
        end

        // Activate result output
        activate_results = 1;

        #10;

        $display("Resultado matriz C (A x B):");
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                $write("%0d\t", C[i][j]);
            end
            $write("\n");
        end

        $finish;
    end

endmodule
