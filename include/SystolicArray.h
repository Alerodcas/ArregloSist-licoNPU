#ifndef SYSTOLIC_ARRAY_H
#define SYSTOLIC_ARRAY_H

#include "PE.h"
#include <array>
#include <iostream>
#include <iomanip>

constexpr int N = 4;

class SystolicArray {

public:
    std::array<std::array<Word, N>, N> result{};

    std::array<std::array<PE, N>, N> pes;
    void reset();
    void run_cycles(const std::array<std::array<Word, N>, N>& A,
                    const std::array<std::array<Word, N>, N>& B);
    const std::array<std::array<Word, N>, N>& get_result() const;
    void print_result() const;
    void tick_cycle(const std::array<std::array<Word, N>, N>& A,
                const std::array<std::array<Word, N>, N>& B,
                int current_cycle);

};

#endif // SYSTOLIC_ARRAY_H
