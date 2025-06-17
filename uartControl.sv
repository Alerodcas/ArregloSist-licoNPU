//=========================================================
// UART_WRITER con buffer que envía "Hola\n" cíclicamente
//=========================================================
module uartControl (
    input  wire        clk,
    input  wire        reset_n,
    output reg         chipselect,
    output reg         address,
    output reg         read_n,
    output reg         write_n,
    output reg [31:0]  writedata,
    input  wire        waitrequest
);
    typedef enum logic [1:0] {IDLE, SEND, WAIT_DONE} state_t;
    state_t state;
    
    reg [23:0] delay_counter;
    reg [4:0] char_index;  // Cambiado de 3 bits a 5 bits para manejar 17 caracteres
    reg [7:0] message [0:16]; // Cambiado de 5 elementos a 17 elementos
    
    initial begin
        // "Cien y nos vamos" + salto de línea
        message[0]  = 8'h43; // 'C'
        message[1]  = 8'h69; // 'i'
        message[2]  = 8'h65; // 'e'
        message[3]  = 8'h6E; // 'n'
        message[4]  = 8'h20; // ' ' (espacio)
        message[5]  = 8'h79; // 'y'
        message[6]  = 8'h20; // ' ' (espacio)
        message[7]  = 8'h6E; // 'n'
        message[8]  = 8'h6F; // 'o'
        message[9]  = 8'h73; // 's'
        message[10] = 8'h20; // ' ' (espacio)
        message[11] = 8'h76; // 'v'
        message[12] = 8'h61; // 'a'
        message[13] = 8'h6D; // 'm'
        message[14] = 8'h6F; // 'o'
        message[15] = 8'h73; // 's'
        message[16] = 8'h0A; // '\n' (salto de línea)
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state        <= IDLE;
            delay_counter<= 0;
            chipselect   <= 0;
            address      <= 0;
            read_n       <= 1;
            write_n      <= 1;
            writedata    <= 32'd0;
            char_index   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    chipselect <= 0;
                    write_n    <= 1;
                    if (delay_counter < 24'd5_000_000) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        delay_counter <= 0;
                        writedata  <= {24'd0, message[char_index]};
                        chipselect <= 1;
                        write_n    <= 0;
                        address    <= 0; // txdata
                        read_n     <= 1;
                        state      <= SEND;
                    end
                end
                
                SEND: begin
                    if (!waitrequest) begin
                        write_n <= 1;
                        chipselect <= 0;
                        state <= WAIT_DONE;
                    end
                end
                
                WAIT_DONE: begin
                    char_index <= (char_index == 16) ? 0 : char_index + 1; // Cambiado de 4 a 16
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule