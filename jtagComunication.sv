module jtagComunication (
    input  wire CLOCK_50,
    input  wire RESET_N
);
    // Señales JTAG UART
    wire        uart_chipselect;
    wire        uart_address;
    wire        uart_read_n;
    wire [31:0] uart_readdata;
    wire        uart_write_n;
    wire [31:0] uart_writedata;
    wire        uart_waitrequest;
    
    // Instancia del JTAG UART directamente
    jtagUart jtaguart(
        .clk_clk                  (CLOCK_50),
        .reset_reset_n            (RESET_N),
        .jtagslave_chipselect   (uart_chipselect),
        .jtagslave_address      (uart_address),
        .jtagslave_read_n       (uart_read_n),
        .jtagslave_readdata     (uart_readdata),
        .jtagslave_write_n      (uart_write_n),
        .jtagslave_writedata    (uart_writedata),
        .jtagslave_waitrequest  (uart_waitrequest)
    );
    
    // UART Writer confiable con buffer de mensaje
    uartControl uartControl (
        .clk         (CLOCK_50),
        .reset_n     (RESET_N),
        .chipselect  (uart_chipselect),
        .address     (uart_address),
        .read_n      (uart_read_n),
        .write_n     (uart_write_n),
        .writedata   (uart_writedata),
        .waitrequest (uart_waitrequest)
    );
endmodule