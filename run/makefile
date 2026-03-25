# SEED := 221

COMP_FLAGS :=   -f file_list.f

TOP ?= spi_module

SIM_FLAGS :=  tb_spi_sim -runall

compile:
	xvlog $(COMP_FLAGS)

lint:
	vivado -mode tcl -source scripts/lint.tcl -tclargs $(TOP)

synth:
	vivado -mode tcl -source scripts/build.tcl -tclargs $(TOP)

run:
	vivado -mode tcl -source scripts/sim.tcl

gui: 
	vivado -mode tcl -source scripts/gui.tcl -tclargs -gui

all : compile lint synth


clean:
	del *.jou *.log *.dcp *.runs *.pb 
	del /q ..\spi_output\sim\*
	rmdir /s /q xsim.dir .Xil


help:
	@echo "Usage:"
	@echo "  make compile  - Runs xvlog to compile files"
	@echo "  make lint     - Run linter on the design"
	@echo "  make synth    - Synthesize the design and report methodology"
	@echo "  make run      - Run the design"
	@echo "  make run      - Run the design"
	@echo "  make clean    - Clean up generated files"
	@echo "  make all      - Compile and run the design"
	@echo "  make help     - Show this help message"