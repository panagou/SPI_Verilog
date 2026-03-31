SPI Full-Duplex IP Core (Master & Slave)

A robust, high-performance Full-Duplex SPI (Serial Peripheral Interface) implementation in Verilog, featuring integrated FIFO buffers for both Master and Slave modules. This project includes a Python-based verification suite using cocotb.
* Features

    Full-Duplex Communication: Simultaneous data transmission and reception.

    Synchronous FIFO Buffers: Integrated FIFOs for input (RX) and output (TX) to decouple the SPI clock domain from the system logic.

    Configurable Parameters: Easily adjust Data Width (default 8-bit) and FIFO Depth.

    Cocotb Testbench: Modern Python-based verification environment for rigorous testing of edge cases and throughput.

* Architecture

The design consists of two primary modules: spi_master and spi_slave. Each module encapsulates a shift register state machine and circular buffer FIFOs to handle data bursts without CPU intervention.
Module Breakdown

    Master IP: Generates SCLK and CS_N. Controls the communication flow.

    Slave IP: Responds to the Master's clock and chip select signals.

    FIFO Logic: Prevents data loss during high-speed transfers by buffering incoming/outgoing bytes.
