
-------------------------------------------------------------------------------
-- xadc_wiz_0_axi_xadc.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ************************************************************************
-- ** DISCLAIMER OF LIABILITY                                            **
-- **                                                                    **
-- ** This file contains proprietary and confidential information of     **
-- ** Xilinx, Inc. ("Xilinx"), that is distributed under a license       **
-- ** from Xilinx, and may be used, copied and/or disclosed only         **
-- ** pursuant to the terms of a valid license agreement with Xilinx.    **
-- **                                                                    **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION              **
-- ** ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER         **
-- ** EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                **
-- ** LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,          **
-- ** MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx      **
-- ** does not warrant that functions included in the Materials will     **
-- ** meet the requirements of Licensee, or that the operation of the    **
-- ** Materials will be uninterrupted or error-free, or that defects     **
-- ** in the Materials will be corrected. Furthermore, Xilinx does       **
-- ** not warrant or make any representations regarding use, or the      **
-- ** results of the use, of the Materials in terms of correctness,      **
-- ** accuracy, reliability or otherwise.                                **
-- **                                                                    **
-- ** Xilinx products are not designed or intended to be fail-safe,      **
-- ** or for use in any application requiring fail-safe performance,     **
-- ** such as life-support or safety devices or systems, Class III       **
-- ** medical devices, nuclear facilities, applications related to       **
-- ** the deployment of airbags, or any other applications that could    **
-- ** lead to death, personal injury or severe property or               **
-- ** environmental damage (individually and collectively, "critical     **
-- ** applications"). Customer assumes the sole risk and liability       **
-- ** of any use of Xilinx products in critical applications,            **
-- ** subject only to applicable laws and regulations governing          **
-- ** limitations on product liability.                                  **
-- **                                                                    **
-- ** Copyright 2010, 2013 Xilinx, Inc.                                  **
-- ** All rights reserved.                                               **
-- **                                                                    **
-- ** This disclaimer and copyright notice must be retained as part      **
-- ** of this file at all times.                                         **
-- ************************************************************************
-------------------------------------------------------------------------------
-- File          : xadc_wiz_0_axi_xadc.vhd
-- Version       : v3.0
-- Description   : XADC macro with AXI bus interface 
-- Standard      : VHDL-93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Structure:
--             axi_xadc.vhd
--               -xadc_wiz_0_xadc_core_drp.vhd
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.conv_std_logic_vector;
    use IEEE.std_logic_arith.unsigned;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_misc.and_reduce;
    use IEEE.std_logic_misc.or_reduce;


-------------------------------------------------------------------------------
--   AXI4STREAM MASTER SIGNALS 
-------------------------------------------------------------------------------
--    m_axis_tdata         -- 16 bit Axi4Stream Data
--    m_axis_tvalid        -- Valid 
--    m_axis_tid          -- 5 bit Tag ID 
--    m_axis_tready        -- Ready 

entity xadc_wiz_0_axi_xadc is
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
    alarm_out       : out STD_LOGIC_VECTOR (7 downto 0);                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
  );   

end entity xadc_wiz_0_axi_xadc;
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------

architecture imp of xadc_wiz_0_axi_xadc is

component xadc_wiz_0_xadc_core_drp 
   port
   (
  -- axi4stream master signals 
     s_axis_aclk            : in  std_logic;
     m_axis_aclk            : in  std_logic;
     m_axis_resetn          : in  std_logic;                                      
                    
     m_axis_tdata           : out std_logic_vector(15 downto 0);
     m_axis_tvalid          : out std_logic;
     m_axis_tid             : out std_logic_vector(4 downto 0);
     m_axis_tready          : in  std_logic;
     ----------------  sysmon macro interface  -------------------
     vauxp4                 : in  STD_LOGIC;                         -- Auxiliary Channel 4
     vauxn4                 : in  STD_LOGIC;
     vauxp12                : in  STD_LOGIC;                         -- Auxiliary Channel 12
     vauxn12                : in  STD_LOGIC;
     busy_out               : out  STD_LOGIC;                        -- ADC Busy signal
     channel_out            : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
     eoc_out                : out  STD_LOGIC;                        -- End of Conversion Signal
     eos_out                : out  STD_LOGIC;                        -- End of Sequence Signal
     alarm_out              : out STD_LOGIC_VECTOR (7 downto 0);                   
     vp_in                  : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
     vn_in                  : in  STD_LOGIC
   );

end component;

-------------------------------------------------------------------------------
-- Architecture begins
-------------------------------------------------------------------------------
begin

--------------------------------------------
-- XADC_CORE_I: INSTANTIATE XADC CORE
--------------------------------------------

AXI_XADC_CORE_I : xadc_wiz_0_xadc_core_drp
   port map
   (
  -- axi4stream master signals 
    s_axis_aclk                  => s_axis_aclk, 
    m_axis_aclk                  => m_axis_aclk, 
    m_axis_resetn                => m_axis_resetn, 
    m_axis_tdata                 => m_axis_tdata, 
    m_axis_tvalid                => m_axis_tvalid, 
    m_axis_tid                   => m_axis_tid, 
    m_axis_tready                => m_axis_tready, 
    --- external interface signals ------------------
    vauxp4                       => vauxp4,
    vauxn4                       => vauxn4,
    vauxp12                      => vauxp12,
    vauxn12                      => vauxn12,
    busy_out                     => busy_out,
    channel_out                  => channel_out,
    eoc_out                      => eoc_out,
    eos_out                      => eos_out,
    alarm_out                    => alarm_out,
    vp_in                        => vp_in,
    vn_in                        => vn_in
   );

end architecture imp;
