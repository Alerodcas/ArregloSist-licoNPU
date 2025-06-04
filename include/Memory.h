#ifndef MEMORY_H
#define MEMORY_H

#include <vector>
#include <cstdint>
#include <stdexcept>
#include <queue>

using Word = int16_t;


struct MemRequest {
    enum Type { READ, WRITE } type;
    int addr;
    Word value;  // solo usado en WRITE
    int remaining_cycles;
};

class Memory {
private:
    std::vector<Word> data;
    std::queue<MemRequest> pending;
    std::queue<Word> read_results;
    int latency; // latencia simulada en ciclos

public:
    Memory(size_t size, int latency_cycles = 2);

    void request_read(int addr);
    void request_write(int addr, Word value);
    void tick();  // avanza un ciclo en la memoria
    bool has_read_result() const;
    Word pop_read_result(); // bloquea si no hay resultado

    bool is_busy() const;

    void dump(int start = 0, int count = 16) const; //Para debug
};

#endif // MEMORY_H
