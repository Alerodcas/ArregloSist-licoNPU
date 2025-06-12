`timescale 1ns / 1ps

module PE_tb;

    // Parámetros
    parameter DATA_WIDTH = 16;

    // Señales del DUT (Device Under Test)
    logic                      clk;
    logic                      rst;
    logic                      enable;
    logic signed [DATA_WIDTH-1:0] a_in, b_in;
    logic        [1:0]         activation_mode;
    logic signed [DATA_WIDTH-1:0] a_out, b_out, result;

    // Instancia del módulo PE
    PE #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .a_in(a_in),
        .b_in(b_in),
        .activation_mode(activation_mode),
        .enable(enable),
        .a_out(a_out),
        .b_out(b_out),
        .result(result)
    );

    // Generador de reloj (10ns periodo)
    always #5 clk = ~clk;

    // Tareas auxiliares
    task tick();
        begin
            @(posedge clk);
        end
    endtask

    task send_input(logic signed [DATA_WIDTH-1:0] a, b);
        begin
            a_in = a;
            b_in = b;
            enable = 1;
            tick();
            enable = 0;
        end
    endtask

    // Simulación
    initial begin
        $display("Inicio de simulación...");
        $dumpfile("PE_tb.vcd");   // Para GTKWave si usas
        $dumpvars(0, PE_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        enable = 0;
        a_in = 0;
        b_in = 0;
        activation_mode = 2'b00; // RELU por defecto

        tick();  // Primer ciclo con reset activo
        rst = 0;

        // Ciclo 1: enviar 3 * 4
        send_input(3, 4);  // acc = 12

        // Ciclo 2: enviar -2 * 5
        send_input(-2, 5); // acc = 12 + (-10) = 2

        // Ciclo 3: enviar 7 * -1
        send_input(7, -1); // acc = 2 + (-7) = -5

        // Aplicar RELU (debería quedar 0)
        activation_mode = 2'b00;
        tick();
        $display("RELU: result = %0d", result);

        // Reiniciar acumulador y repetir con LINEAR
        rst = 1;
        tick();
        rst = 0;

        send_input(3, 2);  // acc = 6
        send_input(4, 1);  // acc = 6 + 4 = 10
        activation_mode = 2'b01; // LINEAR
        tick();
        $display("LINEAR: result = %0d", result);

        // Tanh test
        rst = 1;
        tick();
        rst = 0;

        send_input(80, 1); // acc = 80
        activation_mode = 2'b10; // TANH
        tick();
        $display("TANH approx: result = %0d", result);

    end

endmodule
