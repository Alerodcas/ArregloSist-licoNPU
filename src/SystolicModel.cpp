#include "SystolicModel.h"

Matrix systolicMultiply(const Matrix& A, const Matrix& B) {
    int rows = A.rows();
    int cols = B.cols();
    int shared = A.cols(); // o B.rows()

    Matrix C(rows, cols); // Resultado

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            DataType acc = 0;
            for (int k = 0; k < shared; ++k) {
                acc += A.data[i][k] * B.data[k][j];
            }
            C.data[i][j] = relu(acc); // Aplicar ReLU solo al final
        }
    }

    return C;
}

