
ghdl -a fft_bram.vhd

ghdl -a fft_bram_tb.vhd

ghdl -r fft_bram_tb --wave=fft_bram.ghw

pause