-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Sun Mar 15 14:38:16 2020
-- Host        : DESKTOP-FH2NF4G running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/xilinx_ip/xadc_wiz_0/xadc_wiz_0_sim_netlist.vhdl
-- Design      : xadc_wiz_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a15tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity xadc_wiz_0_drp_to_axi4stream is
  port (
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    AR : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    Q : out STD_LOGIC_VECTOR ( 5 downto 0 );
    den_C : out STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    s_axis_aclk : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    DO : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tready : in STD_LOGIC;
    m_axis_resetn : in STD_LOGIC;
    drdy_C : in STD_LOGIC;
    CHANNEL : in STD_LOGIC_VECTOR ( 4 downto 0 );
    den_o_reg_0 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of xadc_wiz_0_drp_to_axi4stream : entity is "drp_to_axi4stream";
end xadc_wiz_0_drp_to_axi4stream;

architecture STRUCTURE of xadc_wiz_0_drp_to_axi4stream is
  signal \^ar\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal FIFO18E1_inst_data_i_1_n_0 : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[3]_i_1_n_0\ : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal almost_full : STD_LOGIC;
  signal \busy_o0__0\ : STD_LOGIC;
  signal channel_id : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal \channel_id[6]_i_1_n_0\ : STD_LOGIC;
  signal \^den_c\ : STD_LOGIC;
  signal \den_o0__0\ : STD_LOGIC;
  signal den_o_i_1_n_0 : STD_LOGIC;
  signal fifo_empty : STD_LOGIC;
  signal \state__0\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \state__1\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal valid_data_wren_i_1_n_0 : STD_LOGIC;
  signal valid_data_wren_reg_n_0 : STD_LOGIC;
  signal wren_fifo : STD_LOGIC;
  signal NLW_FIFO18E1_inst_data_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_data_FULL_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_data_RDERR_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_data_WRERR_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_data_DO_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 16 );
  signal NLW_FIFO18E1_inst_data_DOP_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_FIFO18E1_inst_data_RDCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_FIFO18E1_inst_data_WRCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_FIFO18E1_inst_tid_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_ALMOSTFULL_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_EMPTY_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_FULL_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_RDERR_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_WRERR_UNCONNECTED : STD_LOGIC;
  signal NLW_FIFO18E1_inst_tid_DO_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 5 );
  signal NLW_FIFO18E1_inst_tid_DOP_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_FIFO18E1_inst_tid_RDCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_FIFO18E1_inst_tid_WRCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  attribute box_type : string;
  attribute box_type of FIFO18E1_inst_data : label is "PRIMITIVE";
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of FIFO18E1_inst_data_i_1 : label is "soft_lutpair3";
  attribute box_type of FIFO18E1_inst_tid : label is "PRIMITIVE";
  attribute SOFT_HLUTNM of \FSM_sequential_state[0]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \FSM_sequential_state[3]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \FSM_sequential_state[3]_i_3\ : label is "soft_lutpair2";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[0]\ : label is "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011";
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[1]\ : label is "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011";
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[2]\ : label is "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011";
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[3]\ : label is "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011";
  attribute SOFT_HLUTNM of \channel_id[0]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \channel_id[6]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of den_o_i_2 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of m_axis_tvalid_INST_0 : label is "soft_lutpair3";
begin
  AR(0) <= \^ar\(0);
  Q(5 downto 0) <= \^q\(5 downto 0);
  den_C <= \^den_c\;
