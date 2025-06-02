#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "SystolicArray.h"

class Controller {
private:
    SystolicArray systolic;
    std::array<std::array<Word, N>, N> matrixA{};
    std::array<std::array<Word, N>, N> matrixB{};
    int current_cycle = 0;
    int total_cycles = 2 * N + N - 2;
    bool done = false;
    bool loaded = false;

public:
    void load_data(const std::array<std::array<Word, N>, N>& A,
                   const std::array<std::array<Word, N>, N>& B);

    void step();       // Ejecuta un ciclo
    void run();        // Ejecuta hasta terminar
    void print_result() const;
    void print_status() const;
    bool is_done() const;
};

#endif // CONTROLLER_H
