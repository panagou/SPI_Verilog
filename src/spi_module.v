`timescale 1ns / 1ps

`include "spi_master.v"
`include "spi_slave.v"
`include "spi_fifo.v"

module spi_module #(
    parameter integer SPI_MASTER =1'b0,
    parameter integer DATA_WIDTH = 8,
    parameter integer FIFO_DEPTH = 8
) (
    input  wire clk, rst_n,
    input  wire write_en,
    input  wire i_sclk,
    input  wire i_cs_n,
    input  wire i_mosi,
    input  wire i_miso,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire o_mosi,
    output wire o_miso,
    output wire  o_cs_n,
    output wire o_sclk,
    output wire done,
    output wire [DATA_WIDTH-1:0] data_out
);

    generate 
        if(SPI_MASTER) begin : gen_spi_master

            wire [DATA_WIDTH-1:0] fifo_data_out;
            wire fifo_empty, fifo_full;

            wire inactive_master, read_start, read_fifo;
            reg read_start_reg, read_fifo_reg;

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    read_start_reg <= 1'b0;
                    read_fifo_reg <= 1'b0;
                end else begin
                    read_start_reg <= read_start;
                    read_fifo_reg <= read_fifo;
                end
            end

            spi_fifo #(
                .FIFO_DEPTH(FIFO_DEPTH),
                .FIFO_WIDTH(DATA_WIDTH)
            ) fifo_inst (
                .clk(clk),
                .rst_n(rst_n),
                .data_in(data_in),
                .write_en(write_en),
                .read_en(read_fifo),
                .data_out(fifo_data_out),
                .full(fifo_full),
                .empty(fifo_empty)
            );

            spi_master #(
                .DATA_WIDTH(DATA_WIDTH)
            ) master_inst (
                .clk(clk),
                .rst_n(rst_n),
                .start(read_fifo_reg),
                .data_in(fifo_data_out),
                .miso(i_miso),
                .mosi(o_mosi),
                .cs_n(o_cs_n),
                .sclk(o_sclk),
                .data_out(data_out),
                .done(done),
                .inactive(inactive_master)
            );

            assign read_start = (!fifo_empty && inactive_master) ? 1'b1 : 1'b0;
            assign read_fifo = (read_start && !read_start_reg) ? 1'b1 : 1'b0;

        end else begin : gen_spi_slave

            wire [DATA_WIDTH-1:0] fifo_data_out, slave_data_in;
            wire fifo_empty, fifo_full;

            wire i_cs_n_fall, read_fifo;
            reg i_cs_n_reg, i_sclk_reg, mosi_reg;

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    i_cs_n_reg <= 1'b0;
                    i_sclk_reg <= 1'b0;
                    mosi_reg <= 1'b0;
                end else begin
                    i_cs_n_reg <= i_cs_n;
                    i_sclk_reg <= i_sclk;
                    mosi_reg <= i_mosi;
                end
            end
            spi_fifo #(
                .FIFO_DEPTH(FIFO_DEPTH),
                .FIFO_WIDTH(DATA_WIDTH)
            ) fifo_inst (
                .clk(clk),
                .rst_n(rst_n),
                .data_in(data_in),
                .write_en(write_en),
                .read_en(read_fifo),
                .data_out(fifo_data_out),
                .full(fifo_full),
                .empty(fifo_empty)
            );

            assign read_fifo = (i_cs_n_fall && !fifo_empty);
            assign i_cs_n_fall = ~i_cs_n & i_cs_n_reg;

            spi_slave #(
                .DATA_WIDTH(DATA_WIDTH)
            ) slave_inst (
                .clk(clk),
                .sclk(i_sclk_reg),
                .cs_n(i_cs_n_reg),
                .mosi(mosi_reg),
                .miso(o_miso),
                .data_in(fifo_data_out),
                .data_out(data_out),
                .done(done)
            ); 
        end
    endgenerate

   
endmodule