FIFO18E1_inst_data: unisim.vcomponents.FIFO18E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"0006",
      ALMOST_FULL_OFFSET => X"03F9",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_SYN => false,
      FIFO_MODE => "FIFO18",
      FIRST_WORD_FALL_THROUGH => true,
      INIT => X"000000000",
      IS_RDCLK_INVERTED => '0',
      IS_RDEN_INVERTED => '0',
      IS_RSTREG_INVERTED => '0',
      IS_RST_INVERTED => '0',
      IS_WRCLK_INVERTED => '0',
      IS_WREN_INVERTED => '0',
      SIM_DEVICE => "7SERIES",
      SRVAL => X"000000000"
    )
        port map (
      ALMOSTEMPTY => NLW_FIFO18E1_inst_data_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => almost_full,
      DI(31 downto 16) => B"0000000000000000",
      DI(15 downto 0) => DO(15 downto 0),
      DIP(3 downto 0) => B"0000",
      DO(31 downto 16) => NLW_FIFO18E1_inst_data_DO_UNCONNECTED(31 downto 16),
      DO(15 downto 0) => m_axis_tdata(15 downto 0),
      DOP(3 downto 0) => NLW_FIFO18E1_inst_data_DOP_UNCONNECTED(3 downto 0),
      EMPTY => fifo_empty,
      FULL => NLW_FIFO18E1_inst_data_FULL_UNCONNECTED,
      RDCLK => s_axis_aclk,
      RDCOUNT(11 downto 0) => NLW_FIFO18E1_inst_data_RDCOUNT_UNCONNECTED(11 downto 0),
      RDEN => FIFO18E1_inst_data_i_1_n_0,
      RDERR => NLW_FIFO18E1_inst_data_RDERR_UNCONNECTED,
      REGCE => '1',
      RST => \^ar\(0),
      RSTREG => '0',
      WRCLK => m_axis_aclk,
      WRCOUNT(11 downto 0) => NLW_FIFO18E1_inst_data_WRCOUNT_UNCONNECTED(11 downto 0),
      WREN => wren_fifo,
      WRERR => NLW_FIFO18E1_inst_data_WRERR_UNCONNECTED
    );
FIFO18E1_inst_data_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => m_axis_tready,
      I1 => fifo_empty,
      O => FIFO18E1_inst_data_i_1_n_0
    );
FIFO18E1_inst_data_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => m_axis_resetn,
      O => \^ar\(0)
    );
FIFO18E1_inst_data_i_3: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => drdy_C,
      I1 => valid_data_wren_reg_n_0,
      O => wren_fifo
    );
FIFO18E1_inst_tid: unisim.vcomponents.FIFO18E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"0006",
      ALMOST_FULL_OFFSET => X"03F9",
      DATA_WIDTH => 18,
      DO_REG => 1,
      EN_SYN => false,
      FIFO_MODE => "FIFO18",
      FIRST_WORD_FALL_THROUGH => true,
      INIT => X"000000000",
      IS_RDCLK_INVERTED => '0',
      IS_RDEN_INVERTED => '0',
      IS_RSTREG_INVERTED => '0',
      IS_RST_INVERTED => '0',
      IS_WRCLK_INVERTED => '0',
      IS_WREN_INVERTED => '0',
      SIM_DEVICE => "7SERIES",
      SRVAL => X"000000000"
    )
        port map (
      ALMOSTEMPTY => NLW_FIFO18E1_inst_tid_ALMOSTEMPTY_UNCONNECTED,
      ALMOSTFULL => NLW_FIFO18E1_inst_tid_ALMOSTFULL_UNCONNECTED,
      DI(31 downto 7) => B"0000000000000000000000000",
      DI(6) => \^q\(5),
      DI(5) => '0',
      DI(4 downto 0) => \^q\(4 downto 0),
      DIP(3 downto 0) => B"0000",
      DO(31 downto 5) => NLW_FIFO18E1_inst_tid_DO_UNCONNECTED(31 downto 5),
      DO(4 downto 0) => m_axis_tid(4 downto 0),
      DOP(3 downto 0) => NLW_FIFO18E1_inst_tid_DOP_UNCONNECTED(3 downto 0),
      EMPTY => NLW_FIFO18E1_inst_tid_EMPTY_UNCONNECTED,
      FULL => NLW_FIFO18E1_inst_tid_FULL_UNCONNECTED,
      RDCLK => s_axis_aclk,
      RDCOUNT(11 downto 0) => NLW_FIFO18E1_inst_tid_RDCOUNT_UNCONNECTED(11 downto 0),
      RDEN => FIFO18E1_inst_data_i_1_n_0,
      RDERR => NLW_FIFO18E1_inst_tid_RDERR_UNCONNECTED,
      REGCE => '1',
      RST => \^ar\(0),
      RSTREG => '0',
      WRCLK => m_axis_aclk,
      WRCOUNT(11 downto 0) => NLW_FIFO18E1_inst_tid_WRCOUNT_UNCONNECTED(11 downto 0),
      WREN => wren_fifo,
      WRERR => NLW_FIFO18E1_inst_tid_WRERR_UNCONNECTED
    );
