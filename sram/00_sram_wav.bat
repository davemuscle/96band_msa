
ghdl -a sram_ctrl.vhd
ghdl -a sram_model.vhd


ghdl -a sram_ctrl_tb.vhd
ghdl -r sram_ctrl_tb --wave=sram_ctrl_tb.ghw

pause