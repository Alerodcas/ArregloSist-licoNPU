// Controlador para arreglo sistólico en SystemVerilog
// FSM que carga matrices desde memoria, ejecuta, y almacena resultados

module systolicController #(
    parameter N = 4,
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 16,
    parameter LATENCY = 3
)(
    input  logic clk,
    input  logic rst,

    // Control desde CPU o FSM externa
    input  logic start,
    input  logic [1:0] activation_mode,
    input  logic [ADDR_WIDTH-1:0] base_addr_A,
    input  logic [ADDR_WIDTH-1:0] base_addr_B,
    input  logic [ADDR_WIDTH-1:0] base_addr_C,

    // Señales a memoria (solo un puerto)
    output logic mem_req_valid,
    output logic mem_req_write,
    output logic [ADDR_WIDTH-1:0] mem_req_addr,
    output logic signed [DATA_WIDTH-1:0] mem_req_data,
    input  logic mem_busy,
    input  logic mem_read_valid,
    input  logic signed [DATA_WIDTH-1:0] mem_read_data,

    // Señal de terminado
    output logic done
);

    typedef enum logic [2:0] {
        IDLE, LOAD_A, LOAD_B, LOAD_WAIT_B,
        EXECUTE, STORE_C, WAIT_DONE
    } state_t;

    state_t state, next_state;

    logic [ADDR_WIDTH-1:0] addr_A, addr_B, addr_C;
    logic [$clog2(N):0] row, col;
    logic [$clog2(N*N*2):0] cycle_cnt; // suficiente para ciclos de ejecución

    // FSM de control
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            row <= 0;
            col <= 0;
            cycle_cnt <= 0;
            done <= 0;
        end else begin
            state <= next_state;

            // Actualización de contadores
            case (state)
                LOAD_WAIT_B: if (mem_read_valid) begin
                    if (col == N-1) begin
                        col <= 0;
                        row <= row + 1;
                    end else begin
                        col <= col + 1;
                    end
                end
                EXECUTE: cycle_cnt <= cycle_cnt + 1;
                STORE_C: if (!mem_busy) begin
                    if (col == N-1) begin
                        col <= 0;
                        row <= row + 1;
                    end else begin
                        col <= col + 1;
                    end
                end
            endcase

            if (state == WAIT_DONE && !mem_busy)
                done <= 1;
            else if (state == IDLE)
                done <= 0;
        end
    end

    always_comb begin
        next_state = state;
        mem_req_valid = 0;
        mem_req_write = 0;
        mem_req_addr  = 0;
        mem_req_data  = 0;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = LOAD_A;
                end
            end

            LOAD_A: begin
                if (!mem_busy) begin
                    mem_req_valid = 1;
                    mem_req_write = 0;
                    mem_req_addr = base_addr_A + row*N + col;
                    next_state = LOAD_B;
                end
            end

            LOAD_B: begin
                if (mem_read_valid) begin
                    mem_req_valid = 1;
                    mem_req_write = 0;
                    mem_req_addr = base_addr_B + row*N + col;
                    next_state = LOAD_WAIT_B;
                end
            end

            LOAD_WAIT_B: begin
                if (mem_read_valid) begin
                    if (row == N-1 && col == N-1)
                        next_state = EXECUTE;
                    else
                        next_state = LOAD_A;
                end
            end

            EXECUTE: begin
                if (cycle_cnt == (2*N - 1)) begin
                    next_state = STORE_C;
                end
            end

            STORE_C: begin
                if (!mem_busy) begin
                    mem_req_valid = 1;
                    mem_req_write = 1;
                    mem_req_addr = base_addr_C + row*N + col;
                    mem_req_data = 16'sd0; // En integración: valor del PE

                    if (row == N-1 && col == N-1)
                        next_state = WAIT_DONE;
                end
            end

            WAIT_DONE: begin
                if (!mem_busy)
                    next_state = IDLE;
            end
        endcase
    end

endmodule
