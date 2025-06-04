#include "SystolicArray.h"

void SystolicArray::reset() {
    for (auto& row : pes)
        for (auto& pe : row)
            pe.reset();
}

const std::array<std::array<Word, N>, N>& SystolicArray::get_result() const {
    return result;
}

void SystolicArray::print_result() const {
    for (const auto& row : get_result()) {
        for (Word val : row)
            std::cout << std::setw(6) << val << " ";
        std::cout << "\n";
    }
}

void SystolicArray::tick_cycle(const std::array<std::array<Word, N>, N>& A,
                               const std::array<std::array<Word, N>, N>& B,
                               int current_cycle) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            // Entradas por izquierda (A)
            if (j == 0 && current_cycle - i >= 0 && current_cycle - i < N)
                pes[i][j].a_in = A[i][current_cycle - i];
            else if (j > 0)
                pes[i][j].a_in = pes[i][j - 1].get_a_out();
            else
                pes[i][j].a_in = 0;

            // Entradas por arriba (B)
            if (i == 0 && current_cycle - j >= 0 && current_cycle - j < N)
                pes[i][j].b_in = B[current_cycle - j][j];
            else if (i > 0)
                pes[i][j].b_in = pes[i - 1][j].get_b_out();
            else
                pes[i][j].b_in = 0;
        }
    }

    for (auto& row : pes)
        for (auto& pe : row)
            pe.tick();
}

