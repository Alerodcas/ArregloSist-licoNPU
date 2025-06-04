#include "PE.h"
#include <cmath>

Word relu(Word x) {
    return (x > 0) ? x : 0;
}

Word linear(Word x) {
    return x;
}

Word tanh_approx(Word x) {
    // Versión rápida para enteros
    double fx = static_cast<double>(x) / 128.0;
    double tx = std::tanh(fx);
    return static_cast<Word>(tx * 128);
}

void PE::apply_activation(int mode) {
    switch (mode) {
        case ACT_LINEAR: acc = linear(acc); break;
        case ACT_TANH:   acc = tanh_approx(acc); break;
        case ACT_RELU:
            default:         acc = relu(acc); break;
    }
}


void PE::tick() {
    a_reg = a_in;
    b_reg = b_in;
    acc += a_reg * b_reg;
}

void PE::reset() {
    a_reg = b_reg = acc = 0;
    a_in = b_in = 0;
}

Word PE::get_output() const {
    return acc;
}


Word PE::get_a_out() const {
    return a_reg;
}

Word PE::get_b_out() const {
    return b_reg;
}
