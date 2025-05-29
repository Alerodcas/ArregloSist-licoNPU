#ifndef PE_H
#define PE_H

#include <cstdint>
#include <algorithm>

using DataType = int16_t;

// Función de activación
inline DataType relu(DataType x) {
    return std::max(static_cast<DataType>(0), x); //Si x < 0, devuelve 0. Si x >= 0, devuelve x.
}

// PE básico: realiza multiplicación, suma acumulativa y ReLU
inline DataType PE(DataType a, DataType b, DataType acc) {
    return relu(acc + a * b);
}

#endif // PE_H
