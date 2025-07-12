//TESTBENCH CODE

module tb_spi_to_i2c_fifo;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 8;

    reg clk;
    reg rst_n;
    reg [DATA_WIDTH-1:0] spi_data;
    reg spi_start;
    wire i2c_scl;
    wire i2c_sda;

    wire fifo_wr_en;
    wire fifo_rd_en;
    wire fifo_empty;
    wire fifo_full;
    wire [DATA_WIDTH-1:0] fifo_data_out;

    spi_to_i2c_fifo uut (
        .clk(clk),
        .rst_n(rst_n),
        .spi_data(spi_data),
        .spi_start(spi_start),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda)
    );

    assign fifo_wr_en = uut.fifo_wr_en;
    assign fifo_rd_en = uut.fifo_rd_en;
    assign fifo_empty = uut.fifo_empty;
    assign fifo_full = uut.fifo_full;
    assign fifo_data_out = uut.fifo_data_out;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, clk, rst_n, spi_data, spi_start, fifo_wr_en, fifo_rd_en, fifo_full, fifo_empty, fifo_data_out, i2c_scl, i2c_sda);

        rst_n = 0;
        spi_data = 8'b0;
        spi_start = 0;

        #10 rst_n = 1;
            
        #10 spi_data = 8'b10101010;
        spi_start = 1;
        #10 spi_start = 0;

        #200;

        #10 spi_data = 8'b11001100;
        spi_start = 1;
        #10 spi_start = 0;

        #200;

        spi_start = 1;
        #10 spi_start = 0;
        #120 $finish;
    end

    initial begin
        $monitor($time,
                 " clk=%b rst_n=%b spi_data=%b spi_start=%b fifo_wr_en=%b fifo_rd_en=%b fifo_empty=%b fifo_full=%b fifo_data_out=%b i2c_scl=%b i2c_sda=%b",
                 clk, rst_n, spi_data, spi_start, fifo_wr_en, fifo_rd_en, fifo_empty, fifo_full, fifo_data_out, i2c_scl, i2c_sda);
    end

endmodule