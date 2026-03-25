`timescale 1ns / 1ps

`include "spi_master.v"
`include "spi_slave.v"

module spi_module #(
    parameter         SPI_MASTER =1'b0,
    parameter integer DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire rst_n,
    input  wire i_sclk,
    input  wire start,
    input  wire i_cs_n,
    input  wire i_mosi,
    input  wire i_miso,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire o_mosi,
    output wire o_miso,
    output wire  o_cs_n,
    output wire o_sclk,
    output wire valid,
    output wire  [DATA_WIDTH-1:0] data_out
);

    generate 
        if(SPI_MASTER) begin : gen_spi_master
            spi_master #(
                .DATA_WIDTH(DATA_WIDTH)
            ) master_inst (
                .clk(clk),
                .rst_n(rst_n),
                .start(start),
                .data_in(data_in),
                .miso(i_miso),
                .mosi(o_mosi),
                .cs_n(o_cs_n),
                .sclk(o_sclk),
                .data_out(data_out),
                .valid(valid)
            ); 
        end else begin : gen_spi_slave
            spi_slave #(
                .DATA_WIDTH(DATA_WIDTH)
            ) slave_inst (
                .clk(clk),
                .sclk(i_sclk),
                .cs_n(i_cs_n),
                .mosi(i_mosi),
                .miso(o_miso),
                .data_in(data_in),
                .data_out(data_out),
                .valid(valid)
            ); 
        end
    endgenerate

endmodule