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

    systolic.tick_cycle(matrixA, matrixB, current_cycle);
    current_cycle++;

    if (current_cycle >= total_cycles) {
        for (int i = 0; i < N; ++i) {
            for (int j = 0; j < N; ++j){
                systolic.pes[i][j].apply_activation();
                systolic.result[i][j] = systolic.pes[i][j].get_output();

            }
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
