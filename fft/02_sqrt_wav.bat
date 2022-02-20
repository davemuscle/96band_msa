
ghdl -a sqrt.vhd

ghdl -a sqrt_tb.vhd

ghdl -r sqrt_tb --wave=sqrt.ghw

pause