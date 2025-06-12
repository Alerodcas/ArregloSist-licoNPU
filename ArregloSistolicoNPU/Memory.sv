module Memory #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10,        // 2^10 = 1024 palabras
    parameter LATENCY     = 3
)(
    input  logic                      clk,
    input  logic                      rst,

    // Solicitud
    input  logic                      req_valid,
    input  logic                      req_write,   // 1 = write, 0 = read
    input  logic [ADDR_WIDTH-1:0]     req_addr,
    input  logic signed [DATA_WIDTH-1:0] req_data, // válido solo si write

    // Respuesta (solo para lectura)
    output logic                      resp_valid,
    output logic signed [DATA_WIDTH-1:0] resp_data
);

    // Memoria interna
    logic signed [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Registro de solicitud
    typedef struct packed {
        logic write;
        logic [ADDR_WIDTH-1:0] addr;
        logic signed [DATA_WIDTH-1:0] data;
        int unsigned cycles_left;
    } request_t;

    request_t current_req;
    logic busy;

    // Inicialización
    initial begin
        for (int i = 0; i < (1<<ADDR_WIDTH); i++) begin
            mem[i] = 0;
        end
    end

    // Estado de respuesta
    assign resp_valid = (!busy && current_req.write == 0 && current_req.cycles_left == 0);
    assign resp_data  = mem[current_req.addr];

    // Ciclo principal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 0;
            current_req <= '{default:0};
        end else begin
            if (!busy && req_valid) begin
                // Capturar nueva solicitud
                current_req.write       <= req_write;
                current_req.addr        <= req_addr;
                current_req.data        <= req_data;
                current_req.cycles_left <= LATENCY;
                busy <= 1;
            end else if (busy) begin
                if (current_req.cycles_left > 0)
                    current_req.cycles_left <= current_req.cycles_left - 1;

                if (current_req.cycles_left == 1) begin
                    if (current_req.write) begin
                        mem[current_req.addr] <= current_req.data;
                        busy <= 0;  // Escribimos y terminamos
                    end else begin
                        busy <= 0;  // Lectura estará disponible la siguiente vez
                    end
                end
            end
        end
    end

endmodule
