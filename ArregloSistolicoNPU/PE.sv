module PE #(
    parameter DATA_WIDTH = 16
)(
    input  logic                      clk,
    input  logic                      rst,
    input  logic signed [DATA_WIDTH-1:0] a_in,
    input  logic signed [DATA_WIDTH-1:0] b_in,
    input  logic  [1:0]               activation_mode, // 2 bits: 00=RELU, 01=LINEAR, 10=TANH
    input  logic                      enable,  // permite controlar cuándo hacer tick
    output logic signed [DATA_WIDTH-1:0] a_out,
    output logic signed [DATA_WIDTH-1:0] b_out,
    output logic signed [DATA_WIDTH-1:0] result  // salida después de aplicar activación
);

    // Registros internos
    logic signed [DATA_WIDTH-1:0] a_reg, b_reg;
    logic signed [2*DATA_WIDTH-1:0] acc_raw;  // acumulador más grande para evitar overflow
    logic signed [DATA_WIDTH-1:0] acc;        // versión truncada (salida)

    // Captura de entradas y acumulación
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg   <= '0;
            b_reg   <= '0;
            acc_raw <= '0;
        end else if (enable) begin
            a_reg   <= a_in;
            b_reg   <= b_in;
            acc_raw <= acc_raw + a_in * b_in;
        end
    end

    // Propagación de señales (Output Stationary)
    assign a_out = a_reg;
    assign b_out = b_reg;

    // Aplicación de función de activación
    always_comb begin
        unique case (activation_mode)
            2'b00: acc = (acc_raw > 0) ? acc_raw[DATA_WIDTH-1:0] : '0;        // ReLU
            2'b01: acc = acc_raw[DATA_WIDTH-1:0];                             // Linear
            2'b10: acc = tanh_approx(acc_raw[DATA_WIDTH-1:0]);               // Tanh aprox
            default: acc = acc_raw[DATA_WIDTH-1:0];
        endcase
    end

    // Salida final
    assign result = acc;

    // Función de activación: tanh aproximado (simple)
    function logic signed [DATA_WIDTH-1:0] tanh_approx(input logic signed [DATA_WIDTH-1:0] x);
        logic signed [DATA_WIDTH-1:0] y;
        begin
            if (x > 64)       y = 127;
            else if (x < -64) y = -127;
            else              y = x;  // línea recta dentro del rango
            return y;
        end
    endfunction

endmodule
