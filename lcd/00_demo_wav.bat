ghdl -a lcd_demo.vhd

ghdl -a lcd_demo_tb.vhd
ghdl -r testbench --wave=lcd_demo.ghw

pause