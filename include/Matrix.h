#ifndef MATRIX_H
#define MATRIX_H

#include <vector>
#include <iostream>
#include <cstdint>

/*
int16_t
Rango: de -32,768 a 32,767.
Más liviano: menor uso de memoria y recursos.
Suficiente si los valores no son grandes.

int32_t
Rango: mucho mayor.
Usa más memoria y lógica (en hardware y en simulación).
Más robusto para valores grandes o muchas acumulaciones.
 */

using DataType = int16_t;

class Matrix {
public:
    Matrix(int rows, int cols);

    void fillRandom(int minVal = -10, int maxVal = 10); // Opcional para pruebas
    void fillWithValue(DataType value);
    void print() const;

    int rows() const { return data.size(); }
    int cols() const { return data[0].size(); }

    std::vector<std::vector<DataType>> data;
};

#endif // MATRIX_H