\FSM_sequential_state[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"51555551"
    )
        port map (
      I0 => \state__0\(0),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => DO(15),
      I4 => DO(14),
      O => \state__1\(0)
    );
\FSM_sequential_state[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00FFBE00"
    )
        port map (
      I0 => \state__0\(2),
      I1 => DO(15),
      I2 => DO(14),
      I3 => \state__0\(1),
      I4 => \state__0\(0),
      O => \state__1\(1)
    );
\FSM_sequential_state[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"60"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(2),
      I2 => \FSM_sequential_state[2]_i_2_n_0\,
      O => \state__1\(2)
    );
\FSM_sequential_state[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F4040404FFFFFFFF"
    )
        port map (
      I0 => DO(14),
      I1 => DO(15),
      I2 => \state__0\(0),
      I3 => CHANNEL(4),
      I4 => den_o_reg_0,
      I5 => \state__0\(1),
      O => \FSM_sequential_state[2]_i_2_n_0\
    );
\FSM_sequential_state[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1055555510550011"
    )
        port map (
      I0 => \state__0\(3),
      I1 => \state__0\(2),
      I2 => \busy_o0__0\,
      I3 => \state__0\(1),
      I4 => \state__0\(0),
      I5 => drdy_C,
      O => \FSM_sequential_state[3]_i_1_n_0\
    );
\FSM_sequential_state[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00002002"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(2),
      I2 => DO(15),
      I3 => DO(14),
      I4 => \state__0\(0),
      O => \state__1\(3)
    );
\FSM_sequential_state[3]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => den_o_reg_0,
      I1 => CHANNEL(4),
      O => \busy_o0__0\
    );
\FSM_sequential_state_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \FSM_sequential_state[3]_i_1_n_0\,
      CLR => \^ar\(0),
      D => \state__1\(0),
      Q => \state__0\(0)
    );
\FSM_sequential_state_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \FSM_sequential_state[3]_i_1_n_0\,
      CLR => \^ar\(0),
      D => \state__1\(1),
      Q => \state__0\(1)
    );
\FSM_sequential_state_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \FSM_sequential_state[3]_i_1_n_0\,
      CLR => \^ar\(0),
      D => \state__1\(2),
      Q => \state__0\(2)
    );
\FSM_sequential_state_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \FSM_sequential_state[3]_i_1_n_0\,
      CLR => \^ar\(0),
      D => \state__1\(3),
      Q => \state__0\(3)
    );
\channel_id[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30303171"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(3),
      I2 => CHANNEL(0),
      I3 => \state__0\(0),
      I4 => \state__0\(2),
      O => channel_id(0)
    );
\channel_id[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"32003700"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(3),
      I2 => \state__0\(2),
      I3 => CHANNEL(1),
      I4 => \state__0\(0),
      O => channel_id(1)
    );
\channel_id[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"32003700"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(3),
      I2 => \state__0\(2),
      I3 => CHANNEL(2),
      I4 => \state__0\(0),
      O => channel_id(2)
    );
\channel_id[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"22102710"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(3),
      I2 => \state__0\(2),
      I3 => CHANNEL(3),
      I4 => \state__0\(0),
      O => channel_id(3)
    );
