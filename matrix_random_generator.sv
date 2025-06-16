module matrix_random_generator #(
    parameter int N = 4
)(
    input  logic clk,
    input  logic rstN,
    input  logic start,
    output logic signed [31:0] matrix [N][N],
    output logic done
);

    logic [3:0] lfsr;
    logic [5:0] count; // para contar hasta N*N
    logic [3:0] random_val;
    int i = 0, j = 0;

    always_ff @(posedge clk or negedge rstN) begin
        if (!rstN) begin
            lfsr <= 4'b0001;  // semilla inicial
            count <= 0;
            done <= 0;
            i <= 0;
            j <= 0;
        end else if (start && !done) begin
            // Generador LFSR de 4 bits
            lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
            
            // Convertir a rango -5 a 5
            random_val = lfsr % 11;                  // [0,10]
            matrix[i][j] <= random_val - 5;          // [-5,5]

            // Avance de posición
            if (j == N-1) begin
                j <= 0;
                if (i == N-1) begin
                    done <= 1;
                end else begin
                    i <= i + 1;
                end
            end else begin
                j <= j + 1;
            end

            count <= count + 1;
        end
    end

endmodule
