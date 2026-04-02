module spi_fifo #(
    parameter integer FIFO_DEPTH = 8,
    parameter integer FIFO_WIDTH = 8
)(
    input wire clk, rst_n,
    input wire [FIFO_WIDTH-1:0] data_in,
    input wire write_en, read_en,
    output reg [FIFO_WIDTH-1:0] data_out,
    output wire full, empty
);

    reg [(FIFO_WIDTH-1):0] fifo [(FIFO_DEPTH-1):0];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr, rd_ptr;
    wire wrap_around;

    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr   <= 0;
        end else begin
            if (write_en && !full) begin
                fifo[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= data_in;
                wr_ptr       <= wr_ptr + 1;
            end
        end
    end 

    always @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr   <= 0;
            data_out <= 0;
        end else begin
            if (read_en && !empty) begin
                data_out <= fifo[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
                rd_ptr   <= rd_ptr + 1;
            end
        end
    end

    assign wrap_around = wr_ptr[$clog2(FIFO_DEPTH)] ^ rd_ptr[$clog2(FIFO_DEPTH)];

    assign full = wrap_around & (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]);
    assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
    
endmodule