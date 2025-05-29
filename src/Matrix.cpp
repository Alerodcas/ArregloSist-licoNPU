#include "Matrix.h"
#include <iomanip>
#include <random>


Matrix::Matrix(int rows, int cols) {
    data.resize(rows, std::vector<DataType>(cols, 0));
}

void Matrix::fillWithValue(DataType value) {
    for (auto& row : data)
        for (auto& cell : row)
            cell = value;
}

void Matrix::fillRandom(int minVal, int maxVal) {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<DataType> dist(minVal, maxVal);

    for (auto& row : data)
        for (auto& cell : row)
            cell = dist(gen);
}

void Matrix::print() const {
    for (const auto& row : data) {
        for (auto val : row)
            std::cout << std::setw(5) << val << " ";
        std::cout << '\n';
    }
}
