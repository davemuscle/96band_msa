ghdl -a i2s_master.vhd
ghdl -a i2s_bram.vhd
ghdl -a i2s_stereo_pingpong.vhd
ghdl -a i2s_stereo2mono.vhd
ghdl -a i2s_overlapper.vhd
ghdl -a pp_tb.vhd
ghdl -r pp_tb --wave=pp.ghw

pause