module ArregloSistolicoNPU #(parameter N = 4, MEM_SIZE = 512)(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [1:0] activation_mode,
    output logic done
);

    // Direcciones base
    localparam int ADDR_A = 0;
    localparam int ADDR_B = 64;
    localparam int ADDR_C = 128;

    // Señales internas
    logic mem_ready;
    logic [31:0] cycle_count, mul_count;

    // Instancia de la memoria
	Memory #(
		 .DATA_WIDTH(16),
		 .ADDR_WIDTH(9),
		 .LATENCY(3)
	) mem (
		 .clk(clk),
		 .rst(rst),
		 .req_valid(/* conectar señal */),
		 .req_write(/* conectar señal */),
		 .req_addr(/* conectar señal */),
		 .req_data(/* conectar señal */),
		 .resp_valid(/* conectar señal */),
		 .resp_data(/* conectar señal */)
	);


    // Instancia del controlador
    SystolicController #(
    .N(4),
    .ADDR_WIDTH(10),
    .DATA_WIDTH(16),
    .LATENCY(3)
) ctrl (
    .clk(clk),
    .rst(rst),
    .start(start),
    .activation_mode(activation_mode),
    .base_addr_A(base_addr_A),
    .base_addr_B(base_addr_B),
    .base_addr_C(base_addr_C),
    .mem_req_valid(mem_req_valid),
    .mem_req_write(mem_req_write),
    .mem_req_addr(mem_req_addr),
    .mem_req_data(mem_req_data),
    .mem_busy(mem_busy),
    .mem_read_valid(mem_read_valid),
    .mem_read_data(mem_read_data),
    .done(done)
);


endmodule
