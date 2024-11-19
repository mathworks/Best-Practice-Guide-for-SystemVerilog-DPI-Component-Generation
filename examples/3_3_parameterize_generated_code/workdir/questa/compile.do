vlog ../simpletestdir/simple_build/simple_dpi_pkg.sv
vlog ../simpletestdir/simple_build/simple_dpi.sv

vlog tb_top.sv

vsim work.tb_top -sv_lib ../simpletestdir/simple_build/simple_win64 -voptargs=+acc -do "do wave.do; run 1000"
