ghdl -a vga_box_demo.vhd

ghdl -a vga_box_demo_tb.vhd
ghdl -r testbench --wave=vga_box_demo.ghw

pause