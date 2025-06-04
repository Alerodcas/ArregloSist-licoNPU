#include "Memory.h"
#include <iostream>
#include <iomanip>

Memory::Memory(size_t size, int latency_cycles)
    : data(size, 0), latency(latency_cycles) {}

void Memory::request_read(int addr) {
    if (addr < 0 || addr >= static_cast<int>(data.size()))
        throw std::out_of_range("Read address out of range");

    pending.push({MemRequest::READ, addr, 0, latency});
}

void Memory::request_write(int addr, Word value) {
    if (addr < 0 || addr >= static_cast<int>(data.size()))
        throw std::out_of_range("Write address out of range");

    pending.push({MemRequest::WRITE, addr, value, latency});
}

void Memory::tick() {
    if (!pending.empty()) {
        MemRequest& req = pending.front();
        req.remaining_cycles--;

        if (req.remaining_cycles <= 0) {
            if (req.type == MemRequest::READ) {
                read_results.push(data[req.addr]);
            } else if (req.type == MemRequest::WRITE) {
                data[req.addr] = req.value;
            }
            pending.pop();
        }
    }
}

bool Memory::has_read_result() const {
    return !read_results.empty();
}

Word Memory::pop_read_result() {
    if (read_results.empty())
        throw std::runtime_error("No read result available");

    Word val = read_results.front();
    read_results.pop();
    return val;
}

bool Memory::is_busy() const {
    return !pending.empty();
}

void Memory::dump(int start, int count) const {
    for (int i = 0; i < count; ++i) {
        int addr = start + i;
        if (addr >= static_cast<int>(data.size())) break;
        std::cout << "[" << std::setw(3) << addr << "] = " << std::setw(6) << data[addr] << "\n";
    }
}

//Solo para pruebas, no toma en cuenta latencia
Word Memory::read(int addr) const {
    if (addr < 0 || addr >= static_cast<int>(data.size()))
        throw std::out_of_range("Read address out of range");
    return data[addr];
}
