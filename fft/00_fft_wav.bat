ghdl -a sqrt.vhd

ghdl -a fft_bram.vhd
ghdl -a fft_bram64.vhd
ghdl -a fft_twiddles.vhd
ghdl -a fft.vhd


ghdl -a fft_tb.vhd
ghdl -r fft_tb --wave=fft.ghw

pause