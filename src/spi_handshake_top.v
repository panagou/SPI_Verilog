`timescale 1ns / 1ps

`include "./spi_module.v"

module spi_handshake_top #(
    parameter integer DATA_WIDTH = 8
) (
    input  wire                  clk, rst_n,
    input  wire [DATA_WIDTH-1:0] tx_data_master, tx_data_slave,
    input  wire                   start_master,
    output wire [DATA_WIDTH-1:0] rx_data_master, rx_data_slave,
    output wire                   valid_master, valid_slave
);

wire miso, mosi;

spi_module #(
        .SPI_MASTER(1'b1),
        .DATA_WIDTH(DATA_WIDTH)
) spi_master_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_sclk(1'b0),
        .start(start_master),
        .i_cs_n(1'b0),
        .data_in(tx_data_master),
        .i_mosi(mosi),
        .i_miso(miso), 
        .o_mosi(mosi),
        .o_cs_n(cs_n),
        .o_sclk(sclk),
        .data_out(rx_data_master),
        .valid(valid_master)
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
        .data_in(tx_data_slave), 
        .i_mosi(mosi), 
        .i_miso(1'b0), 
        .o_miso(miso), 
        .data_out(rx_data_slave),
        .valid(valid_slave)
    );
    
endmodule