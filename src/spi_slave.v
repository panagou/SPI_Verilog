module spi_slave #(
    parameter integer DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire sclk,
    input  wire cs_n,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire mosi,
    output wire miso,
    output reg  [DATA_WIDTH-1:0] data_out,
    output reg  done
);

    reg [$clog2(DATA_WIDTH)-1:0] bit_cnt; 
    reg miso_q, first_send;
    reg sclk_d;
    wire sclk_rise, sclk_fall;
    reg [DATA_WIDTH-1:0] data_in_reg;

    assign sclk_rise = sclk & ~sclk_d; 
    assign sclk_fall = ~sclk & sclk_d;

    //High impedance when not selected
    assign miso = (cs_n == 1'b0) ? miso_q : 1'bz;

    always @(posedge clk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt      <= {$clog2(DATA_WIDTH){1'b0}};
            miso_q       <= 1'b0;
            first_send   <=1'b1;
            data_in_reg  <= {DATA_WIDTH{1'b0}};
            sclk_d       <= 1'b1;
            data_out     <= {DATA_WIDTH{1'b0}};
            done         <= 1'b0;
        end else begin
            sclk_d <= sclk;
            if (done) done <= 1'b0;
            if (sclk_rise) begin
                data_out <= {data_out[DATA_WIDTH-2:0], mosi};
                if (bit_cnt == {{($clog2(DATA_WIDTH)){1'b1}}}) begin
                    bit_cnt  <= {$clog2(DATA_WIDTH){1'b0}};
                    done     <= 1'b1;
                end else begin
                    bit_cnt  <= bit_cnt + 1;
                end
            end else if (sclk_fall) begin
                if (first_send) begin
                    data_in_reg <= {data_in[DATA_WIDTH-2:0], 1'b0};
                    first_send  <= 1'b0;
                    miso_q      <= data_in[DATA_WIDTH-1];
                end else begin
                    miso_q      <= data_in_reg[DATA_WIDTH-1]; // Update MISO on falling edge
                    data_in_reg <= {data_in_reg[DATA_WIDTH-2:0], 1'b0}; // Shift data_in_reg left
                end
            end
        end
    end

endmodule