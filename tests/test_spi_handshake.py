import test_spi
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, Combine
from cocotb.clock import Clock
from cocotb.types import LogicArray

import random
from cocotb_coverage.coverage import coverage_section
import cocotb

#--------------------------------------------------------------------------------------------------
async def spi_handshake_check(tx_master_data, tx_slave_data, master_done, slave_done, rx_master_data, rx_slave_data):

    async def check_master():
        for expected in tx_slave_data:
            await RisingEdge(master_done)
            await ReadOnly()
            actual = hex(rx_master_data.value)
            assert actual == hex(expected), f"Master Recv Error: Got {actual}, Expected {expected}"
            cocotb.log.info(f"Master received: {actual}")
            
    async def check_slave():
        for expected in tx_master_data:
            await RisingEdge(slave_done)
            await ReadOnly()
            actual = hex(rx_slave_data.value)
            assert actual == hex(expected), f"Slave Recv Error: Got {actual}, Expected {expected}"
            cocotb.log.info(f"Slave received:  {actual}")
            
    mastercheck = cocotb.start_soon(check_master())
    slavecheck = cocotb.start_soon(check_slave())
    
    await Combine(mastercheck, slavecheck)
    
async def spi_fifo_write(clk, write_en, data_in, data):
    for i in range(len(data)):
        await FallingEdge(clk)
        write_en.value = 0b1
        data_in.value = data[i]
        await RisingEdge(clk)
        await Timer(1, unit="ns")
        write_en.value = 0b0
        
async def read_master_results(clk, read_en, data_out, expected_data):
    cocotb.log.info("|--------Read Master Results--------|")
    cocotb.log.info("|  Expected Data  |   Actual Data   |")
    cocotb.log.info("|-----------------------------------|")
    
    for i in range(len(expected_data)):
        await FallingEdge(clk)
        read_en.value = 0b1
        await RisingEdge(clk)
        await ReadOnly()
        actual = data_out.value
        cocotb.log.info(f"|{hex(expected_data[i]):^{17}}|{hex(actual):^{17}}|")
        
def generate_random_data(data_width, fifo_depth):
    data_array =[]
    my_data = data(data_width)
    
    for _ in range (fifo_depth):
        my_data.randomize()
        data_array.append(int(my_data.data))
    return data_array

#--------------------------------------------------------------------------------------------------
class data(object):
    
    def __init__(self, width):
        self.width = width
        self.data = 0
        
    def randomize(self):
        self.data = random.getrandbits(self.width)

#--------------------------------------------------------------------------------------------------
@cocotb.test()
async def test_spi_handshake(dut):
    cocotb.log.info(f"Accesing the DUT: {dut._name}")
    
    master_data =  generate_random_data(dut.DATA_WIDTH.value, dut.FIFO_DEPTH.value)
    slave_data  =  generate_random_data(dut.DATA_WIDTH.value, dut.FIFO_DEPTH.value)
    
    dut.i_read_master.value = 0b0
    tx_data_master = dut.tx_data_master
    tx_data_slave = dut.tx_data_slave
    write_en_master = dut.write_en_master
    write_en_slave = dut.write_en_slave
      
    cocotb.start_soon(Clock(dut.clk, 4, unit="ns").start())  
    await test_spi.reset_dut(dut)
    
    scoreboard = cocotb.start_soon(spi_handshake_check(
    master_data,
    slave_data,
    dut.done_master,
    dut.done_slave,
    dut.spi_master_inst.gen_spi_master.master_data_out,
    dut.rx_data_slave
    ))
    
    cocotb.start_soon(spi_fifo_write(
        dut.clk,
        write_en_master,
        tx_data_master,
        master_data
    ))


    cocotb.start_soon(spi_fifo_write(
        dut.clk,
        write_en_slave,
        tx_data_slave,
        slave_data
    ))

    await scoreboard
    
    await read_master_results(
        dut.clk,
        dut.i_read_master,
        dut.rx_data_master,
        slave_data
    )