\channel_id[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0B0A04000B5F0400"
    )
        port map (
      I0 => \state__0\(1),
      I1 => CHANNEL(3),
      I2 => \state__0\(3),
      I3 => \state__0\(2),
      I4 => CHANNEL(4),
      I5 => \state__0\(0),
      O => channel_id(4)
    );
\channel_id[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2226"
    )
        port map (
      I0 => \state__0\(0),
      I1 => \state__0\(3),
      I2 => \state__0\(1),
      I3 => \state__0\(2),
      O => \channel_id[6]_i_1_n_0\
    );
\channel_id[6]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => \state__0\(3),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      O => channel_id(6)
    );
\channel_id_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(0),
      Q => \^q\(0)
    );
\channel_id_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(1),
      Q => \^q\(1)
    );
\channel_id_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(2),
      Q => \^q\(2)
    );
\channel_id_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(3),
      Q => \^q\(3)
    );
\channel_id_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(4),
      Q => \^q\(4)
    );
\channel_id_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => \channel_id[6]_i_1_n_0\,
      CLR => \^ar\(0),
      D => channel_id(6),
      Q => \^q\(5)
    );
den_o_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EECCFFC822003308"
    )
        port map (
      I0 => \den_o0__0\,
      I1 => \state__0\(3),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => \state__0\(1),
      I5 => \^den_c\,
      O => den_o_i_1_n_0
    );
den_o_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => den_o_reg_0,
      I1 => almost_full,
      O => \den_o0__0\
    );
den_o_reg: unisim.vcomponents.FDCE
     port map (
      C => m_axis_aclk,
      CE => '1',
      CLR => \^ar\(0),
      D => den_o_i_1_n_0,
      Q => \^den_c\
    );
m_axis_tvalid_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fifo_empty,
      O => m_axis_tvalid
    );
valid_data_wren_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFEFE00001000"
    )
        port map (
      I0 => \state__0\(3),
      I1 => \state__0\(2),
      I2 => \state__0\(1),
      I3 => drdy_C,
      I4 => \state__0\(0),
      I5 => valid_data_wren_reg_n_0,
      O => valid_data_wren_i_1_n_0
    );
