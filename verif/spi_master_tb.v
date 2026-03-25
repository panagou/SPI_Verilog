`include "../src/spi_module.v"

module spi_master_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;


    reg clk;
    reg rst_n;
    reg [DATA_WIDTH-1:0] tx_data;
    reg start;
    wire mosi, miso;
    wire sclk, cs_n;
    wire [DATA_WIDTH-1:0] rx_data, rx_data_slave;

    spi_module #(
        .SPI_MASTER(1'b1),
        .DATA_WIDTH(DATA_WIDTH)
    ) spi_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_sclk(1'b0),
        .start(start),
        .i_cs_n(1'b0),
        .data_in(tx_data),
        .i_mosi(1'b0),
        .i_miso(miso), 
        .o_mosi(mosi),
        .o_cs_n(cs_n),
        .o_sclk(sclk),
        .data_out(rx_data)
    );

    spi_module #(
        .SPI_MASTER(1'b0),
        .DATA_WIDTH(DATA_WIDTH)
    ) spi_slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_sclk(sclk),
        .start(1'b0),
        .i_cs_n(cs_n),
        .data_in(tx_data), 
        .i_mosi(mosi), 
        .i_miso(1'b0), 
        .o_miso(miso), 
        .data_out(rx_data_slave)
    );


    initial begin
        clk   = 0;
        rst_n = 1;
        start = 0;
    end

    always #(CLK_PERIOD/2) clk = ~clk;

    task send_data(input [DATA_WIDTH-1:0] data);
        begin
            tx_data = data;
            start   = 1;
            #(CLK_PERIOD);
            start   = 0;
            $display("Data sent at time %0t: %0h", $time, data);
        end
    endtask


    initial begin

        #(CLK_PERIOD*1);
        rst_n = 0;
        #(CLK_PERIOD*1);
        rst_n = 1;

        send_data(8'hA5);
        #(CLK_PERIOD*18);
        send_data(8'h3C);
        #(CLK_PERIOD*18);
        send_data(8'hFF);
        #(CLK_PERIOD*18);
        send_data(8'h00);

        #(CLK_PERIOD*25);


        $finish;
    end

    //Monitor the data received by the slave
    initial begin
        $monitor("Data received at time %0t: %0h", $time, rx_data_slave);
    end

    endmodule