-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

  library unisim;
  use unisim.vcomponents.all;

entity top is
	port(
    	clk12M : in std_logic;
    	rst : in std_logic;
    	
		adc_mclk : out std_logic;
		adc_lrclk : out std_logic;
		adc_sclk : out std_logic;
			
		dac_mclk : out std_logic;
		dac_lrclk : out std_logic;
		dac_sclk : out std_logic;

		sdin : in std_logic;
		sdout : out std_logic;

		buf_finished : out std_logic;
		fft_finished : out std_logic;
		mag_finished : out std_logic;
		screen_done : out std_logic;
		
		lcd_rst : out std_logic;
		lcd_wr  : out std_logic;
		lcd_cs  : out std_logic;
		lcd_rs  : out std_logic;
		lcd_db  : out std_logic_vector(15 downto 0)
		
        );
end top;

architecture str of top is 
	
	constant stereo_order : integer := 9;
	constant mono_order   : integer := 8;
	
	constant dwn_order : integer := 4;
	constant dwn_factor : integer := 16;
	
	constant low_ov_input_order : integer := 4;
	constant low_ov_output_order : integer := 10;
	constant low_ov_recordnum   : integer := 3;
	
	constant high_ov_input_order : integer := 8;
	constant high_ov_output_order : integer := 10;
	constant high_ov_recordnum : integer := 3;

	
	constant order : integer := 10;
	constant binorder : integer := 6;
	constant numbins : integer := 48;
	
	constant totalbinorder : integer := 7;
	constant totalbins : integer := 2*numbins;
	
	signal upstream_sel : std_logic := '0';
	signal dwnstream_sel : std_logic := '0';
	
	signal high_cqt_ov_start : std_logic := '0';
	signal high_cqt_ov_start_dly : std_logic := '0';
	
	signal low_cqt_ov_full : std_logic := '0';
	signal high_cqt_ov_full : std_logic := '0';
	
	signal mono_full_dly : std_logic := '0';
	
	signal low_cqt_dwn_en : std_logic := '0';
	signal low_cqt_dwn_addr : unsigned(mono_order - 1 downto 0) := (others => '0');
	
	signal high_cqt_ov_en : std_logic := '0';
	signal high_cqt_ov_addr : unsigned(mono_order - 1 downto 0) := (others => '0');
	
	signal low_cqt_ov_read_en : std_logic := '0';
	signal high_cqt_ov_read_en : std_logic := '0';
	signal low_cqt_ov_data : signed(31 downto 0) := (others => '0');
	signal high_cqt_ov_data : signed(31 downto 0) := (others => '0');
	
	signal high_cqt_ov_full_reg : std_logic := '0';
	signal high_cqt_ov_full_pulse : std_logic := '0';
	
	signal cqt_done_reg : std_logic := '0';
	signal high_cqt_ov_full_pulse_dly : std_logic := '0';

	signal mag_start : std_logic := '0';
	
	signal low_ov_read_done : std_logic := '0';
	signal high_ov_read_done : std_logic := '0';
	
	signal bin_en : std_logic := '0';
	signal bin_addr : unsigned(totalbinorder - 1 downto 0) := (others => '0');
	signal bin_data : signed(63 downto 0) := (others => '0');
	
    signal mclk_int : std_logic;
    signal lrclk_int : std_logic;
    signal sclk_int : std_logic;
    
	signal sound_rec : signed(23 downto 0) := (others => '0');
	signal sound_tra : signed(23 downto 0) := (others => '0');
	signal stb : std_logic := '0';
	
	signal stereo_full : std_logic := '0';
	signal mono_full : std_logic := '0';
	
	signal stereo_en : std_logic := '0';
	signal stereo_wr : std_logic := '0';
	signal stereo_addr : unsigned(stereo_order-1 downto 0) := (others => '0');
	signal stereo_data : signed(23 downto 0) := (others => '0');
	signal mono_data : signed(23 downto 0) := (others => '0');
	
	signal clock_fb : std_logic := '0';
	
	
	signal clk_int : std_logic := '0';

	signal lcd_clk : std_logic := '0';
	
	signal fft_done : std_logic := '0';
	signal mag_done : std_logic := '0';
	
	signal fft_clk : std_logic := '0';
	signal fft_read_en : std_logic := '0';
	signal fft_read_addr : unsigned(order-1 downto 0) := (others => '0');
	signal fft_read_data : signed(31 downto 0) := (others => '0');
	
	signal full_buffer_dfs1 : std_logic := '0';
	signal full_buffer_dfs2 : std_logic := '0';
	
	signal fft_write_q : signed(31 downto 0) := (others => '0');
	signal fft_write_i : signed(31 downto 0) := (others => '0');
	signal fft_write_en : std_logic := '0';
	signal fft_write_addr : unsigned(order-1 downto 0) := (others => '0');
	
	signal fft_en : std_logic := '0';
	signal temp : std_logic := '0';
	
	signal rect_ready : std_logic := '0';
	signal rect_valid : std_logic := '0';
	
	signal pix_addr : unsigned(totalbinorder-1 downto 0) := (others => '0');
	signal pix_data : unsigned(31 downto 0) := (others => '0');
	signal pix_en : std_logic := '0';
	
	signal col_sta : std_logic_vector(9 downto 0) := (others => '0');
	signal col_end : std_logic_vector(9 downto 0) := (others => '0');
	signal row_sta : std_logic_vector(8 downto 0) := (others => '0');
	signal row_end : std_logic_vector(8 downto 0) := (others => '0');
	signal pixel : std_logic_vector(15 downto 0) := (others => '0');
	
	signal screen_done_t : std_logic := '0';
	
	signal blank_check : std_logic := '0';
	signal blank_check_dly : std_logic := '0';
	signal blank_check_dly2 : std_logic := '0';
			
	signal blank_done : std_logic := '0';
	
	signal mag_done_latch : std_logic := '0';

	signal max_bin_t : unsigned(6 downto 0) := (others => '0');
	
	signal fft_win_addr : unsigned(order-1 downto 0) := (others => '0');
	signal fft_win_en : std_logic := '0';
	signal windowed_data : signed(23 downto 0) := (others => '0');
	
	signal fft_start : std_logic := '0';

	signal mono_addr : unsigned(mono_order-1 downto 0) := (others => '0');
	signal mono_en : std_logic := '0';
	signal ov_data : signed(31 downto 0) := (others => '0');
	signal ov_en : std_logic := '0';
	signal ov_addr : unsigned(9 downto 0) := (others => '0');
	signal ov_full : std_logic := '0';
	
	
	signal kernel_ready : std_logic := '0';
	signal kernel_load : std_Logic := '0';
	signal cqt_input : signed(63 downto 0) := (others => '0');
	
	signal cqt_read_en : std_logic := '0';
	signal cqt_read_addr : unsigned(binorder - 1 downto 0) := (others => '0');
	
	signal cqt_done : std_logic := '0';
	
	signal cqt_read_data : signed(63 downto 0) := (others => '0');
	
	
	signal fft_load : std_logic := '0';
	signal fft_busy : std_logic := '0';
	
	signal mag_load : std_logic := '0';
	
	signal downsample_full : std_logic := '0';
	
	signal mono_data_ext : signed(31 downto 0) := (others => '0');
	
	signal dwn_en : std_logic := '0';
	signal dwn_addr : unsigned(dwn_order-1 downto 0) := (others => '0');
	signal dwn_data : signed(31 downto 0) := (others => '0');
	
	signal fft_zpd_data : signed(31 downto 0) := (others => '0');
	signal fft_zpd_addr : unsigned(11 downto 0) := (others => '0');
	
	signal read_start : std_logic := '0';
	signal read_en : std_logic := '0';
	signal read_addr : unsigned(order -1 downto 0) := (others => '0');
	
	signal cqt_en : std_logic := '0';
	signal cqt_addr : unsigned(order-1 downto 0) := (others => '0');
	signal cqt_data : signed(63 downto 0) := (others => '0');
	
	signal out_en : std_logic := '0';
	signal qdata_wr : signed(31 downto 0) := (others => '0');
	signal idata_wr : signed(31 downto 0) := (others => '0');
	
	signal mag_q_scaled : signed(31 downto 0) := (others => '0');
	signal mag_i_scaled : signed(31 downto 0) := (others => '0');
	
	signal rect_valid_dfs1 : std_logic := '0';
	signal rect_valid_dfs2 : std_logic := '0';
	
	signal rect_ready_dfs1 : std_logic := '0';
	signal rect_ready_dfs2 : std_logic := '0';
	
	signal rot_count : integer := 0;
	
	
	signal rot_count_dfs1 : integer := 0;
	signal rot_count_dfs2 : integer := 0;
	
