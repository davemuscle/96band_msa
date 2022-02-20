
ghdl -a ../fft/fft_bram64.vhd




ghdl -a dual_bins.vhd
ghdl -a dual_bins_tb.vhd
ghdl -r dual_bins_tb --wave=dual_bins.ghw

pause