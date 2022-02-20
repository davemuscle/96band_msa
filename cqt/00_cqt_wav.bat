
ghdl -a ../fft/fft_bram.vhd
ghdl -a ../fft/fft_bram64.vhd
ghdl -a ../fft/fft_twiddles.vhd
ghdl -a ../fft/fft.vhd

ghdl -a ../sram/sram_ctrl.vhd
ghdl -a ../sram/sram_model.vhd

ghdl -a kernel_bram.vhd
ghdl -a kernel_manager.vhd

ghdl -a cqt.vhd

ghdl -a cqt_tb.vhd
ghdl -r cqt_tb --wave=cqt.ghw

pause