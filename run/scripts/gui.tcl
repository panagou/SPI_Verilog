set top spi_master_tb

set tbDir ../verif
set outputDir ../spi_output
file mkdir $outputDir/sim


exec xvlog -f file_list.f
exec xelab $top -incremental -mt 8 -debug typical -timescale 1ns/1ps -s spi_master_tb_sim
exec xsim spi_master_tb_sim -t scripts/add_waves.tcl -gui -runall -wdb $outputDir/sim/spi_master_tb_sim.wdb -log $outputDir/sim/spi_master_tb_sim.log


exit