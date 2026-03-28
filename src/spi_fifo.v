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
    reg [$clog2(FIFO_DEPTH):0] count;
    wire wrap_around; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count    <= 0;
            data_out <= 0;
        end else begin
            case({write_en, read_en})
                2'b10: if (!full) begin
                    fifo[wr_ptr] <= data_in;
                    wr_ptr       <= wr_ptr + 1;
                    count        <= count + 1;
                end
                2'b01: if (!empty) begin
                    data_out <= fifo[rd_ptr];
                    rd_ptr   <= rd_ptr + 1;
                    count    <= count - 1;
                end
                2'b11: if (!full) begin
                    fifo[wr_ptr] <= data_in;
                    data_out     <= fifo[rd_ptr];
                    wr_ptr       <= wr_ptr + 1;
                    rd_ptr       <= rd_ptr + 1;
                    count        <= count; 
                end
                default: begin
                    // No operation
                end
            endcase
        end
    end

    assign wrap_around = wr_ptr[$clog2(FIFO_DEPTH)] ^ rd_ptr[$clog2(FIFO_DEPTH)];

    assign full = wrap_around & (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]);
    assign empty = wr_ptr == rd_ptr;
    
endmodule