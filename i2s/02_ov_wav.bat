
ghdl -a i2s_bram.vhd

ghdl -a i2s_overlapper.vhd
ghdl -a overlapper_tb.vhd
ghdl -r overlapper_tb --wave=overlapper.ghw

pause