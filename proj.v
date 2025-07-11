module fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8
)(
    input clk,
    input rst_n,
    input cs,
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

    localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

    reg [FIFO_DEPTH_LOG:0] write_pointer;
    reg [FIFO_DEPTH_LOG:0] read_pointer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_pointer <= 0;
        else if (cs && wr_en && !full) begin
            fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
            write_pointer <= write_pointer + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_pointer <= 0;
        else if (cs && rd_en && !empty) begin
            data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
            read_pointer <= read_pointer + 1'b1;
        end
    end

    assign empty = (read_pointer == write_pointer);
    assign full = (read_pointer == {~write_pointer[FIFO_DEPTH_LOG], write_pointer[FIFO_DEPTH_LOG-1:0]});

endmodule


module spi_to_i2c_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] spi_data,
    input spi_start,
    output reg i2c_scl,
    output reg i2c_sda
);

    reg fifo_wr_en;
    reg fifo_rd_en;
    wire fifo_empty;
    wire fifo_full;
    wire [DATA_WIDTH-1:0] fifo_data_out;
    reg [1:0] state, next_state;
    reg [3:0] bit_counter;
    reg [DATA_WIDTH-1:0] fifo_data_in;

    localparam IDLE = 2'b00,
               WRITE_FIFO = 2'b01,
               READ_FIFO = 2'b10,
               I2C_SEND = 2'b11;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .cs(1'b1),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .data_in(fifo_data_in),
        .data_out(fifo_data_out),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        fifo_wr_en = 0;
        fifo_rd_en = 0;
        i2c_scl = 1;
        i2c_sda = 1'bz;

        case (state)
            IDLE: begin
                if (spi_start && !fifo_full) begin
                    fifo_wr_en = 1;
                    next_state = WRITE_FIFO;
                end
            end

            WRITE_FIFO: begin
                fifo_wr_en = 0;
                next_state = READ_FIFO;
            end

            READ_FIFO: begin
                if (!fifo_empty) begin
                    fifo_rd_en = 1;
                    next_state = I2C_SEND;
                end
            end

            I2C_SEND: begin
                i2c_scl = ~clk;
                i2c_sda = fifo_data_out[7 - bit_counter];
                if (bit_counter == 7)
                    next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bit_counter <= 0;
        else if (state == I2C_SEND)
            bit_counter <= bit_counter + 1'b1;
        else
            bit_counter <= 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fifo_data_in <= 0;
        else if (spi_start && state == IDLE)
            fifo_data_in <= spi_data;
    end

endmodule

