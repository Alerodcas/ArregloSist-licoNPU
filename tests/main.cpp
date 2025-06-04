#include "Controller.h"
#include "Memory.h"
#include <random>
#include <iostream>
#include <limits>
#include <cassert>
#include <fstream>


void generate_random_matrix(std::array<std::array<Word, N>, N>& mat, int min = -5, int max = 5) {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(min, max);

    for (auto& row : mat)
        for (auto& val : row)
            val = dis(gen);
}

void print_matrix(const std::array<std::array<Word, N>, N>& mat) {
    for (const auto& row : mat) {
        for (Word val : row)
            std::cout << std::setw(6) << val << " ";
        std::cout << "\n";
    }
}

void wait_for_enter() {
    std::cout << "Presione Enter para continuar...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void display_menu() {
    std::cout << "==== MENU DE PRUEBAS ====" << std::endl;
    std::cout << "1. Matrices definidas (A y B)" << std::endl;
    std::cout << "2. Matrices aleatorias" << std::endl;
    std::cout << "3. Prueba automatica de matriz identidad" << std::endl;
    std::cout << "4. Prueba automatica de matriz cero" << std::endl;
    std::cout << "5. Prueba automatica de simetria A * B == B^T * A^T" << std::endl;
    std::cout << "Seleccione una opcion: ";
}


bool matrices_iguales(const std::array<std::array<Word, N>, N>& A,
                      const std::array<std::array<Word, N>, N>& B) {
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            if (A[i][j] != B[i][j]) return false;
    return true;
}

std::array<std::array<Word, N>, N> transpose(const std::array<std::array<Word, N>, N>& M) {
    std::array<std::array<Word, N>, N> T{};
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            T[j][i] = M[i][j];
    return T;
}

std::array<std::array<Word, N>, N> multiply_and_relu(const std::array<std::array<Word, N>, N>& A,
                                                     const std::array<std::array<Word, N>, N>& B) {
    std::array<std::array<Word, N>, N> C{};
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            Word acc = 0;
            for (int k = 0; k < N; ++k)
                acc += A[i][k] * B[k][j];
            C[i][j] = std::max<Word>(0, acc); // solo ReLU por simplicidad
        }
    return C;
}

bool run_automatic_test(const std::array<std::array<Word, N>, N>& A,
                        const std::array<std::array<Word, N>, N>& B,
                        const std::array<std::array<Word, N>, N>& expected,
                        const std::string& nombre_prueba) {
    constexpr int MEM_SIZE = 512;
    constexpr int ADDR_A = 0, ADDR_B = 64, ADDR_C = 128;
    Memory mem(MEM_SIZE, 2);
    Controller ctrl;
    ctrl.attach_memory(&mem);

    // Escribir A y B
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            mem.request_write(ADDR_A + i * N + j, A[i][j]);
            mem.request_write(ADDR_B + i * N + j, B[i][j]);
        }
    while (mem.is_busy()) mem.tick();

    ctrl.write_register(REG_ADDR_A, ADDR_A);
    ctrl.write_register(REG_ADDR_B, ADDR_B);
    ctrl.write_register(REG_ADDR_C, ADDR_C);
    ctrl.write_register(REG_ACTIVATION_MODE, ACT_RELU);

    while (!ctrl.is_done()) ctrl.step();

    std::array<std::array<Word, N>, N> resultado{};
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            resultado[i][j] = mem.read(ADDR_C + i * N + j);

    bool ok = matrices_iguales(resultado, expected);
    std::cout << "\n[" << nombre_prueba << "] Resultado: " << (ok ? "PASA" : "FALLA") << "\n";

        std::cout << "Esperado:\n";
        print_matrix(expected);
        std::cout << "Obtenido:\n";
        print_matrix(resultado);

    // Abrir archivo de log (modo append)
    std::ofstream log("resultados_pruebas.txt", std::ios::app);
    log << "\n==== PRUEBA: " << nombre_prueba << " ====\n";
    log << "Matriz A:\n";
    for (const auto& row : A) {
        for (Word val : row) log << val << "\t";
        log << "\n";
    }
    log << "Matriz B:\n";
    for (const auto& row : B) {
        for (Word val : row) log << val << "\t";
        log << "\n";
    }
    log << "Esperado (C):\n";
    for (const auto& row : expected) {
        for (Word val : row) log << val << "\t";
        log << "\n";
    }
    log << "Obtenido (C):\n";
    for (const auto& row : resultado) {
        for (Word val : row) log << val << "\t";
        log << "\n";
    }
    log << "Resultado: " << (ok ? "PASA" : "FALLA") << "\n";
    log << "---------------------------------------------\n";
    log.close();


    return ok;
}

