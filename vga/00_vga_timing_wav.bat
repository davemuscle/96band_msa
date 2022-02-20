ghdl -a vga_timing_gen_pkg.vhd
ghdl -a vga_timing_gen.vhd

ghdl -a vga_timing_gen_tb.vhd
ghdl -r testbench --wave=vga_timing_gen.ghw

pause