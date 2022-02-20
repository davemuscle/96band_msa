ghdl -a ../fft/fft_bram.vhd
ghdl -a bin_accumulator.vhd


ghdl -a bin_accumulator_tb.vhd
ghdl -r bin_accumulator_tb --wave=bin_accumulator.ghw

pause