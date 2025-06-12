`timescale 1ns/1ps
module ArregloSistolicoNPU_tb();

    parameter N = 4;
    parameter MEM_SIZE = 512;

    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    logic [1:0] activation_mode = 2'd0; // 0 = ReLU
    logic done;

    // Instancia del DUT (Device Under Test)
    ArregloSistolicoNPU #(.N(N), .MEM_SIZE(MEM_SIZE)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .activation_mode(activation_mode),
        .done(done)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Matrices de prueba
    logic signed [15:0] A[N][N], B[N][N];

    initial begin
        $display("Iniciando simulación...");
        rst = 1;
        #20;
        rst = 0;

        // Inicializar matrices A y B (puedes cambiar a casos aleatorios)
        A = '{ '{1, 2, 3, 4}, '{5, 6, 7, 8}, '{9, 0, 1, 2}, '{3, 4, 5, 6} };
        B = '{ '{7, 6, 5, 4}, '{3, 2, 1, 0}, '{1, 2, 3, 4}, '{5, 6, 7, 8} };

        // Cargar matrices en memoria (simulado)
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++) begin
                // Lógica para escribir en memoria simulada (por ejemplo: usar funciones del módulo `Memory`)
                // Esto depende de cómo implementaste `Memory`.
            end

        #20;
        start = 1;
        #10;
        start = 0;

        // Esperar a que termine
        wait (done);
        #10;

        // Leer y mostrar matriz C
        $display("Resultado C:");
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                // Lógica para leer desde la memoria simulada
                // $display("%0d ", valor);
            end
            $display("");
        end

        $display("Simulación finalizada.");
        $finish;
    end
endmodule
