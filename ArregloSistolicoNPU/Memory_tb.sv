`timescale 1ns / 1ps

module Memory_tb;

    // Parámetros
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 8;
    parameter LATENCY    = 3;

    // Señales
    logic                      clk;
    logic                      rst;
    logic                      req_valid;
    logic                      req_write;
    logic [ADDR_WIDTH-1:0]     req_addr;
    logic signed [DATA_WIDTH-1:0] req_data;
    logic                      resp_valid;
    logic signed [DATA_WIDTH-1:0] resp_data;

    // Instancia del DUT
    Memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .LATENCY(LATENCY)
    ) dut (
        .clk(clk),
        .rst(rst),
        .req_valid(req_valid),
        .req_write(req_write),
        .req_addr(req_addr),
        .req_data(req_data),
        .resp_valid(resp_valid),
        .resp_data(resp_data)
    );

    // Reloj
    always #5 clk = ~clk;

    // Utilidad para esperar ciclos
    task wait_cycles(int n);
        for (int i = 0; i < n; i++) @(posedge clk);
    endtask

    // Simulación
    initial begin
        $display("Inicio de simulación de memoria");
        $dumpfile("memory_tb.vcd");
        $dumpvars(0, Memory_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        req_valid = 0;
        req_write = 0;
        req_addr  = 0;
        req_data  = 0;

        wait_cycles(2);
        rst = 0;

        // Escribir valor 42 en la dirección 10
        @(posedge clk);
        req_valid <= 1;
        req_write <= 1;
        req_addr  <= 8'd10;
        req_data  <= 16'sd42;
        @(posedge clk);
        req_valid <= 0; // solicitud enviada

        // Esperar suficiente tiempo para completar la escritura
        wait_cycles(LATENCY + 1);

        // Leer dirección 10
        @(posedge clk);
        req_valid <= 1;
        req_write <= 0;
        req_addr  <= 8'd10;
        req_data  <= 16'sd0; // ignorado
        @(posedge clk);
        req_valid <= 0;

        // Esperar hasta que resp_valid sea alto
        while (!resp_valid) @(posedge clk);
        $display("Lectura dirección 10 = %0d", resp_data);

        // Verificar valor leído
        if (resp_data === 42)
            $display("✅ Lectura correcta");
        else
            $display("❌ Lectura incorrecta");

        // Finalizar
        wait_cycles(2);
        $display("Fin de simulación");
        $finish;
    end

endmodule
