#include "Controller.h"
#include <array>

void Controller::load_data(const std::array<std::array<Word, N>, N>& A,
                           const std::array<std::array<Word, N>, N>& B) {
    matrixA = A;
    matrixB = B;
    systolic.reset();
    current_cycle = 0;
    done = false;
    loaded = true;
}

void Controller::step() {
    if (!loaded || done) return;

    // Simular un ciclo individual
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            // Entradas por izquierda (A)
            if (j == 0 && current_cycle - i >= 0 && current_cycle - i < N)
                systolic.pes[i][j].a_in = matrixA[i][current_cycle - i];
            else if (j > 0)
                systolic.pes[i][j].a_in = systolic.pes[i][j - 1].get_a_out();
            else
                systolic.pes[i][j].a_in = 0;

            // Entradas por arriba (B)
            if (i == 0 && current_cycle - j >= 0 && current_cycle - j < N)
                systolic.pes[i][j].b_in = matrixB[current_cycle - j][j];
            else if (i > 0)
                systolic.pes[i][j].b_in = systolic.pes[i - 1][j].get_b_out();
            else
                systolic.pes[i][j].b_in = 0;
        }
    }

    for (auto& row : systolic.pes)
        for (auto& pe : row)
            pe.tick();

    current_cycle++;
    if (current_cycle >= total_cycles) {
        for (int i = 0; i < N; ++i)
            for (int j = 0; j < N; ++j) {
                systolic.pes[i][j].apply_activation();
            }
        done = true;
    }
}

void Controller::run() {
    while (!done)
        step();
}

void Controller::print_status() const {
    std::cout << "Ciclo actual: " << current_cycle
              << " / " << total_cycles << "\n";
    std::cout << "Estado: " << (done ? "FINALIZADO" : "EN PROCESO") << "\n";
}

void Controller::print_result() const {
    if (!done) {
        std::cout << "Advertencia: Resultado parcial.\n";
    }
    systolic.print_result();
}

bool Controller::is_done() const {
    return done;
}
