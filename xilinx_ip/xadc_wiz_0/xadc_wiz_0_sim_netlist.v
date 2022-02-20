// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sun Mar 15 14:38:16 2020
// Host        : DESKTOP-FH2NF4G running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/xilinx_ip/xadc_wiz_0/xadc_wiz_0_sim_netlist.v
// Design      : xadc_wiz_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a15tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* NotValidForBitStream *)
module xadc_wiz_0
   (s_axis_aclk,
    m_axis_aclk,
    m_axis_resetn,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tid,
    m_axis_tready,
    vauxp4,
    vauxn4,
    vauxp12,
    vauxn12,
    busy_out,
    channel_out,
    eoc_out,
    eos_out,
    alarm_out,
    vp_in,
    vn_in);
  input s_axis_aclk;
  input m_axis_aclk;
  input m_axis_resetn;
  output [15:0]m_axis_tdata;
  output m_axis_tvalid;
  output [4:0]m_axis_tid;
  input m_axis_tready;
  input vauxp4;
  input vauxn4;
  input vauxp12;
  input vauxn12;
  output busy_out;
  output [4:0]channel_out;
  output eoc_out;
  output eos_out;
  output alarm_out;
  input vp_in;
  input vn_in;

  wire alarm_out;
  wire busy_out;
  wire [4:0]channel_out;
  wire eoc_out;
  wire eos_out;
  wire m_axis_aclk;
  wire m_axis_resetn;
  wire [15:0]m_axis_tdata;
  wire [4:0]m_axis_tid;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire s_axis_aclk;
  wire vauxn12;
  wire vauxn4;
  wire vauxp12;
  wire vauxp4;
  wire vn_in;
  wire vp_in;
  wire [6:0]NLW_U0_alarm_out_UNCONNECTED;

  xadc_wiz_0_xadc_wiz_0_axi_xadc U0
       (.alarm_out({alarm_out,NLW_U0_alarm_out_UNCONNECTED[6:0]}),
        .busy_out(busy_out),
        .channel_out(channel_out),
        .eoc_out(eoc_out),
        .eos_out(eos_out),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_resetn(m_axis_resetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tid(m_axis_tid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_aclk(s_axis_aclk),
        .vauxn12(vauxn12),
        .vauxn4(vauxn4),
        .vauxp12(vauxp12),
        .vauxp4(vauxp4),
        .vn_in(vn_in),
        .vp_in(vp_in));
endmodule

(* ORIG_REF_NAME = "drp_to_axi4stream" *) 
module xadc_wiz_0_drp_to_axi4stream
   (m_axis_tdata,
    AR,
    m_axis_tid,
    Q,
    den_C,
    m_axis_tvalid,
    s_axis_aclk,
    m_axis_aclk,
    DO,
    m_axis_tready,
    m_axis_resetn,
    drdy_C,
    CHANNEL,
    den_o_reg_0);
  output [15:0]m_axis_tdata;
  output [0:0]AR;
  output [4:0]m_axis_tid;
  output [5:0]Q;
  output den_C;
  output m_axis_tvalid;
  input s_axis_aclk;
  input m_axis_aclk;
  input [15:0]DO;
  input m_axis_tready;
  input m_axis_resetn;
  input drdy_C;
  input [4:0]CHANNEL;
  input den_o_reg_0;

  wire [0:0]AR;
  wire [4:0]CHANNEL;
  wire [15:0]DO;
  wire FIFO18E1_inst_data_i_1_n_0;
  wire \FSM_sequential_state[2]_i_2_n_0 ;
  wire \FSM_sequential_state[3]_i_1_n_0 ;
  wire [5:0]Q;
  wire almost_full;
  wire busy_o0__0;
  wire [6:0]channel_id;
  wire \channel_id[6]_i_1_n_0 ;
  wire den_C;
  wire den_o0__0;
  wire den_o_i_1_n_0;
  wire den_o_reg_0;
  wire drdy_C;
  wire fifo_empty;
  wire m_axis_aclk;
  wire m_axis_resetn;
  wire [15:0]m_axis_tdata;
  wire [4:0]m_axis_tid;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire s_axis_aclk;
  wire [3:0]state__0;
  wire [3:0]state__1;
  wire valid_data_wren_i_1_n_0;
  wire valid_data_wren_reg_n_0;
  wire wren_fifo;
  wire NLW_FIFO18E1_inst_data_ALMOSTEMPTY_UNCONNECTED;
  wire NLW_FIFO18E1_inst_data_FULL_UNCONNECTED;
  wire NLW_FIFO18E1_inst_data_RDERR_UNCONNECTED;
  wire NLW_FIFO18E1_inst_data_WRERR_UNCONNECTED;
  wire [31:16]NLW_FIFO18E1_inst_data_DO_UNCONNECTED;
  wire [3:0]NLW_FIFO18E1_inst_data_DOP_UNCONNECTED;
  wire [11:0]NLW_FIFO18E1_inst_data_RDCOUNT_UNCONNECTED;
  wire [11:0]NLW_FIFO18E1_inst_data_WRCOUNT_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_ALMOSTEMPTY_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_ALMOSTFULL_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_EMPTY_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_FULL_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_RDERR_UNCONNECTED;
  wire NLW_FIFO18E1_inst_tid_WRERR_UNCONNECTED;
  wire [31:5]NLW_FIFO18E1_inst_tid_DO_UNCONNECTED;
  wire [3:0]NLW_FIFO18E1_inst_tid_DOP_UNCONNECTED;
  wire [11:0]NLW_FIFO18E1_inst_tid_RDCOUNT_UNCONNECTED;
  wire [11:0]NLW_FIFO18E1_inst_tid_WRCOUNT_UNCONNECTED;

  (* box_type = "PRIMITIVE" *) 
  FIFO18E1 #(
    .ALMOST_EMPTY_OFFSET(13'h0006),
    .ALMOST_FULL_OFFSET(13'h03F9),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO18"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(36'h000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(36'h000000000)) 
    FIFO18E1_inst_data
       (.ALMOSTEMPTY(NLW_FIFO18E1_inst_data_ALMOSTEMPTY_UNCONNECTED),
        .ALMOSTFULL(almost_full),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,DO}),
        .DIP({1'b0,1'b0,1'b0,1'b0}),
        .DO({NLW_FIFO18E1_inst_data_DO_UNCONNECTED[31:16],m_axis_tdata}),
        .DOP(NLW_FIFO18E1_inst_data_DOP_UNCONNECTED[3:0]),
        .EMPTY(fifo_empty),
        .FULL(NLW_FIFO18E1_inst_data_FULL_UNCONNECTED),
        .RDCLK(s_axis_aclk),
        .RDCOUNT(NLW_FIFO18E1_inst_data_RDCOUNT_UNCONNECTED[11:0]),
        .RDEN(FIFO18E1_inst_data_i_1_n_0),
        .RDERR(NLW_FIFO18E1_inst_data_RDERR_UNCONNECTED),
        .REGCE(1'b1),
        .RST(AR),
        .RSTREG(1'b0),
        .WRCLK(m_axis_aclk),
        .WRCOUNT(NLW_FIFO18E1_inst_data_WRCOUNT_UNCONNECTED[11:0]),
        .WREN(wren_fifo),
        .WRERR(NLW_FIFO18E1_inst_data_WRERR_UNCONNECTED));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h2)) 
    FIFO18E1_inst_data_i_1
       (.I0(m_axis_tready),
        .I1(fifo_empty),
        .O(FIFO18E1_inst_data_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    FIFO18E1_inst_data_i_2
       (.I0(m_axis_resetn),
        .O(AR));
  LUT2 #(
    .INIT(4'h8)) 
    FIFO18E1_inst_data_i_3
       (.I0(drdy_C),
        .I1(valid_data_wren_reg_n_0),
        .O(wren_fifo));
  (* box_type = "PRIMITIVE" *) 
  FIFO18E1 #(
    .ALMOST_EMPTY_OFFSET(13'h0006),
    .ALMOST_FULL_OFFSET(13'h03F9),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO18"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(36'h000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(36'h000000000)) 
    FIFO18E1_inst_tid
       (.ALMOSTEMPTY(NLW_FIFO18E1_inst_tid_ALMOSTEMPTY_UNCONNECTED),
        .ALMOSTFULL(NLW_FIFO18E1_inst_tid_ALMOSTFULL_UNCONNECTED),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,Q[5],1'b0,Q[4:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0}),
        .DO({NLW_FIFO18E1_inst_tid_DO_UNCONNECTED[31:5],m_axis_tid}),
        .DOP(NLW_FIFO18E1_inst_tid_DOP_UNCONNECTED[3:0]),
        .EMPTY(NLW_FIFO18E1_inst_tid_EMPTY_UNCONNECTED),
        .FULL(NLW_FIFO18E1_inst_tid_FULL_UNCONNECTED),
        .RDCLK(s_axis_aclk),
        .RDCOUNT(NLW_FIFO18E1_inst_tid_RDCOUNT_UNCONNECTED[11:0]),
        .RDEN(FIFO18E1_inst_data_i_1_n_0),
        .RDERR(NLW_FIFO18E1_inst_tid_RDERR_UNCONNECTED),
        .REGCE(1'b1),
        .RST(AR),
        .RSTREG(1'b0),
        .WRCLK(m_axis_aclk),
        .WRCOUNT(NLW_FIFO18E1_inst_tid_WRCOUNT_UNCONNECTED[11:0]),
        .WREN(wren_fifo),
        .WRERR(NLW_FIFO18E1_inst_tid_WRERR_UNCONNECTED));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h51555551)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(state__0[0]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(DO[15]),
        .I4(DO[14]),
        .O(state__1[0]));
  LUT5 #(
    .INIT(32'h00FFBE00)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(state__0[2]),
        .I1(DO[15]),
        .I2(DO[14]),
        .I3(state__0[1]),
        .I4(state__0[0]),
        .O(state__1[1]));
  LUT3 #(
    .INIT(8'h60)) 
    \FSM_sequential_state[2]_i_1 
       (.I0(state__0[1]),
        .I1(state__0[2]),
        .I2(\FSM_sequential_state[2]_i_2_n_0 ),
        .O(state__1[2]));
  LUT6 #(
    .INIT(64'hF4040404FFFFFFFF)) 
    \FSM_sequential_state[2]_i_2 
       (.I0(DO[14]),
        .I1(DO[15]),
        .I2(state__0[0]),
        .I3(CHANNEL[4]),
        .I4(den_o_reg_0),
        .I5(state__0[1]),
        .O(\FSM_sequential_state[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h1055555510550011)) 
    \FSM_sequential_state[3]_i_1 
       (.I0(state__0[3]),
        .I1(state__0[2]),
        .I2(busy_o0__0),
        .I3(state__0[1]),
        .I4(state__0[0]),
        .I5(drdy_C),
        .O(\FSM_sequential_state[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00002002)) 
    \FSM_sequential_state[3]_i_2 
       (.I0(state__0[1]),
        .I1(state__0[2]),
        .I2(DO[15]),
        .I3(DO[14]),
        .I4(state__0[0]),
        .O(state__1[3]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_sequential_state[3]_i_3 
       (.I0(den_o_reg_0),
        .I1(CHANNEL[4]),
        .O(busy_o0__0));
  (* FSM_ENCODED_STATES = "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011" *) 
  FDCE \FSM_sequential_state_reg[0] 
       (.C(m_axis_aclk),
        .CE(\FSM_sequential_state[3]_i_1_n_0 ),
        .CLR(AR),
        .D(state__1[0]),
        .Q(state__0[0]));
  (* FSM_ENCODED_STATES = "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011" *) 
  FDCE \FSM_sequential_state_reg[1] 
       (.C(m_axis_aclk),
        .CE(\FSM_sequential_state[3]_i_1_n_0 ),
        .CLR(AR),
        .D(state__1[1]),
        .Q(state__0[1]));
  (* FSM_ENCODED_STATES = "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011" *) 
  FDCE \FSM_sequential_state_reg[2] 
       (.C(m_axis_aclk),
        .CE(\FSM_sequential_state[3]_i_1_n_0 ),
        .CLR(AR),
        .D(state__1[2]),
        .Q(state__0[2]));
  (* FSM_ENCODED_STATES = "wait_ind_adc:0111,wait_mode_change:0000,wait_seq_s_ch:1000,rd_ctrl_reg_41:0010,rd_en_ctrl_reg_41:0001,rd_b_reg_cmd:0101,rd_a_reg:0100,rd_b_reg:0110,wait_sim_samp:0011" *) 
  FDCE \FSM_sequential_state_reg[3] 
       (.C(m_axis_aclk),
        .CE(\FSM_sequential_state[3]_i_1_n_0 ),
        .CLR(AR),
        .D(state__1[3]),
        .Q(state__0[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h30303171)) 
    \channel_id[0]_i_1 
       (.I0(state__0[1]),
        .I1(state__0[3]),
        .I2(CHANNEL[0]),
        .I3(state__0[0]),
        .I4(state__0[2]),
        .O(channel_id[0]));
  LUT5 #(
    .INIT(32'h32003700)) 
    \channel_id[1]_i_1 
       (.I0(state__0[1]),
        .I1(state__0[3]),
        .I2(state__0[2]),
        .I3(CHANNEL[1]),
        .I4(state__0[0]),
        .O(channel_id[1]));
  LUT5 #(
    .INIT(32'h32003700)) 
    \channel_id[2]_i_1 
       (.I0(state__0[1]),
        .I1(state__0[3]),
        .I2(state__0[2]),
        .I3(CHANNEL[2]),
        .I4(state__0[0]),
        .O(channel_id[2]));
  LUT5 #(
    .INIT(32'h22102710)) 
    \channel_id[3]_i_1 
       (.I0(state__0[1]),
        .I1(state__0[3]),
        .I2(state__0[2]),
        .I3(CHANNEL[3]),
        .I4(state__0[0]),
        .O(channel_id[3]));
  LUT6 #(
    .INIT(64'h0B0A04000B5F0400)) 
    \channel_id[4]_i_1 
       (.I0(state__0[1]),
        .I1(CHANNEL[3]),
        .I2(state__0[3]),
        .I3(state__0[2]),
        .I4(CHANNEL[4]),
        .I5(state__0[0]),
        .O(channel_id[4]));
  LUT4 #(
    .INIT(16'h2226)) 
    \channel_id[6]_i_1 
       (.I0(state__0[0]),
        .I1(state__0[3]),
        .I2(state__0[1]),
        .I3(state__0[2]),
        .O(\channel_id[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \channel_id[6]_i_2 
       (.I0(state__0[3]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .O(channel_id[6]));
  FDCE \channel_id_reg[0] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[0]),
        .Q(Q[0]));
  FDCE \channel_id_reg[1] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[1]),
        .Q(Q[1]));
  FDCE \channel_id_reg[2] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[2]),
        .Q(Q[2]));
  FDCE \channel_id_reg[3] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[3]),
        .Q(Q[3]));
  FDCE \channel_id_reg[4] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[4]),
        .Q(Q[4]));
  FDCE \channel_id_reg[6] 
       (.C(m_axis_aclk),
        .CE(\channel_id[6]_i_1_n_0 ),
        .CLR(AR),
        .D(channel_id[6]),
        .Q(Q[5]));
  LUT6 #(
    .INIT(64'hEECCFFC822003308)) 
    den_o_i_1
       (.I0(den_o0__0),
        .I1(state__0[3]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(state__0[1]),
        .I5(den_C),
        .O(den_o_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h2)) 
    den_o_i_2
       (.I0(den_o_reg_0),
        .I1(almost_full),
        .O(den_o0__0));
  FDCE den_o_reg
       (.C(m_axis_aclk),
        .CE(1'b1),
        .CLR(AR),
        .D(den_o_i_1_n_0),
        .Q(den_C));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT1 #(
    .INIT(2'h1)) 
    m_axis_tvalid_INST_0
       (.I0(fifo_empty),
        .O(m_axis_tvalid));
  LUT6 #(
    .INIT(64'hFFFFFEFE00001000)) 
    valid_data_wren_i_1
       (.I0(state__0[3]),
        .I1(state__0[2]),
        .I2(state__0[1]),
        .I3(drdy_C),
        .I4(state__0[0]),
        .I5(valid_data_wren_reg_n_0),
        .O(valid_data_wren_i_1_n_0));
  FDCE #(
    .INIT(1'b0)) 
    valid_data_wren_reg
       (.C(m_axis_aclk),
        .CE(1'b1),
        .CLR(AR),
        .D(valid_data_wren_i_1_n_0),
        .Q(valid_data_wren_reg_n_0));
endmodule

(* ORIG_REF_NAME = "xadc_wiz_0_axi_xadc" *) 
module xadc_wiz_0_xadc_wiz_0_axi_xadc
   (s_axis_aclk,
    m_axis_aclk,
    m_axis_resetn,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tid,
    m_axis_tready,
    vauxp4,
    vauxn4,
    vauxp12,
    vauxn12,
    busy_out,
    channel_out,
    eoc_out,
    eos_out,
    alarm_out,
    vp_in,
    vn_in);
  input s_axis_aclk;
  input m_axis_aclk;
  input m_axis_resetn;
  output [15:0]m_axis_tdata;
  output m_axis_tvalid;
  output [4:0]m_axis_tid;
  input m_axis_tready;
  input vauxp4;
  input vauxn4;
  input vauxp12;
  input vauxn12;
  output busy_out;
  output [4:0]channel_out;
  output eoc_out;
  output eos_out;
  output [7:0]alarm_out;
  input vp_in;
  input vn_in;

  wire [7:0]alarm_out;
  wire busy_out;
  wire [4:0]channel_out;
  wire eoc_out;
  wire eos_out;
  wire m_axis_aclk;
  wire m_axis_resetn;
  wire [15:0]m_axis_tdata;
  wire [4:0]m_axis_tid;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire s_axis_aclk;
  wire vauxn12;
  wire vauxn4;
  wire vauxp12;
  wire vauxp4;
  wire vn_in;
  wire vp_in;

  xadc_wiz_0_xadc_wiz_0_xadc_core_drp AXI_XADC_CORE_I
       (.VAUXN({vauxn12,vauxn4}),
        .VAUXP({vauxp12,vauxp4}),
        .alarm_out(alarm_out),
        .busy_out(busy_out),
        .channel_out(channel_out),
        .eoc_out(eoc_out),
        .eos_out(eos_out),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_resetn(m_axis_resetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tid(m_axis_tid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_aclk(s_axis_aclk),
        .vn_in(vn_in),
        .vp_in(vp_in));
endmodule

(* ORIG_REF_NAME = "xadc_wiz_0_xadc_core_drp" *) 
module xadc_wiz_0_xadc_wiz_0_xadc_core_drp
   (m_axis_tdata,
    m_axis_tid,
    busy_out,
    eoc_out,
    eos_out,
    channel_out,
    alarm_out,
    m_axis_tvalid,
    m_axis_tready,
    s_axis_aclk,
    m_axis_aclk,
    vn_in,
    vp_in,
    VAUXN,
    VAUXP,
    m_axis_resetn);
  output [15:0]m_axis_tdata;
  output [4:0]m_axis_tid;
  output busy_out;
  output eoc_out;
  output eos_out;
  output [4:0]channel_out;
  output [7:0]alarm_out;
  output m_axis_tvalid;
  input m_axis_tready;
  input s_axis_aclk;
  input m_axis_aclk;
  input vn_in;
  input vp_in;
  input [1:0]VAUXN;
  input [1:0]VAUXP;
  input m_axis_resetn;

  wire [1:0]VAUXN;
  wire [1:0]VAUXP;
  wire [7:0]alarm_out;
  wire busy_out;
  wire [4:0]channel_out;
  wire [6:0]daddr_C;
  wire den_C;
  wire [15:0]do_C;
  wire drdy_C;
  wire eoc_out;
  wire eos_out;
  wire m_axis_aclk;
  wire m_axis_reset;
  wire m_axis_resetn;
  wire [15:0]m_axis_tdata;
  wire [4:0]m_axis_tid;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire s_axis_aclk;
  wire vn_in;
  wire vp_in;
  wire NLW_XADC_INST_JTAGBUSY_UNCONNECTED;
  wire NLW_XADC_INST_JTAGLOCKED_UNCONNECTED;
  wire NLW_XADC_INST_JTAGMODIFIED_UNCONNECTED;
  wire NLW_XADC_INST_OT_UNCONNECTED;
  wire [4:0]NLW_XADC_INST_MUXADDR_UNCONNECTED;

  (* box_type = "PRIMITIVE" *) 
  XADC #(
    .INIT_40(16'h8000),
    .INIT_41(16'h212F),
    .INIT_42(16'h0300),
    .INIT_43(16'h0000),
    .INIT_44(16'h0000),
    .INIT_45(16'h0000),
    .INIT_46(16'h0000),
    .INIT_47(16'h0000),
    .INIT_48(16'h0000),
    .INIT_49(16'h1010),
    .INIT_4A(16'h0000),
    .INIT_4B(16'h0000),
    .INIT_4C(16'h0000),
    .INIT_4D(16'h0000),
    .INIT_4E(16'h0000),
    .INIT_4F(16'h0000),
    .INIT_50(16'hB5ED),
    .INIT_51(16'h57E4),
    .INIT_52(16'hA147),
    .INIT_53(16'hCA33),
    .INIT_54(16'hA93A),
    .INIT_55(16'h52C6),
    .INIT_56(16'h9555),
    .INIT_57(16'hAE4E),
    .INIT_58(16'h5999),
    .INIT_59(16'h0000),
    .INIT_5A(16'h0000),
    .INIT_5B(16'h0000),
    .INIT_5C(16'h5111),
    .INIT_5D(16'h0000),
    .INIT_5E(16'h0000),
    .INIT_5F(16'h0000),
    .IS_CONVSTCLK_INVERTED(1'b0),
    .IS_DCLK_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SIM_MONITOR_FILE("design.txt")) 
    XADC_INST
       (.ALM(alarm_out),
        .BUSY(busy_out),
        .CHANNEL(channel_out),
        .CONVST(1'b0),
        .CONVSTCLK(1'b0),
        .DADDR({daddr_C[6],1'b0,daddr_C[4:0]}),
        .DCLK(m_axis_aclk),
        .DEN(den_C),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DO(do_C),
        .DRDY(drdy_C),
        .DWE(1'b0),
        .EOC(eoc_out),
        .EOS(eos_out),
        .JTAGBUSY(NLW_XADC_INST_JTAGBUSY_UNCONNECTED),
        .JTAGLOCKED(NLW_XADC_INST_JTAGLOCKED_UNCONNECTED),
        .JTAGMODIFIED(NLW_XADC_INST_JTAGMODIFIED_UNCONNECTED),
        .MUXADDR(NLW_XADC_INST_MUXADDR_UNCONNECTED[4:0]),
        .OT(NLW_XADC_INST_OT_UNCONNECTED),
        .RESET(m_axis_reset),
        .VAUXN({1'b0,1'b0,1'b0,VAUXN[1],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,VAUXN[0],1'b0,1'b0,1'b0,1'b0}),
        .VAUXP({1'b0,1'b0,1'b0,VAUXP[1],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,VAUXP[0],1'b0,1'b0,1'b0,1'b0}),
        .VN(vn_in),
        .VP(vp_in));
  xadc_wiz_0_drp_to_axi4stream drp_to_axi4stream_inst
       (.AR(m_axis_reset),
        .CHANNEL(channel_out),
        .DO(do_C),
        .Q({daddr_C[6],daddr_C[4:0]}),
        .den_C(den_C),
        .den_o_reg_0(eoc_out),
        .drdy_C(drdy_C),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_resetn(m_axis_resetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tid(m_axis_tid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_aclk(s_axis_aclk));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
