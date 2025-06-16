`timescale 1ns/1ps

module menu_tb;

    logic clk = 0;
    logic rstN = 0;

    always #5 clk = ~clk;

    localparam int OPCION_ELEGIDA = 2;     // Cambiar entre 1 o 2
    localparam int ACTIVACION_ELEGIDA = 2; // 0: ReLU, 1: Lineal, 2: Tanh

    menu #(
        .option(OPCION_ELEGIDA),
        .activation_mode(ACTIVACION_ELEGIDA)
    ) dut (
        .clk(clk),
        .rstN(rstN)
    );

    initial begin
        $display("Iniciando testbench...");
        #10 rstN = 1;
        #500 $finish;
    end

endmodule
