from cocotb.triggers import Timer, ClockCycles
from cocotb.clock import Clock
from cocotb.types import LogicArray
import cocotb

async def reset_dut(dut):
    cocotb.log.info("Reseting the design.")
    dut.rst_n.value = 1
    await Timer(1, unit="ns")
    dut.rst_n.value = 0
    await Timer(1, unit="ns")
    dut.rst_n.value = 1

#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_master(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    data_in = dut.data_in
    start = dut.start
    miso = dut.i_miso
    
    miso.value = 0b0
    start.value = 0b1
    data_in.value = LogicArray(6, 4)
    
    
    
    await reset_dut(dut)
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())
    await Timer(5, unit="ns")
    start.value = 0b0
    
    
    await ClockCycles(dut.clk, 100, rising=True)

#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_handshake(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    tx_data_master = dut.tx_data_master
    tx_data_slave = dut.tx_data_slave
    start = dut.start_master
    rx_data_master = dut.rx_data_master
    rx_data_slave = dut.rx_data_slave
    
    tx_data_master.value = tx_data_slave.value = LogicArray(6, 4)
    start.value = 0b1
    
    await reset_dut(dut)
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())
    await Timer(5, unit="ns")
    start.value = 0b0
    
    await ClockCycles(dut.clk, 100, rising=True)