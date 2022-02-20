ghdl -a ../fft/fft_bram.vhd
ghdl -a ../fft/fft_bram64.vhd
ghdl -a ../fft/sqrt.vhd
ghdl -a ../fft/fft_mag.vhd
ghdl -a ../fft/fft_twiddles.vhd
ghdl -a ../fft/fft.vhd

ghdl -a ../cqt/kernel_bram.vhd
ghdl -a ../cqt/cqt.vhd
ghdl -a ../cqt/cqt_wrapper.vhd

ghdl -a octave_bufferer.vhd
ghdl -a bin_accumulator.vhd
ghdl -a mra_piano_keys.vhd

ghdl -a mra_piano_keys_tb.vhd
ghdl -r mra_piano_keys_tb --wave=mra_piano_keys.ghw

pause