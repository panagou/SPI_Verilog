import test_spi
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, Combine
from cocotb.clock import Clock
from cocotb.types import LogicArray
import cocotb

#--------------------------------------------------------------------------------------------------
async def spi_handshake_check(tx_master_data, tx_slave_data, master_done, slave_done, rx_master_data, rx_slave_data):

    async def check_master():
        for expected in tx_slave_data:
            await RisingEdge(master_done)
            await ReadOnly()
            actual = int (rx_master_data.value)
            assert actual == expected, f"Master Recv Error: Got {actual}, Expected {expected}"
            cocotb.log.info(f"Master received: {actual}")
            
    async def check_slave():
        for expected in tx_master_data:
            await RisingEdge(slave_done)
            await ReadOnly()
            actual = int (rx_slave_data.value)
            assert actual == expected, f"Slave Recv Error: Got {actual}, Expected {expected}"
            cocotb.log.info(f"Slave received:  {actual}")
            
    mastercheck = cocotb.start_soon(check_master())
    slavecheck = cocotb.start_soon(check_slave())
    
    await Combine(mastercheck, slavecheck)
    
async def spi_fifo_write(clk, write_en, data_in, data, width, fifo_depth):
    for i in range(len(data)):
        await FallingEdge(clk)
        write_en.value = 0b1
        data_in.value = LogicArray(data[i], int(width.value))
        await RisingEdge(clk)
        await Timer(1, unit="ns")
        write_en.value = 0b0
        
#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_handshake(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    master_data = [15, 12, 5, 3, 2]
    slave_data  = [1, 2, 5, 7, 9]
    
    tx_data_master = dut.tx_data_master
    tx_data_slave = dut.tx_data_slave
    write_en_master = dut.write_en_master
    write_en_slave = dut.write_en_slave
      
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())  
    await test_spi.reset_dut(dut)
  
    
    cocotb.start_soon(spi_fifo_write(
        dut.clk,
        write_en_master,
        tx_data_master,
        master_data,
        dut.DATA_WIDTH,
        dut.FIFO_DEPTH
    ))


    cocotb.start_soon(spi_fifo_write(
        dut.clk,
        write_en_slave,
        tx_data_slave,
        slave_data,
        dut.DATA_WIDTH,
        dut.FIFO_DEPTH
    ))
    
    await spi_handshake_check(
        master_data,
        slave_data,
        dut.done_master,
        dut.done_slave,
        dut.rx_data_master,
        dut.rx_data_slave
    )

    
    await ClockCycles(dut.clk, 20, rising=True)
