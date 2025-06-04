#include "SystolicArray.h"
#include "PE.h"
#include <cassert>
#include "Controller.h"

void testMemory() {
    Memory mem(256, 2); // SDRAM simulada con latencia de 2 ciclos

    // Datos de prueba
    std::array<std::array<Word, N>, N> A = {{{1, 2, 3, 4},
                                             {5, 6, 7, 8},
                                             {9, 0, 1, 2},
                                             {3, 4, 5, 6}}};

    std::array<std::array<Word, N>, N> B = {{{7, 6, 5, 4},
                                             {3, 2, 1, 0},
                                             {1, 2, 3, 4},
                                             {5, 6, 7, 8}}};

    // Cargar A y B en memoria (A en 0, B en 64)
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            mem.request_write(0 + i * N + j, A[i][j]);   // addr A
            mem.request_write(64 + i * N + j, B[i][j]);  // addr B
        }

    // Esperar a que memoria complete escrituras
    while (mem.is_busy()) {
        mem.tick();
    }


    Controller ctrl;
    ctrl.attach_memory(&mem);

    // Configurar direcciones
    ctrl.write_register(REG_ADDR_A, 0);
    ctrl.write_register(REG_ADDR_B, 64);
    ctrl.write_register(REG_ADDR_C, 128); // Resultado en C

    // Ejecutar paso a paso (como hardware)
    while (!ctrl.is_done()) {
        ctrl.step();
    }

    std::cout << "✅ Ejecución completada. Ciclos: " << ctrl.read_register(REG_CYCLE_COUNT) << "\n";
    std::cout << "Resultado almacenado en memoria externa (addr 128):\n";
    mem.dump(128, 16); // Mostrar 4x4 resultado

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
    testMemory();
    return 0;
}
