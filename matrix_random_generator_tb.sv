module matrix_random_generator_tb;

    logic clk = 0, rstN = 0, start;
    logic signed [31:0] matrix [4][4];
    logic done;

    matrix_random_generator #(.N(4)) uut (
        .clk(clk),
        .rstN(rstN),
        .start(start),
        .matrix(matrix),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        rstN = 0;
        start = 0;
        #10 rstN = 1;
        #10 start = 1;

        wait (done);

        $display("Matriz aleatoria (LFSR en [-5,5]):");
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                $write("%0d\t", matrix[i][j]);
            end
            $display("");
        end
    end

endmodule
