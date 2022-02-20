set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN A18 [get_ports rst]
set_property PACKAGE_PIN L17 [get_ports clk]

set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports { pio26 }]; #IO_L2P_T0_34 Sch=pio[26]
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports { pio27 }]; #IO_L2N_T0_34 Sch=pio[27]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports { pio28 }]; #IO_L1P_T0_34 Sch=pio[28]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports { pio29 }]; #IO_L3P_T0_DQS_34 Sch=pio[29]