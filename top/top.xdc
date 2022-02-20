set_property IOSTANDARD LVCMOS33 [get_ports clk12M]
set_property PACKAGE_PIN L17 [get_ports clk12M]

create_clock -period 83.333 [get_ports clk12M]

set_property PACKAGE_PIN V3 [get_ports pb]
set_property IOSTANDARD LVCMOS33 [get_ports pb]

set_property PACKAGE_PIN W3 [get_ports sel]
set_property IOSTANDARD LVCMOS33 [get_ports sel]