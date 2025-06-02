#include "SystolicArray.h"
#include "PE.h"
#include <cassert>
#include "Controller.h"

void runController() {
    Controller ctrl;

    std::array<std::array<Word, N>, N> A = {{{1, 2, 3, 4},
                                             {5, 6, 7, 8},
                                             {9, 0, 1, 2},
                                             {3, 4, 5, 6}}};

    std::array<std::array<Word, N>, N> B = {{{7, 6, 5, 4},
                                             {3, 2, 1, 0},
                                             {1, 2, 3, 4},
                                             {5, 6, 7, 8}}};

    ctrl.load_data(A, B);
    std::cout << "Ejecución paso a paso:\n";

    while (!ctrl.is_done()) {
        ctrl.step();
        ctrl.print_status();
    }

    std::cout << "\nResultado final:\n";
    ctrl.print_result();

}


void run_unit_tests() {
    // Test ReLU
    PE pe;
    pe.a_in = 2; pe.b_in = 3;
    pe.tick(); // acc += 6

    pe.a_in = 1; pe.b_in = -4;
    pe.tick(); // acc += -4 => total = 2
    assert(pe.get_output() == 2);
    pe.apply_activation();
    assert(pe.get_output() == 2);

    pe.a_in = -3; pe.b_in = 1;
    pe.tick(); // acc += -3 => total = -1
    pe.apply_activation();
    assert(pe.get_output() == 0); // ReLU
    pe.reset();
    assert(pe.get_output() == 0);


    // Test SystolicArray con datos generales (no usar identidad todavía)
    SystolicArray array;
    std::array<std::array<Word, N>, N> A = {{{1, 2, 3, 4},
                                             {5, 6, 7, 8},
                                             {9, 0, 1, 2},
                                             {3, 4, 5, 6}}};

    std::array<std::array<Word, N>, N> B = {{{7, 6, 5, 4},
                                             {3, 2, 1, 0},
                                             {1, 2, 3, 4},
                                             {5, 6, 7, 8}}};

    array.run_cycles(A, B);
(A, B);
    const auto& result = array.get_result();

    // Solo validamos que todos los valores son >= 0 por ReLU
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            assert(result[i][j] >= 0);

    std::cout << "Todas las pruebas unitarias PASARON correctamente.\n";
}


int main() {
    runController();
    return 0;
}
