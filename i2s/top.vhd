
--I2S master to communicate with Digilent's PMOD i2s2 module
--Port descriptions: 
    --clk12M and rst are from the Artix 7 board
    --adc and dac pins go to pmod pins in i2s_top.xcd
    --BRAM port B pins connect to audio proc
    

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
    	sdout : out std_logic

        );
end top;

architecture str of top is 

    signal mclk_int : std_logic;
    signal lrclk_int : std_logic;
    signal sclk_int : std_logic;
    
	signal sound_rec : signed(23 downto 0) := (others => '0');
	signal sound_tra : signed(23 downto 0) := (others => '0');
	signal stb : std_logic := '0';
	
	signal sd : std_logic := '0';
	
	signal clock_fb : std_logic := '0';
	
	signal stereo_full : std_logic := '0';
	signal mono_full : std_logic := '0';
	
	signal stereo_full_dfs1 : std_logic := '0';
	signal setero_full_dfs2 : std_logic := '0';


	
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
		buffersizelog2 => 4
	)
	port map(
		rst_i => rst,
    	sclk_i => sclk_int,
		lrclk_i => lrclk_int,
		rec_reg_i => sound_rec,
		tra_reg_o => sound_tra,
		stb_i => stb,
		full_o => stereo_full,
		proc_clk_i => mclk_int,
		proc_en_i => '0',
		proc_wr_i => '0',
		proc_addr_i => "0000",
		proc_left_data_i => x"000000",
		proc_right_data_i => x"000000",
		proc_left_data_o => open,
		proc_right_data_o => open
		);
		
	mono : entity work.i2s_stereo2mono
	generic map(
		stereobuffersizelog2 => 4,
		monobuffersizelog2 => 3
	)
	port map(
		clk_i => clk12M,
		full_i => full,
		full_o => open,
		en_o => proc_en,
		addr_o => proc_addr,
		stereo_data_i => proc_data,
		en_i => '0',
		addr_i => "0",
		mono_data_o => open
	
	);
	--MMCME2_BASE: Base Mixed Mode Clock Manager
-- 7 Series
-- Xilinx HDL Libraries Guide, version 2012.2
    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 51.200, -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 83.333, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 25,
        CLKOUT2_DIVIDE => 50,
        CLKOUT3_DIVIDE => 13,
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
        CLKOUT2 => open, -- 1-bit output: CLKOUT2
        CLKOUT2B => open, -- 1-bit output: Inverted CLKOUT2
        CLKOUT3 => open, -- 1-bit output: CLKOUT3
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
        RST => rst, -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => clock_fb -- 1-bit input: Feedback clock
    );

end str;