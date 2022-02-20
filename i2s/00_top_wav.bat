ghdl -a i2s_master.vhd
ghdl -a i2s_bram.vhd
ghdl -a i2s_stereo_pingpong.vhd
ghdl -a top_tb.vhd
ghdl -r top_tb --wave=top.ghw

pause