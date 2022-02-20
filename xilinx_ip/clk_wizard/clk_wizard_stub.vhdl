-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Sun Mar 15 14:17:59 2020
-- Host        : DESKTOP-FH2NF4G running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top clk_wizard -prefix
--               clk_wizard_ clk_wizard_stub.vhdl
-- Design      : clk_wizard
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a15tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wizard is
  Port ( 
    i2s_clk : out STD_LOGIC;
    p_clk : out STD_LOGIC;
    fft_clk : out STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clk_wizard;

architecture stub of clk_wizard is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "i2s_clk,p_clk,fft_clk,locked,clk_in1";
begin
end;
