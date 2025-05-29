#include "Matrix.h"
#include "SystolicModel.h"

int main() {
    const int SIZE = 4;
    Matrix A(SIZE, SIZE);
    Matrix B(SIZE, SIZE);

    A.fillRandom(-5, 5);
    B.fillRandom(-5, 5);

    std::cout << "Matriz A:\n";
    A.print();

    std::cout << "\nMatriz B:\n";
    B.print();

    Matrix C = systolicMultiply(A, B);

    std::cout << "\nResultado C = ReLU(A x B):\n";
    C.print();

    return 0;
}
