ghdl -a bin_bram.vhd

ghdl -a vga_timing_gen_pkg.vhd
ghdl -a vga_timing_gen.vhd


ghdl -a vga_2d_bin_render_basic.vhd

ghdl -a vga_2d_bin_render_basic_tb.vhd
ghdl -r vga_2d_bin_render_basic_tb --wave=vga_2d_bin_render_basic.ghw

pause