`timescale 1ns / 1ps
`default_nettype none

`include "./spi_module.v"

module spi_handshake_top #(
    parameter integer DATA_WIDTH = 8,
    parameter integer FIFO_DEPTH = 8
) (
    input  wire                  clk, rst_n,
    input  wire [DATA_WIDTH-1:0] tx_data_master, tx_data_slave,
    input  wire                  write_en_master, write_en_slave,
    input  wire                  i_read_master,
    output wire [DATA_WIDTH-1:0] rx_data_master, rx_data_slave,
    output wire                  done_master, done_slave
);

    wire miso, mosi, sclk, cs_n;

    spi_module #(
        .SPI_MASTER(1'b1),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) spi_master_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_sclk(1'b0),
        .write_en(write_en_master),
        .i_cs_n(1'b0),
        .data_in(tx_data_master),
        .i_mosi(1'b0),
        .i_miso(miso), 
        .o_mosi(mosi),
        .i_read(i_read_master),
        .o_cs_n(cs_n),
        .o_sclk(sclk),
        .data_out(rx_data_master),
        .done(done_master)
    );

    spi_module #(
        .SPI_MASTER(1'b0),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) spi_slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_sclk(sclk),
        .write_en(write_en_slave),
        .i_cs_n(cs_n),
        .data_in(tx_data_slave), 
        .i_mosi(mosi), 
        .i_miso(1'b0), 
        .o_miso(miso), 
        .data_out(rx_data_slave),
        .done(done_slave)
    );
    
endmodule