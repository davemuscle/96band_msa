ghdl -a ../fft/fft_bram.vhd
ghdl -a octave_bufferer.vhd


ghdl -a octave_bufferer_tb.vhd
ghdl -r octave_bufferer_tb --wave=octave_bufferer.ghw

pause