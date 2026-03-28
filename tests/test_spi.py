from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray
import cocotb

async def reset_dut(dut):
    cocotb.log.info("Reseting the design.")
    dut.rst_n.value = 1
    await Timer(5, unit="ns")
    dut.rst_n.value = 0
    await Timer(5, unit="ns")
    dut.rst_n.value = 1
    
async def spi_master_write(dut, data):
    await FallingEdge(dut.clk)
    dut.write_en.value = 0b1
    dut.data_in.value = LogicArray(data, int(dut.DATA_WIDTH.value))
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.write_en.value = 0b0
    
async def spi_slave_send(dut):
    dut.i_cs_n.value = 0b0
    for _ in range(5):
        dut.i_sclk.value = 0b0
        await RisingEdge (dut.clk)
        dut.i_sclk.value = 0b1
        await RisingEdge (dut.clk)
    dut.i_cs_n.value = 0b1
    
#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_master(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    miso = dut.i_miso
      
    miso.value = 0b0
    
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())
    await reset_dut(dut)
    
    await Timer(10, unit="ns")

    await spi_master_write(dut, 15)
    await Timer(1, unit="ns")
    await spi_master_write(dut, 12)
    await Timer(1, unit="ns")
    await spi_master_write(dut, 5)
    await Timer(1, unit="ns")
    await spi_master_write(dut, 3)
    await Timer(1, unit="ns")
    await spi_master_write(dut, 2)
    
    
    await ClockCycles(dut.clk, 100, rising=True)

#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_slave(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    tx_slave_data = [15, 12, 5, 3, 2]
    
    mosi = dut.i_mosi
    slave_cs_n = dut.i_cs_n
    slave_cs_n.value = 0b0
      
    mosi.value = 0b0
 
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())   
    await reset_dut(dut)

    # cocotb.start_soon(Clock(dut.i_sclk, 8, unit="ns").start())
    
    for data in tx_slave_data:
        await spi_master_write(dut, data)
        await Timer(1, unit="ns")

    await ClockCycles(dut.clk, 2, rising=True)
    dut.data_in.value = LogicArray("xxxx")
    
    await FallingEdge(dut.clk)
    slave_cs_n.value = 0b1
    await RisingEdge(dut.clk)
    
    for i in range(len(tx_slave_data)):
        await spi_slave_send(dut)
        await RisingEdge(dut.clk)
        
    
    await ClockCycles(dut.clk, 200, rising=True)
