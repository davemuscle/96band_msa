
#PIO01 -- bottom right pin
set_property PACKAGE_PIN L2 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

#PIO02
set_property PACKAGE_PIN L1 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]


set_property PACKAGE_PIN K3 [get_ports {blu[3]}]
set_property PACKAGE_PIN A16 [get_ports {blu[2]}]
set_property PACKAGE_PIN L3  [get_ports {blu[1]}]
set_property PACKAGE_PIN M3  [get_ports {blu[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blu[*]}]

set_property PACKAGE_PIN B15  [get_ports {grn[3]}]
set_property PACKAGE_PIN A15  [get_ports {grn[2]}]
set_property PACKAGE_PIN H1  [get_ports {grn[1]}]
set_property PACKAGE_PIN C15  [get_ports {grn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {grn[*]}]

set_property PACKAGE_PIN K2  [get_ports {red[3]}]
set_property PACKAGE_PIN J1  [get_ports {red[2]}] 
set_property PACKAGE_PIN J3  [get_ports {red[1]}]
set_property PACKAGE_PIN A14  [get_ports {red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[*]}]