// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sun Mar 15 14:17:59 2020
// Host        : DESKTOP-FH2NF4G running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top clk_wizard -prefix
//               clk_wizard_ clk_wizard_stub.v
// Design      : clk_wizard
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a15tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wizard(i2s_clk, p_clk, fft_clk, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="i2s_clk,p_clk,fft_clk,locked,clk_in1" */;
  output i2s_clk;
  output p_clk;
  output fft_clk;
  output locked;
  input clk_in1;
endmodule
