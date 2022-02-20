ghdl -a ../fft/fft_bram.vhd
ghdl -a downsampler.vhd


ghdl -a downsampler_tb.vhd
ghdl -r downsampler_tb --wave=downsampler.ghw

pause