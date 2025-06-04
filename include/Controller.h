#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "SystolicArray.h"
#include <array>
#include "Memory.h"

enum class ExecPhase {
    IDLE,
    LOADING_A,
    LOADING_B,
    LOADING_AWAIT_B,
    EXECUTING,
    STORING_C,
    DONE
};


enum Register {
    REG_CONTROL = 0,
    REG_STATUS,
    REG_CYCLE_COUNT,
    REG_MUL_COUNT,
    REG_ADDR_A,      // Dirección base matriz A
    REG_ADDR_B,      // Dirección base matriz B
    REG_ADDR_C,      // Dirección base matriz resultado
    REG_ACTIVATION_MODE,
    NUM_REGISTERS
};



class Controller {
private:
    SystolicArray systolic;
    std::array<Word, NUM_REGISTERS> registers{};
    int current_cycle = 0;
    int total_cycles = 2 * N + N - 2;
    bool done = false;
    bool loaded = false;

    ExecPhase phase = ExecPhase::IDLE;
    int mem_row = 0, mem_col = 0; // índice para carga/almacenamiento progresivo

    std::array<std::array<Word, N>, N> matrixA{};
    std::array<std::array<Word, N>, N> matrixB{};

    Memory* memory = nullptr;  // Puntero a memoria externa

public:
    void attach_memory(Memory* mem);
    void load_matrices_from_memory();
    void store_result_to_memory();

    void step();
    void run();
    void load_data(const std::array<std::array<Word, N>, N>& A,
                   const std::array<std::array<Word, N>, N>& B);
    void print_result() const;
    void print_status() const;
    bool is_done() const;

    void write_register(Register reg, Word value);
    Word read_register(Register reg) const;
    SystolicArray get_systolic_array() const {
        return systolic;
    }

};

#endif // CONTROLLER_H
