ghdl -a sqrt.vhd

ghdl -a fft_bram.vhd
ghdl -a fft_bram64.vhd
ghdl -a fft_twiddles.vhd
ghdl -a fft.vhd
ghdl -a fft_mag.vhd

ghdl -a fft_mag_tb.vhd
ghdl -r fft_mag_tb --wave=fft_mag.ghw

pause