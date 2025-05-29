#include "Matrix.h"
#include "SystolicModel.h"
#include <cassert>

bool compareMatrices(const Matrix& A, const Matrix& B) {
    if (A.rows() != B.rows() || A.cols() != B.cols()) return false;

    for (int i = 0; i < A.rows(); ++i) {
        for (int j = 0; j < A.cols(); ++j) {
            if (A.data[i][j] != B.data[i][j]) {
                std::cout << "Diferencia en [" << i << "][" << j << "]: "
                          << A.data[i][j] << " != " << B.data[i][j] << std::endl;
                return false;
            }
        }
    }

    return true;
}

void testSimpleMultiplication() {
    Matrix A(2, 2);
    Matrix B(2, 2);

    A.data = {{1, -2},
              {4,  5}};
    B.data = {{-1, 3},
              { 2, -6}};

    Matrix expected(2, 2);
    expected.data = {{0, 15},  // ReLU(1*-1 + -2*2 = -1 -4 = -5) = 0
                     {6,  0}}; // ReLU(4*-1 + 5*2 = -4 + 10 = 6), ReLU(12 -30 = -18) = 0

    Matrix result = systolicMultiply(A, B);

    if (compareMatrices(result, expected)) {
        std::cout << "[OK] testSimpleMultiplication\n";
    } else {
        std::cout << "[FAIL] testSimpleMultiplication\n";
        std::cout << "Esperado:\n";
        expected.print();
        std::cout << "Obtenido:\n";
        result.print();
    }
}

// Función auxiliar: hace A x B + ReLU sin usar systolicMultiply
Matrix referenceMultiply(const Matrix& A, const Matrix& B) {
    int rows = A.rows();
    int cols = B.cols();
    int shared = A.cols();
    Matrix C(rows, cols);

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            DataType acc = 0;
            for (int k = 0; k < shared; ++k) {
                acc += A.data[i][k] * B.data[k][j];
            }
            C.data[i][j] = std::max(static_cast<DataType>(0), acc); // ReLU
        }
    }

    return C;
}

void testRealMatrixExample() {
    Matrix A(4, 4);
    A.data = {
        { 3,  4, -1, -1 },
        { 2,  2, -4,  5 },
        { 1, -1,  0,  2 },
        { 2,  0, -1, -1 }
    };

    Matrix B(4, 4);
    B.data = {
        { 0, -4,  2,  4 },
        { 4,  5,  1, -2 },
        { 3,  1,  4, -3 },
        { 2,  2,  0, -3 }
    };

    Matrix expected(4, 4);
    expected.data = {
        { 11,  5, 6, 10 },
        {  6,  8, 0,  1 },
        {  0,  0, 1,  0 },
        {  0,  0, 0, 14 }
    };


    Matrix result = systolicMultiply(A, B);

    if (compareMatrices(result, expected)) {
        std::cout << "[OK] testRealMatrixExample\n";
    } else {
        std::cout << "[FAIL] testRealMatrixExample\n";
        std::cout << "Esperado:\n";
        expected.print();
        std::cout << "Obtenido:\n";
        result.print();
    }
}


void testRandomMatrixComparison() {
    const int SIZE = 4;

    Matrix A(SIZE, SIZE);
    Matrix B(SIZE, SIZE);

    A.fillRandom(-5, 5);
    B.fillRandom(-5, 5);

    Matrix expected = referenceMultiply(A, B); // implementación clara
    Matrix result = systolicMultiply(A, B);    // tu implementación

    if (compareMatrices(result, expected)) {
        std::cout << "[OK] testRandomMatrixComparison\n";
    } else {
        std::cout << "[FAIL] testRandomMatrixComparison\n";
        std::cout << "Matriz A:\n"; A.print();
        std::cout << "Matriz B:\n"; B.print();
        std::cout << "Esperado:\n"; expected.print();
        std::cout << "Obtenido:\n"; result.print();
    }
}

int main() {
    testSimpleMultiplication();
    testRealMatrixExample();
    testRandomMatrixComparison();
    return 0;
}

