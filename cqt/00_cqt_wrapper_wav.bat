
ghdl -a ../fft/fft_bram.vhd
ghdl -a ../fft/fft_bram64.vhd
ghdl -a ../fft/fft_twiddles.vhd
ghdl -a ../fft/fft.vhd


ghdl -a kernel_bram.vhd


ghdl -a cqt.vhd
ghdl -a cqt_wrapper.vhd

ghdl -a cqt_wrapper_tb.vhd
ghdl -r cqt_wrapper_tb --wave=cqt_wrapper.ghw

pause