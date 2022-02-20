set_property IOSTANDARD LVCMOS33 [get_ports clk12M]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN A18 [get_ports rst]
set_property PACKAGE_PIN L17 [get_ports clk12M]


set_property  PACKAGE_PIN V8 [get_ports {rot_val[0]}]
set_property  PACKAGE_PIN U8 [get_ports {rot_val[1]}]
set_property  PACKAGE_PIN W7 [get_ports {rot_val[2]}]
set_property  PACKAGE_PIN U7 [get_ports {rot_val[3]}]
set_property  PACKAGE_PIN U3 [get_ports rot_b]
set_property  PACKAGE_PIN W6 [get_ports rot_a]


set_property IOSTANDARD LVCMOS33 [get_ports {rot_val[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports rot_a]
set_property IOSTANDARD LVCMOS33 [get_ports rot_b]
