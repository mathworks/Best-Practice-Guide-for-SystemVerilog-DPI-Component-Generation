onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/clk
add wave -noupdate /tb_top/dut/clk_enable
add wave -noupdate /tb_top/dut/reset
add wave -noupdate /tb_top/dut/inputArg1
add wave -noupdate /tb_top/dut/inputArg2
add wave -noupdate /tb_top/dut/outputArg11
add wave -noupdate /simple_dpi_pkg::DPI_simple_setparam_valid_f/RTWStructParam_valid
add wave -noupdate /simple_dpi_pkg::DPI_simple_setparam_opt1_f/RTWStructParam_opt1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {268 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {75 ns} {349 ns}
