
ghdl -a ../fft/fft_bram.vhd
ghdl -a ../fft/fft_twiddles.vhd
ghdl -a ../fft/fft.vhd

ghdl -a ../sram/sram_ctrl.vhd
ghdl -a ../sram/sram_model.vhd

ghdl -a kernel_bram.vhd
ghdl -a kernel_manager.vhd

ghdl -a kernel_tb.vhd
ghdl -r kernel_tb --wave=kernel.ghw

pause