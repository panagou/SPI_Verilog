# Non Project Tcl script

set_param general.maxThreads 4

set top [lindex $argv 0] ;
set srcDir ../src/
# set tbDir ../verif
set outputDir ../spi_output
file mkdir $outputDir/lint

read_verilog [glob $srcDir*.v]

synth_design -top $top -lint -file $outputDir/lint/$top.log 

exit