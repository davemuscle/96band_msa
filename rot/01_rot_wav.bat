ghdl -a rotary_encoder.vhd
ghdl -a rotary_encoder_tb.vhd
ghdl -r rotary_encoder_tb --wave=rotary_encoder.ghw

pause