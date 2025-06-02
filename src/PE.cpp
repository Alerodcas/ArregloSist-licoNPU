#include "PE.h"

Word relu(Word value) {
    return (value > 0) ? value : 0;
}

void PE::tick() {
    a_reg = a_in;
    b_reg = b_in;
    acc += a_reg * b_reg;
}

void PE::apply_activation() {
    acc = relu(acc);
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
