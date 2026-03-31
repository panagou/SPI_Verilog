# SPI Full-Duplex IP Core with FIFO

A high-performance, **Full-Duplex SPI (Serial Peripheral Interface)** implementation in Verilog. This repository contains both **Master** and **Slave** IP cores, each integrated with **Synchronous FIFOs** to handle data buffering, ensuring reliable communication even when the system clock and SPI clock are desynchronized.

This project includes a Python-based verification suite using cocotb.

---

## Key Features

* **Full-Duplex:** Simultaneous bidirectional data transfer (MOSI and MISO).
* **Integrated FIFOs:**
    * **TX FIFO:** Buffers data from the system logic to be sent over SPI.
    * **RX FIFO:** Buffers incoming SPI data for the system logic to read.
* **Configurable Parameters:**
    * `DATA_WIDTH`: Default 8-bit (adjustable to 16, 32, etc.).
    * `FIFO_DEPTH`: Configurable buffer size to prevent data loss.
* **Verification:** Includes a Python testbench using `cocotb` for automated, scalable testing.

---

## Architecture Overview

The system is designed to decouple the high-speed system clock domain from the relatively slower SPI serial clock.

1.  **System Interface:** Simple `write_en/read_en` handshake to interact with the internal FIFOs.
2.  **FIFO Layer:** Provides elasticity. The Master can "load up" multiple bytes into the TX FIFO before starting a transmission.
3.  **Shift Register:** Logic that converts parallel FIFO data into serial bits and vice versa.
