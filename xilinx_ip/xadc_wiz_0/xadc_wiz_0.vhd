
-- file: xadc_wiz_0.vhd
-- (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity xadc_wiz_0 is
   port
   (
  -- axi4stream master signals 
    s_axis_aclk     : in  std_logic;
    m_axis_aclk     : in  std_logic;
    m_axis_resetn   : in  std_logic;                                      
    m_axis_tdata    : out std_logic_vector(15 downto 0);
    m_axis_tvalid   : out std_logic;
    m_axis_tid      : out std_logic_vector(4 downto 0);
    m_axis_tready   : in  std_logic;
    vauxp4          : in  STD_LOGIC;                         -- Auxiliary Channel 4
    vauxn4          : in  STD_LOGIC;
    vauxp12         : in  STD_LOGIC;                         -- Auxiliary Channel 12
    vauxn12         : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end xadc_wiz_0;

architecture xilinx of xadc_wiz_0 is

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of xilinx : architecture is "xadc_wiz_0,xadc_wiz_v3_3_7,{component_name=xadc_wiz_0,enable_axi=false,enable_axi4stream=true,dclk_frequency=61,enable_busy=true,enable_convst=false,enable_convstclk=false,enable_dclk=true,enable_drp=false,enable_eoc=true,enable_eos=true,enable_vbram_alaram=false,enable_vccddro_alaram=false,enable_Vccint_Alaram=false,enable_Vccaux_alaram=falseenable_vccpaux_alaram=false,enable_vccpint_alaram=false,ot_alaram=false,user_temp_alaram=false,timing_mode=continuous,channel_averaging=None,sequencer_mode=on,startup_channel_selection=contineous_sequence}";


  component xadc_wiz_0_axi_xadc 
   port
   (
  -- axi4stream master signals 
    s_axis_aclk     : in  std_logic;
    m_axis_aclk     : in  std_logic;
    m_axis_resetn   : in  std_logic;                                      
    m_axis_tdata    : out std_logic_vector(15 downto 0);
    m_axis_tvalid   : out std_logic;
    m_axis_tid      : out std_logic_vector(4 downto 0);
    m_axis_tready   : in  std_logic;
   -- XADC External interface signals

    -- Conversion start control signal for Event driven mode
    vauxp4          : in  STD_LOGIC;                         -- Auxiliary Channel 4
    vauxn4          : in  STD_LOGIC;
    vauxp12         : in  STD_LOGIC;                         -- Auxiliary Channel 12
    vauxn12         : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC_VECTOR(7 downto 0);
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
   );
  end component;

  signal alm_int : std_logic_vector (7 downto 0);

begin

       alarm_out <= alm_int(7);

   U0 : xadc_wiz_0_axi_xadc 
   port map
   (
    s_axis_aclk     => s_axis_aclk,
    m_axis_aclk     => m_axis_aclk,
    m_axis_resetn   => m_axis_resetn,
    m_axis_tdata    => m_axis_tdata,
    m_axis_tvalid   => m_axis_tvalid,
    m_axis_tid      => m_axis_tid,
    m_axis_tready   => m_axis_tready,
    vauxp4 => vauxp4,
    vauxn4 => vauxn4,
    vauxp12 => vauxp12,
    vauxn12 => vauxn12,
    busy_out => busy_out,
    channel_out => channel_out,
    eoc_out => eoc_out,
    eos_out => eos_out,
    alarm_out  => alm_int,
    vp_in => vp_in,
    vn_in => vn_in
         );
end xilinx;

