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
    registers.fill(0);
    registers[REG_STATUS] = 0;
}

void Controller::step() {
    if (!memory) return;

    memory->tick(); // avanzar memoria un ciclo

    switch (phase) {
        case ExecPhase::IDLE:
            mem_row = mem_col = 0;
            phase = ExecPhase::LOADING_A;
            break;

        case ExecPhase::LOADING_A:
            if (!memory->is_busy()) {
                int addr = registers[REG_ADDR_A] + mem_row * N + mem_col;
                memory->request_read(addr);
                phase = ExecPhase::LOADING_B;
            }
            break;

        case ExecPhase::LOADING_B:
            if (memory->has_read_result()) {
                matrixA[mem_row][mem_col] = memory->pop_read_result();

                int addrB = registers[REG_ADDR_B] + mem_row * N + mem_col;
                memory->request_read(addrB);
                phase = ExecPhase::LOADING_AWAIT_B;
            }
            break;

        case ExecPhase::LOADING_AWAIT_B:
            if (memory->has_read_result()) {
                matrixB[mem_row][mem_col] = memory->pop_read_result();
                mem_col++;

                if (mem_col == N) {
                    mem_col = 0;
                    mem_row++;
                }

                if (mem_row == N) {
                    systolic.reset();
                    current_cycle = 0;
                    registers[REG_STATUS] = 1; // ejecutando
                    phase = ExecPhase::EXECUTING;
                } else {
                    phase = ExecPhase::LOADING_A;
                }
            }
            break;

        case ExecPhase::EXECUTING:
            if (current_cycle < total_cycles) {
                systolic.tick_cycle(matrixA, matrixB, current_cycle);
                current_cycle++;
                registers[REG_MUL_COUNT] += N * N;
            } else {
                for (int i = 0; i < N; ++i)
                    for (int j = 0; j < N; ++j)
                        systolic.pes[i][j].apply_activation();

                mem_row = mem_col = 0;
                phase = ExecPhase::STORING_C;
            }
            break;

        case ExecPhase::STORING_C:
            // Primero verificar si todavía hay celdas por escribir
                if (mem_row < N && mem_col < N) {
                    if (!memory->is_busy()) {
                        int addrC = registers[REG_ADDR_C] + mem_row * N + mem_col;
                        Word value = systolic.pes[mem_row][mem_col].get_output();

                        memory->request_write(addrC, value);

                        mem_col++;
                        if (mem_col == N) {
                            mem_col = 0;
                            mem_row++;
                        }
                    }
                } else {
                    // Ya solicitamos todos los writes — ahora esperar que terminen
                    if (!memory->is_busy()) {
                        phase = ExecPhase::DONE;
                        registers[REG_STATUS] = 2;
                        done = true;
                    }
                }
        break;


        case ExecPhase::DONE:
            // finalizado
            break;
    }

    registers[REG_CYCLE_COUNT]++;
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

void Controller::write_register(Register reg, Word value) {
    if (reg == REG_CONTROL) {
        // Bit 0 = start, Bit 1 = step
        if (value & 0x1) run();
        else if (value & 0x2) step();
    }
    registers[reg] = value;
}

Word Controller::read_register(Register reg) const {
    return registers[reg];
}

void Controller::attach_memory(Memory* mem) {
    memory = mem;
}



