#ifndef PE_H
#define PE_H

#include <cstdint>

using Word = int16_t;

class PE {
private:
    Word a_reg = 0, b_reg = 0, acc = 0;

public:
    // Entrada para el nuevo ciclo
    Word a_in = 0, b_in = 0;

    void tick();                 // Ejecuta un ciclo (multiplica y acumula)
    void reset();                // Resetea los registros
    void apply_activation();     // Aplica ReLU
    Word get_output() const;     // Valor acumulado
    Word get_a_out() const;      // Valor a propagar a derecha
    Word get_b_out() const;      // Valor a propagar abajo
};

Word relu(Word value);

#endif // PE_H
