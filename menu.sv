`timescale 1ns/1ps

module menu #(
    parameter int N = 4,
    parameter int option = 1,              // Opción del menú
    parameter int activation_mode = 0      // 0: ReLU, 1: Lineal, 2: Tanh
)(
    input logic clk,
    input logic rstN
);

    logic signed [31:0] A [N][N];
    logic signed [31:0] B [N][N];
    logic signed [31:0] R [N][N];
    logic signed [31:0] Activated [N][N];
    logic done;
    logic start;

    // Instancias
    matrix_defined #(N) def_inst (.A(A), .B(B));
    matrix_random_generator #(N) rand_inst (
        .clk(clk), .rstN(rstN), .start(start), .matrix(R), .done(done)
    );

    // Inicial
    initial begin
        $display("==== MENU DE PRUEBAS ====");
        $display("1. Matrices definidas (A y B)");
        $display("2. Matrices aleatorias");
        $display("3. Prueba automatica de matriz identidad");
        $display("4. Prueba automatica de matriz cero");
        $display("5. Prueba automatica de simetria A * B == B^T * A^T");
        $display("Seleccione una opcion: %0d", option);

        if (option == 1 || option == 2) begin
            $display("Seleccione modo de activacion:\n 0. ReLU\n 1. Lineal\n 2. Tanh");
            $display("Modo: %0d", activation_mode);
            case (activation_mode)
                0: $display("Activacion seleccionada: ReLU");
                1: $display("Activacion seleccionada: Lineal");
                2: $display("Activacion seleccionada: Tanh");
                default: $display("Activacion invalida");
            endcase
        end

        case (option)
            1: begin
                #1;
                $display("\nMatriz A:");
                print_matrix(A);
                $display("\nMatriz B:");
                print_matrix(B);

                $display("\nMatriz A con activacion:");
                apply_activation(A, Activated);
                print_matrix(Activated);
            end

            2: begin
                start = 1;
                wait(done);
                $display("\nMatriz aleatoria:");
                print_matrix(R);

                $display("\nMatriz aleatoria con activacion:");
                apply_activation(R, Activated);
                print_matrix(Activated);
            end

            3, 4, 5: $display("ya casi");
            default: $display("Opcion invalida.");
        endcase
    end

    // Tarea para imprimir una matriz NxN
    task print_matrix(input logic signed [31:0] mat [N][N]);
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                $write("%0d\t", mat[i][j]);
            end
            $display("");
        end
    endtask

    // Tarea para aplicar activación
    task apply_activation(
        input logic signed [31:0] in [N][N],
        output logic signed [31:0] out [N][N]
    );
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                case (activation_mode)
                    0: out[i][j] = (in[i][j] > 0) ? in[i][j] : 0;              // ReLU
                    1: out[i][j] = in[i][j];                                   // Lineal
                    2: out[i][j] = (in[i][j] > 5) ? 5 :
                                   (in[i][j] < -5) ? -5 : in[i][j];           // Simula Tanh [-5,5]
                    default: out[i][j] = 0;
                endcase
            end
        end
    endtask

endmodule