begin
        
    adc_mclk <= mclk_int;
    adc_lrclk <= lrclk_int;
    adc_sclk <= sclk_int;
    
    dac_mclk <= mclk_int;
    dac_lrclk <= lrclk_int;
    dac_sclk <= sclk_int;

    i2s_master_inst : entity work.i2s_master
    port map(
		mclk_i => mclk_int,
		sclk_o => sclk_int,
		lrclk_o => lrclk_int,
		sd_i => sdin,
		sd_o => sdout,
		
		rec_reg_o => sound_rec,
		tra_reg_i => sound_tra,
		
		stb_o => stb
		
   
    );
   
	pingpong : entity work.i2s_stereo_pingpong 
	generic map(
		buffersizelog2 => stereo_order
	)
	port map(
		rst_i => rst,
    	sclk_i => sclk_int,
		lrclk_i => lrclk_int,
		rec_reg_i => sound_rec,
		tra_reg_o => sound_tra,
		stb_i => stb,
		full_o => stereo_full,
		proc_clk_i => fft_clk,
		proc_en_i => stereo_en,
		proc_wr_i => '0',
		proc_addr_i => stereo_addr,
		proc_data_i => x"000000",
		proc_data_o => stereo_data
		);
		
	--sclk -> fft_clk domain
	process(fft_clk)
	begin
		
		if(fft_clk'event and fft_clk = '1') then
		
			full_buffer_dfs1 <= stereo_full;
			full_buffer_dfs2 <= full_buffer_dfs1;
		
		end if;
	
	end process;
		
	mono : entity work.i2s_stereo2mono
	generic map(
		stereobuffersizelog2 => stereo_order,
		monobuffersizelog2 => mono_order
	)
	port map(
		clk_i => fft_clk,
		full_i => full_buffer_dfs2,
		full_o => mono_full,
		en_o => stereo_en,
		addr_o => stereo_addr,
		stereo_data_i => stereo_data,
		en_i => mono_en,
		addr_i => mono_addr,
		mono_data_o => mono_data
	
	);

	process(mono_data)
	begin
		for i in 1 to 8 loop
			mono_data_ext(23+i) <= mono_data(23);
		end loop;
			mono_data_ext(23 downto 0) <= mono_data;
	end process;

	
	dual_cqt_inst : entity work.dual_cqt 
	port map(
			clk => fft_clk,

			full_i => mono_full,
			full_o => mag_start,
			
			en_o => mono_en,
			addr_o => mono_addr,
			data_i => mono_data_ext,
			
			en_i => bin_en,
			addr_i => bin_addr,
			data_o => bin_data

			);

	
	--divide by input length
	process(bin_data)
	begin
		--10 is 2**10 for divide by 1024
		for i in 1 to order loop
			mag_q_scaled(32 - i) <= bin_data(63);
			mag_i_scaled(32 - i) <= bin_data(31);
		end loop;
		
		mag_q_scaled(31 - order downto 0) <= bin_data(63 downto 32+order);
		mag_i_scaled(31 - order downto 0) <= bin_data(31 downto 0+order);
	end process;
	
	MAG : entity work.fft_mag
	generic map(
		order => totalbinorder
	)
	port map(
		clk => fft_clk,
		fft_done => mag_start,
		mag_done => mag_done,
		mag_load => open,
		max_bin => open,
		max_freq => open,
		in_qdata => mag_q_scaled, --scaling by input length
		in_idata => mag_i_scaled, --scaling by input length
		in_addr => bin_addr,
		in_en => bin_en,
		in_wr => open,
		out_data => pix_data,
		out_addr => pix_addr,
		out_en => pix_en
		
	);
	
	mag_finished <= mag_done;
	fft_finished <= mag_start;
	buf_finished <= mono_full;
	
	screen_done <= screen_done_t;
	
	-- COLOR_ROT : entity work.rotary_encoder
	-- generic map(
		-- top => 80-1,
		-- bottom => 0,
		-- tick => 1
	-- )
	-- port map(
		-- clk => lcd_clk,
		-- a => rot_a,
		-- b => rot_b,
		-- count => open,
		-- count_sat => open
	-- );
	
	-- rot_val <= to_unsigned(rot_count, 4);
	
	-- process(fft_clk)
	-- begin
		-- if(fft_clk'event and fft_clk = '1') then
			
			-- rot_count_dfs1 <= rot_count;
			-- rot_count_dfs2 <= rot_count_dfs1;
			
		-- end if;
	-- end process;
	
	BAND_DRAWWER : entity work.cqt_bin_displayer
	generic map(
		binorder => totalbinorder,
		bins => totalbins,
		colorLUTfile => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/colorLUT.data",
		bin_width => 7
	)
	port map(
	
		clk => fft_clk,
		rst => rst,
		
		mag_done => mag_done,
		color_offset => 0,
		rect_valid => rect_valid,
		rect_ready => rect_ready_dfs2,
		
		screen_done => screen_done_t,
		
		addr => pix_addr,
		en   => pix_en,
		fft_data => pix_data,
		
		column_sta => col_sta,
		column_end => col_end,
		row_sta => row_sta,
		row_end => row_end,
		
		pixel => pixel
	
	);
	
	process(fft_clk)
	begin
		if(fft_clk'event and fft_clk = '1') then
			rect_valid_dfs1 <= rect_valid;
			rect_valid_dfs2 <= rect_valid_dfs1;
		end if;
	end process;
	
	process(lcd_clk)
	begin
		if(lcd_clk'event and lcd_clk = '1') then
			rect_ready_dfs1 <= rect_ready;
			rect_ready_dfs2 <= rect_ready_dfs1;
		end if;
	end process;
	
	LCD : entity work.lcd_ctrl
	generic map(
	   clock_rate => 60000000
	) 
	port map(
		clk => lcd_clk,
		rst => rst,
		
		col_sta => col_sta,
		col_end => col_end,
		row_sta => row_sta,
		row_end => row_end,
		
		pixel => pixel,
		pixel_strobe => open,
		
		valid => rect_valid_dfs2, 
		ready => rect_ready, 
		
		lcd_rst => lcd_rst, 
		
		lcd_wr => lcd_wr,
		lcd_cs  => lcd_cs,
		lcd_rs => lcd_rs,
		lcd_db => lcd_db
	
	);

	
--MMCME2_BASE: Base Mixed Mode Clock Manager
-- 7 Series
-- Xilinx HDL Libraries Guide, version 2012.2
    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 51.2, -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 83.333, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 25,
        CLKOUT2_DIVIDE => 10,
        CLKOUT3_DIVIDE => 10,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 25.0, -- Divide amount for CLKOUT0 (1.000-128.000).
        -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,
        CLKOUT6_DUTY_CYCLE => 0.5,
        -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        CLKOUT6_PHASE => 0.0,
        CLKOUT4_CASCADE => FALSE, -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1, -- Master division value (1-106)
        REF_JITTER1 => 0.0, -- Reference input jitter in UI (0.000-0.999).
    STARTUP_WAIT => FALSE -- Delays DONE until MMCM is locked (FALSE, TRUE)
)
    port map (  
-- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => open, -- 1-bit output: CLKOUT0
        CLKOUT0B => open, -- 1-bit output: Inverted CLKOUT0
        CLKOUT1 => mclk_int, -- 1-bit output: CLKOUT1
        CLKOUT1B => open, -- 1-bit output: Inverted CLKOUT1
        CLKOUT2 => fft_clk, -- 1-bit output: CLKOUT2
        CLKOUT2B => open, -- 1-bit output: Inverted CLKOUT2
        CLKOUT3 => lcd_clk, -- 1-bit output: CLKOUT3
        CLKOUT3B => open, -- 1-bit output: Inverted CLKOUT3
        CLKOUT4 => open, -- 1-bit output: CLKOUT4
        CLKOUT5 => open, -- 1-bit output: CLKOUT5
        CLKOUT6 => open, -- 1-bit output: CLKOUT6
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => clock_fb, -- 1-bit output: Feedback clock
        CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
        -- Status Ports: 1-bit (each) output: MMCM status ports
        LOCKED => open, -- 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => clk12M, -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0', -- 1-bit input: Power-down
        RST => '0', -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => clock_fb -- 1-bit input: Feedback clock
    );


end str;