void print_memory_activity(const Memory& mem) {
    std::cout << "Actividad de memoria este ciclo:\n";
    if (mem.is_busy()) {
        std::cout << "- Hay solicitudes pendientes en la cola de acceso.\n";
    } else {
        std::cout << "- No hay actividad en memoria.\n";
    }
    if (mem.has_read_result()) {
        std::cout << "- Un resultado de lectura está disponible.\n";
    }
}


void print_pe_states(const Controller& ctrl) {
    std::cout << "Estado de cada PE (a_in, b_in, acc):\n";
    const auto& systolic = ctrl.get_systolic_array();
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            const auto& pe = systolic.pes[i][j];
            std::cout << "PE[" << i << "," << j << "] a_in=" << pe.a_in
                      << " b_in=" << pe.b_in << " acc=" << pe.get_output() << "\t";
        }
        std::cout << "\n";
    }
}


int main() {
    constexpr int MEM_SIZE = 512;
    constexpr int ADDR_A = 0, ADDR_B = 64, ADDR_C = 128;

    display_menu();
    int opcion;
    std::cin >> opcion;
    std::cin.ignore();

    if (opcion >= 3) {
        if (opcion == 3) {
            std::array<std::array<Word, N>, N> I = {};
            for (int i = 0; i < N; ++i) I[i][i] = 1;
            run_automatic_test(I, I, I, "Matriz Identidad");
        } else if (opcion == 4) {
            std::array<std::array<Word, N>, N> Z = {};
            run_automatic_test(Z, Z, Z, "Matriz Cero");
        } else if (opcion == 5) {
            std::array<std::array<Word, N>, N> A, B;
            generate_random_matrix(A);
            generate_random_matrix(B);
            auto At = transpose(A);
            auto Bt = transpose(B);
            auto AB = multiply_and_relu(A, B);
            auto BtAt = multiply_and_relu(Bt, At);
            run_automatic_test(A, B, AB, "A * B");
            run_automatic_test(Bt, At, BtAt, "B^T * A^T");
        }
        return 0;
    }

    // Código existente modo interactivo...
    Memory mem(MEM_SIZE, 2); // latencia de 2 ciclos
    Controller ctrl;
    ctrl.attach_memory(&mem);

    std::array<std::array<Word, N>, N> A{}, B{};

    if (opcion == 1) {
        A = {{{1, 2, 3, 4},
              {5, 6, 7, 8},
              {9, 0, 1, 2},
              {3, 4, 5, 6}}};

        B = {{{7, 6, 5, 4},
              {3, 2, 1, 0},
              {1, 2, 3, 4},
              {5, 6, 7, 8}}};
    } else {
        generate_random_matrix(A);
        generate_random_matrix(B);
    }

    std::cout << "Matriz A:\n";
    print_matrix(A);
    std::cout << "Matriz B:\n";
    print_matrix(B);

    // Escribir matrices en memoria
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            mem.request_write(ADDR_A + i * N + j, A[i][j]);
            mem.request_write(ADDR_B + i * N + j, B[i][j]);
        }
    while (mem.is_busy()) mem.tick();

    // Configurar registros
    ctrl.write_register(REG_ADDR_A, ADDR_A);
    ctrl.write_register(REG_ADDR_B, ADDR_B);
    ctrl.write_register(REG_ADDR_C, ADDR_C);

    std::cout << "Seleccione modo de activaci\u00f3n:\n 0. ReLU\n 1. Lineal\n 2. Tanh\nModo: ";
    int act_mode;
    std::cin >> act_mode;
    std::cin.ignore();
    ctrl.write_register(REG_ACTIVATION_MODE, act_mode);

    std::cout << "Ejecutar en modo (1) step-by-step o (2) run?: ";
    int modo_ejec;
    std::cin >> modo_ejec;
    std::cin.ignore();

    if (modo_ejec == 2) {
        while (!ctrl.is_done()) ctrl.step();
    } else {
        while (!ctrl.is_done()) {
            ctrl.step();
            ctrl.print_status();
            print_pe_states(ctrl);
            print_memory_activity(mem);
            mem.dump(ADDR_C, 16);
            wait_for_enter();
        }
    }

    std::cout << "\nResultado final en memoria (matriz C):\n";
    mem.dump(ADDR_C, 16);
    std::cout << "\n\u2713 Ciclos totales: " << ctrl.read_register(REG_CYCLE_COUNT) << std::endl;
    std::cout << "\u2713 Multiplicaciones: " << ctrl.read_register(REG_MUL_COUNT) << std::endl;

    return 0;
}