valid_data_wren_reg: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => m_axis_aclk,
      CE => '1',
      CLR => \^ar\(0),
      D => valid_data_wren_i_1_n_0,
      Q => valid_data_wren_reg_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity xadc_wiz_0_xadc_wiz_0_xadc_core_drp is
  port (
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    busy_out : out STD_LOGIC;
    eoc_out : out STD_LOGIC;
    eos_out : out STD_LOGIC;
    channel_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
    alarm_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    s_axis_aclk : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    vn_in : in STD_LOGIC;
    vp_in : in STD_LOGIC;
    VAUXN : in STD_LOGIC_VECTOR ( 1 downto 0 );
    VAUXP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axis_resetn : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of xadc_wiz_0_xadc_wiz_0_xadc_core_drp : entity is "xadc_wiz_0_xadc_core_drp";
end xadc_wiz_0_xadc_wiz_0_xadc_core_drp;

architecture STRUCTURE of xadc_wiz_0_xadc_wiz_0_xadc_core_drp is
  signal \^channel_out\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal daddr_C : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal den_C : STD_LOGIC;
  signal do_C : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal drdy_C : STD_LOGIC;
  signal \^eoc_out\ : STD_LOGIC;
  signal m_axis_reset : STD_LOGIC;
  signal NLW_XADC_INST_JTAGBUSY_UNCONNECTED : STD_LOGIC;
  signal NLW_XADC_INST_JTAGLOCKED_UNCONNECTED : STD_LOGIC;
  signal NLW_XADC_INST_JTAGMODIFIED_UNCONNECTED : STD_LOGIC;
  signal NLW_XADC_INST_OT_UNCONNECTED : STD_LOGIC;
  signal NLW_XADC_INST_MUXADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  attribute box_type : string;
  attribute box_type of XADC_INST : label is "PRIMITIVE";
begin
  channel_out(4 downto 0) <= \^channel_out\(4 downto 0);
  eoc_out <= \^eoc_out\;
XADC_INST: unisim.vcomponents.XADC
    generic map(
      INIT_40 => X"8000",
      INIT_41 => X"212F",
      INIT_42 => X"0300",
      INIT_43 => X"0000",
      INIT_44 => X"0000",
      INIT_45 => X"0000",
      INIT_46 => X"0000",
      INIT_47 => X"0000",
      INIT_48 => X"0000",
      INIT_49 => X"1010",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4E => X"0000",
      INIT_4F => X"0000",
      INIT_50 => X"B5ED",
      INIT_51 => X"57E4",
      INIT_52 => X"A147",
      INIT_53 => X"CA33",
      INIT_54 => X"A93A",
      INIT_55 => X"52C6",
      INIT_56 => X"9555",
      INIT_57 => X"AE4E",
      INIT_58 => X"5999",
      INIT_59 => X"0000",
      INIT_5A => X"0000",
      INIT_5B => X"0000",
      INIT_5C => X"5111",
      INIT_5D => X"0000",
      INIT_5E => X"0000",
      INIT_5F => X"0000",
      IS_CONVSTCLK_INVERTED => '0',
      IS_DCLK_INVERTED => '0',
      SIM_DEVICE => "7SERIES",
      SIM_MONITOR_FILE => "design.txt"
    )
        port map (
      ALM(7 downto 0) => alarm_out(7 downto 0),
      BUSY => busy_out,
      CHANNEL(4 downto 0) => \^channel_out\(4 downto 0),
      CONVST => '0',
      CONVSTCLK => '0',
      DADDR(6) => daddr_C(6),
      DADDR(5) => '0',
      DADDR(4 downto 0) => daddr_C(4 downto 0),
      DCLK => m_axis_aclk,
      DEN => den_C,
      DI(15 downto 0) => B"0000000000000000",
      DO(15 downto 0) => do_C(15 downto 0),
      DRDY => drdy_C,
      DWE => '0',
      EOC => \^eoc_out\,
      EOS => eos_out,
      JTAGBUSY => NLW_XADC_INST_JTAGBUSY_UNCONNECTED,
      JTAGLOCKED => NLW_XADC_INST_JTAGLOCKED_UNCONNECTED,
      JTAGMODIFIED => NLW_XADC_INST_JTAGMODIFIED_UNCONNECTED,
      MUXADDR(4 downto 0) => NLW_XADC_INST_MUXADDR_UNCONNECTED(4 downto 0),
      OT => NLW_XADC_INST_OT_UNCONNECTED,
      RESET => m_axis_reset,
      VAUXN(15 downto 13) => B"000",
      VAUXN(12) => VAUXN(1),
      VAUXN(11 downto 5) => B"0000000",
      VAUXN(4) => VAUXN(0),
      VAUXN(3 downto 0) => B"0000",
      VAUXP(15 downto 13) => B"000",
      VAUXP(12) => VAUXP(1),
      VAUXP(11 downto 5) => B"0000000",
      VAUXP(4) => VAUXP(0),
      VAUXP(3 downto 0) => B"0000",
      VN => vn_in,
      VP => vp_in
    );
drp_to_axi4stream_inst: entity work.xadc_wiz_0_drp_to_axi4stream
     port map (
      AR(0) => m_axis_reset,
      CHANNEL(4 downto 0) => \^channel_out\(4 downto 0),
      DO(15 downto 0) => do_C(15 downto 0),
      Q(5) => daddr_C(6),
      Q(4 downto 0) => daddr_C(4 downto 0),
      den_C => den_C,
      den_o_reg_0 => \^eoc_out\,
      drdy_C => drdy_C,
      m_axis_aclk => m_axis_aclk,
      m_axis_resetn => m_axis_resetn,
      m_axis_tdata(15 downto 0) => m_axis_tdata(15 downto 0),
      m_axis_tid(4 downto 0) => m_axis_tid(4 downto 0),
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      s_axis_aclk => s_axis_aclk
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity xadc_wiz_0_xadc_wiz_0_axi_xadc is
  port (
    s_axis_aclk : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    m_axis_resetn : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    m_axis_tready : in STD_LOGIC;
    vauxp4 : in STD_LOGIC;
    vauxn4 : in STD_LOGIC;
    vauxp12 : in STD_LOGIC;
    vauxn12 : in STD_LOGIC;
    busy_out : out STD_LOGIC;
    channel_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
    eoc_out : out STD_LOGIC;
    eos_out : out STD_LOGIC;
    alarm_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    vp_in : in STD_LOGIC;
    vn_in : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of xadc_wiz_0_xadc_wiz_0_axi_xadc : entity is "xadc_wiz_0_axi_xadc";
end xadc_wiz_0_xadc_wiz_0_axi_xadc;

architecture STRUCTURE of xadc_wiz_0_xadc_wiz_0_axi_xadc is
begin
AXI_XADC_CORE_I: entity work.xadc_wiz_0_xadc_wiz_0_xadc_core_drp
     port map (
      VAUXN(1) => vauxn12,
      VAUXN(0) => vauxn4,
      VAUXP(1) => vauxp12,
      VAUXP(0) => vauxp4,
      alarm_out(7 downto 0) => alarm_out(7 downto 0),
      busy_out => busy_out,
      channel_out(4 downto 0) => channel_out(4 downto 0),
      eoc_out => eoc_out,
      eos_out => eos_out,
      m_axis_aclk => m_axis_aclk,
      m_axis_resetn => m_axis_resetn,
      m_axis_tdata(15 downto 0) => m_axis_tdata(15 downto 0),
      m_axis_tid(4 downto 0) => m_axis_tid(4 downto 0),
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      s_axis_aclk => s_axis_aclk,
      vn_in => vn_in,
      vp_in => vp_in
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity xadc_wiz_0 is
  port (
    s_axis_aclk : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    m_axis_resetn : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    m_axis_tready : in STD_LOGIC;
    vauxp4 : in STD_LOGIC;
    vauxn4 : in STD_LOGIC;
    vauxp12 : in STD_LOGIC;
    vauxn12 : in STD_LOGIC;
    busy_out : out STD_LOGIC;
    channel_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
    eoc_out : out STD_LOGIC;
    eos_out : out STD_LOGIC;
    alarm_out : out STD_LOGIC;
    vp_in : in STD_LOGIC;
    vn_in : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of xadc_wiz_0 : entity is true;
end xadc_wiz_0;

architecture STRUCTURE of xadc_wiz_0 is
  signal NLW_U0_alarm_out_UNCONNECTED : STD_LOGIC_VECTOR ( 6 downto 0 );
begin
U0: entity work.xadc_wiz_0_xadc_wiz_0_axi_xadc
     port map (
      alarm_out(7) => alarm_out,
      alarm_out(6 downto 0) => NLW_U0_alarm_out_UNCONNECTED(6 downto 0),
      busy_out => busy_out,
      channel_out(4 downto 0) => channel_out(4 downto 0),
      eoc_out => eoc_out,
      eos_out => eos_out,
      m_axis_aclk => m_axis_aclk,
      m_axis_resetn => m_axis_resetn,
      m_axis_tdata(15 downto 0) => m_axis_tdata(15 downto 0),
      m_axis_tid(4 downto 0) => m_axis_tid(4 downto 0),
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      s_axis_aclk => s_axis_aclk,
      vauxn12 => vauxn12,
      vauxn4 => vauxn4,
      vauxp12 => vauxp12,
      vauxp4 => vauxp4,
      vn_in => vn_in,
      vp_in => vp_in
    );
end STRUCTURE;
