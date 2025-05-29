#ifndef SYSTOLICMODEL_H
#define SYSTOLICMODEL_H

#include "Matrix.h"
#include "PE.h"

// Multiplica A x B usando PEs y ReLU, estilo arreglo sistólico
Matrix systolicMultiply(const Matrix& A, const Matrix& B);

#endif // SYSTOLICMODEL_H
