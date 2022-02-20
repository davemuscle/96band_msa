library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity top is
	port(
    	clk12M : in std_logic;
		
		adc_mclk : out std_logic;
		adc_lrclk : out std_logic;
		adc_sclk : out std_logic;
	
		dac_mclk : out std_logic;
		dac_lrclk : out std_logic;
		dac_sclk : out std_logic;

		sdin : in std_logic;
		sdout : out std_logic;
		
		pb : in std_logic;
		sel : out std_logic;
		
		vsync : out std_logic;
		hsync : out std_logic;
		red   : out std_logic_vector(3 downto 0);
		grn   : out std_logic_vector(3 downto 0);
		blu   : out std_logic_vector(3 downto 0);
		
		xa_p : in std_logic_vector(1 downto 0);
		xa_n : in std_logic_vector(1 downto 0)
        );
end top;

architecture str of top is 
	
	constant stereo_order : integer := 9;
	constant mono_order   : integer := 8;
	constant order 		  : integer := mono_order;
	constant binorder : integer := 7;
	constant numbins : integer := 96;
	
	signal mono_full_dly : std_logic := '0';
	
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
	
	signal mono_en : std_logic := '0';
	signal mono_addr : unsigned(mono_order-1 downto 0) := (others => '0');
	signal mono_data : signed(23 downto 0) := (others => '0');
	signal mono_data_ext : signed(31 downto 0) := (others => '0');
	
	signal clock_fb : std_logic := '0';
	signal fft_clk  : std_logic := '0';
	signal p_clk    : std_logic := '0';
	signal i2s_clk  : std_logic := '0';

	signal full_buffer_dfs1, full_buffer_dfs2 : std_logic := '0';
	
	signal cqt_done : std_logic := '0';
	signal cqt_en : std_logic := '0';
	signal cqt_addr : unsigned(binorder-1 downto 0) := (others => '0');
	signal cqt_data : unsigned(31 downto 0) := (others => '0');
	
	signal bin_en : std_logic := '0';
	signal bin_addr : unsigned(binorder - 1 downto 0) := (others => '0');
	signal bin_data : unsigned(31 downto 0) := (others => '0');

	signal bins_valid : std_logic := '0';

    signal locked : std_logic := '0';

	signal hsync_int, vsync_int, hblank, vblank : std_logic := '0';
	
	attribute ASYNC_REG : string;
	signal valid_dfs : std_logic_vector(1 downto 0) := (others => '0');
	attribute ASYNC_REG of valid_dfs : signal is "TRUE";
	
	signal adc_valid : std_logic := '0';
	signal adc_id  	 : std_logic_vector(4 downto 0) := (others => '0');
	signal adc_data  : std_logic_vector(15 downto 0) := (others => '0');
	
	signal color_sel : unsigned(3 downto 0) := (others => '0');
	signal mult_sel : unsigned(11 downto 0) := (others => '0');
	constant color_id : std_logic_vector(4 downto 0) := "10100"; --0x14 for color (pin 15)
	constant mult_id  : std_logic_vector(4 downto 0) := "11100"; --0x1C for mult (pin 16)
	
	signal dig_amp_full : std_logic := '0';
	signal dig_amp_en : std_logic := '0';
	signal dig_amp_addr : unsigned(mono_order-1 downto 0) := (others => '0');
	signal dig_amp_data : signed(31 downto 0) := (others => '0');
	
	signal pb_count : unsigned(7 downto 0) := (others => '0');
	signal pb_low_count : unsigned(15 downto 0) := (others => '0');
	signal pb_high_count : unsigned(15 downto 0) := (others => '0');
	signal pb_dly : std_logic := '0';
	signal pb_been_low : std_logic := '0';
	signal sel_internal : std_logic := '0';
	
	signal color_valid, color_valid_reg, color_valid_dly : std_logic := '0';
	signal color_sel_dfs : unsigned(3 downto 0) := (others => '0');
	
	component clk_wizard
		port
		 (-- Clock in ports
		  -- Clock out ports
		  i2s_clk : out    std_logic;
		  p_clk   : out    std_logic;
		  fft_clk : out    std_logic;
		  -- Status and control signals
		  locked  : out    std_logic;
		  clk_in1 : in     std_logic
		 );
	end component;

	COMPONENT xadc_wiz_0
		PORT (
		m_axis_tvalid : OUT STD_LOGIC;
		m_axis_tready : IN  STD_LOGIC;
		m_axis_tdata  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		m_axis_tid    : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		m_axis_aclk   : IN  STD_LOGIC;
		s_axis_aclk   : IN  STD_LOGIC;
		m_axis_resetn : IN  STD_LOGIC;
		vp_in         : IN  STD_LOGIC;
		vn_in         : IN  STD_LOGIC;
		vauxp4        : IN  STD_LOGIC;
		vauxn4        : IN  STD_LOGIC;
		vauxp12       : IN  STD_LOGIC;
		vauxn12       : IN  STD_LOGIC;
		channel_out   : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		eoc_out       : OUT STD_LOGIC;
		alarm_out     : OUT STD_LOGIC;
		eos_out       : OUT STD_LOGIC;
		busy_out 	  : OUT STD_LOGIC
		);
	END COMPONENT;
	
	
