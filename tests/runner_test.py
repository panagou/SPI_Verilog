import pytest
import inspect 
from cocotb_tools.runner import Verilog, get_runner
import os

def get_build_dir():
    
    caller_name = inspect.stack()[1].function
    return os.path.join(os.path.abspath("./"), f"build_{caller_name}".replace("test_", "").replace("_runner", ""))

def get_test_dir():
    
    caller_name = inspect.stack()[1].function
    return os.path.join(os.path.abspath("./"), f"{caller_name}".replace("_runner", ""))

#------------------------------------------------------------------------------------------------
@pytest.mark.parametrize("master", [False])

def test_spi_module_runner(master):
    runner = get_runner("icarus")
    
    build_drctr = get_build_dir()
    test_drctr = get_test_dir()
    
    runner.build(
        sources = [
            Verilog("../src/spi_module.v")
        ],
        includes = ["../src/"],
        hdl_toplevel = "spi_module",
        waves = True,
        parameters = {"DATA_WIDTH" : 4, "SPI_MASTER" : 0, "FIFO_DEPTH" : 8},
        always = True,
        log_file = os.path.join(build_drctr, f"./build_{__name__}.log"),
        build_dir = build_drctr
    )
    
    runner.test(
        hdl_toplevel = "spi_module", 
        test_module = "test_spi", 
        test_filter = f"test_spi_{"master" if master else "slave"}",
        waves = True,
        log_file = os.path.join(test_drctr, f"./test_{__name__}.log"),
        test_dir = test_drctr,
    )
    
#------------------------------------------------------------------------------------------------
def test_spi_handshake_runner():
    runner = get_runner("icarus")
        
    build_drctr = get_build_dir()
    test_drctr = get_test_dir()
    
    runner.build(
        sources = [
                Verilog("../src/spi_handshake_top.v")
            ],
        includes = ["../src/"],
        hdl_toplevel = "spi_handshake_top",
        waves = True,
        always = True,
        parameters = {"DATA_WIDTH" : 4},
        build_dir = build_drctr,
        log_file = os.path.join(build_drctr, f"./build_{__name__}.log")
    )
    
    runner.test(
        hdl_toplevel = "spi_handshake_top", 
        test_module = "test_spi", 
        test_filter = "test_spi_handshake",
        waves = True,
        log_file = os.path.join(test_drctr, f"./test_{__name__}.log"),
        test_dir = test_drctr,
    )
    