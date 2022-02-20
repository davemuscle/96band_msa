ghdl -a lcd_ctrl_pkg.vhd
ghdl -a lcd_ctrl.vhd

ghdl -a lcd_ctrl_tb.vhd
ghdl -r testbench --wave=lcd_ctrl.ghw

pause