begin


    adc_mclk <= i2s_clk;
    adc_lrclk <= lrclk_int;
    adc_sclk <= sclk_int;
    
    dac_mclk <= i2s_clk;
    dac_lrclk <= lrclk_int;
    dac_sclk <= sclk_int;

    i2s_master_inst : entity work.i2s_master
    port map(
		mclk_i => i2s_clk,
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
		rst_i => '0',
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

	--digital amp
	
	amp : entity work.dig_amp
	generic map(
		order => mono_order
	)
	port map(
		clk => fft_clk,
		
		full_i => mono_full,
		full_o => dig_amp_full,
		
		mult => mult_sel,
		
		en_o => mono_en,
		addr_o  => mono_addr,
		data_i => mono_data_ext,
		
		en_i => dig_amp_en,
		addr_i => dig_amp_addr,
		data_o => dig_amp_data
	);
	
	--multi res analysis
	main_dsp : entity work.mra_piano_keys
	generic map(
		order => order,
		binorder => binorder,
		numbins => numbins,
		coslutfile => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/fft/twids/cos256.data",
		kernel_order => 6,
		kernel_elements => 64,
		kernel => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/cqt/kernel.data",
		firfile => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/oct/lowpass_32bit_64.data",
		firlenpow2 => 6
	)
	port map(
		fft_clk => fft_clk,
		p_clk   => p_clk,
		full_i => dig_amp_full,
		full_o => open,
		valid => bins_valid,
		
		fft_overflow => open,
		cqt_overflow => open,
		mag_overflow => open,
		
		en_o => dig_amp_en,
		addr_o => dig_amp_addr,
		data_i => dig_amp_data,
		en_i => bin_en,
		addr_i => bin_addr,
		data_o => bin_data
	);
	
	--vga timing gen
	vtc : entity work.vga_timing_gen
	port map(
		pclk => p_clk,
		hsync => hsync_int,
		hsync_n => open,
		vsync => vsync_int,
		vsync_n => open,
		hblank => hblank,
		vblank => vblank
	);
	
	process(p_clk)
	begin
		if(p_clk'event and p_clk = '1') then
			valid_dfs(0) <= bins_valid;
			valid_dfs(1) <= valid_dfs(0);
		end if;
	end process;
	
	
	--vga renderer
	screen_render : entity work.vga_2d_bin_render_basic
	generic map(
		order => binorder,
		numbins => numbins
	)
	port map(
		clk => p_clk,
		
		hblank => hblank,
		vblank => vblank,
		hsync => hsync_int,
		vsync => vsync_int,
		
		valid => valid_dfs(1),
		en_o => bin_en,
		addr_o => bin_addr,
		data_i => bin_data,
		
		color_read_map_sel => color_sel_dfs,
		
		red => red,
		grn => grn,
		blu => blu,
		
		vsync_dly => vsync,
		hsync_dly => hsync
		
	);

	clock_tile : clk_wizard
	port map ( 
	-- Clock out ports  
		i2s_clk => i2s_clk,
		p_clk => p_clk,
		fft_clk => fft_clk,
	-- Status and control signals                
		locked => locked,
    -- Clock in ports
		clk_in1 => clk12M
	);
	 
	process(fft_clk)
	begin
		if(fft_clk'event and fft_clk = '1') then
			
			color_valid <= '0';
			
			
			--new adc data
			if(adc_valid = '1') then
				
				if(adc_id = color_id) then
					color_sel <= unsigned(adc_data(15 downto 12)); 
					color_valid <= '1';
					--upper 4 bits of adc (12 bit data left justified)
				end if;
				
				if(adc_id = mult_id) then
					mult_sel <= unsigned(adc_data(15 downto 4));
					--same as above
				end if;
				
			end if;
			
		end if;
	end process;
	
	process(p_clk)
	begin
		if(p_clk'event and p_clk = '1') then
			--dfs the valid signal
			color_valid_reg <= color_valid; --metastable
			color_valid_dly <= color_valid_reg; --stable
			
			if(color_valid_dly = '1') then
				color_sel_dfs <= color_sel;
			end if;
			
		end if;
	end process;
	 
	--mic / line in select pushbutton toggle
	process(clk12M)
	begin
		if(clk12M'event and clk12M = '1') then
		
			pb_count <= pb_count + 1;
			
			if(pb_count = to_unsigned(24-1, 8)) then --count 24:1 ratio, should be 500 kHz tick for pb
				pb_count <= (others => '0');
				
				if(pb = '0') then
					pb_low_count <= pb_low_count + 1;
					pb_high_count <= (others => '0');
				end if;
			
				if(pb = '1') then
					pb_high_count <= pb_high_count + 1;
					pb_low_count <= (others => '0');
				end if; 
			
				if(pb_low_count >= to_unsigned(50000-1, 16)) then
					pb_been_low <= '1';
				end if;
			
				if(pb_high_count = to_unsigned(50000-1, 16)) then
					if(pb_been_low = '1') then
						sel_internal <= not sel_internal;
						pb_been_low <= '0';
					end if;
				end if;
			
			end if;

		end if;
	end process;
	
	sel <= sel_internal;
	
 	xadc_test : xadc_wiz_0
	  PORT MAP (
		m_axis_tvalid => adc_valid,
		m_axis_tready => '1',
		m_axis_tdata => adc_data,
		m_axis_tid => adc_id,
		m_axis_aclk => fft_clk,
		s_axis_aclk => fft_clk,
		m_axis_resetn => locked,
		vp_in => '0',
		vn_in => '0',
		vauxp4 => xa_p(0),
		vauxn4 => xa_n(0),
		vauxp12 => xa_p(1),
		vauxn12 => xa_n(1),
		channel_out => open,
		eoc_out => open,
		alarm_out => open,
		eos_out => open,
		busy_out => open
	  );
	  

end str;