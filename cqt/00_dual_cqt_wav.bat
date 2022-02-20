
ghdl -a ../i2s/i2s_overlapper.vhd

ghdl -a ../fft/fft_bram.vhd
ghdl -a ../fft/fft_bram64.vhd
ghdl -a ../fft/fft_twiddles.vhd
ghdl -a ../fft/fft.vhd

ghdl -a downsampler.vhd

ghdl -a cqt.vhd
ghdl -a cqt_wrapper.vhd

ghdl -a dual_bins.vhd

ghdl -a dual_cqt.vhd



ghdl -a dual_cqt_tb.vhd
ghdl -r dual_cqt_tb --wave=dual_cqt.ghw

pause