module matrix_defined #(
    parameter int N = 4
)(
    output logic signed [31:0] A [N][N],
    output logic signed [31:0] B [N][N]
);

    // Asignación inicial de matrices A y B
    initial begin
        // Matriz A
        A[0][0] = 1;  A[0][1] = 2;  A[0][2] = 3;  A[0][3] = 4;
        A[1][0] = 5;  A[1][1] = 6;  A[1][2] = 7;  A[1][3] = 8;
        A[2][0] = 9;  A[2][1] = 0;  A[2][2] = 1;  A[2][3] = 2;
        A[3][0] = 3;  A[3][1] = 4;  A[3][2] = 5;  A[3][3] = 6;

        // Matriz B
        B[0][0] = 7;  B[0][1] = 6;  B[0][2] = 5;  B[0][3] = 4;
        B[1][0] = 3;  B[1][1] = 2;  B[1][2] = 1;  B[1][3] = 0;
        B[2][0] = 1;  B[2][1] = 2;  B[2][2] = 3;  B[2][3] = 4;
        B[3][0] = 5;  B[3][1] = 6;  B[3][2] = 7;  B[3][3] = 8;
    end

endmodule
