-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity top is
	port(
    	clk12M : in std_logic;
		locked : out std_logic;
    	
    	hsync : out std_logic;
		vsync : out std_logic;
		
		red : out std_logic_vector(3 downto 0);
		grn : out std_logic_vector(3 downto 0);
		blu : out std_logic_vector(3 downto 0)

        );
end top;

architecture str of top is 

	signal clock_fb : std_logic;
	signal clk_int : std_logic;
	
	signal hblank : std_logic;
	signal vblank : std_logic;

	signal hsync_int, vsync_int : std_logic := '0';
	
	constant valval : unsigned := to_unsigned(268435456,32);
	
	begin
 
  	vtc : entity work.vga_timing_gen
	port map(
		pclk => clk_int,
		hsync => hsync_int,
		hsync_n => open,
		vsync => vsync_int,
		vsync_n => open,
		hblank => hblank,
		vblank => vblank
	);

	demo : entity work.vga_2d_bin_render_basic
	generic map(
		order => 7,
		numbins => 96
	)
	port map(
		clk => clk_int,
		
		hblank => hblank,
		vblank => vblank,
		hsync => hsync_int,
		vsync => vsync_int,
		
		valid => '1',
		en_o => open,
		addr_o => open,
		data_i => valval,
		
		red => red,
		grn => grn,
		blu => blu,
		
		vsync_dly => vsync,
		hsync_dly => hsync
		
	);
	
	
	-- --color:
	-- process(hblank, vblank)
	-- begin
	-- if(	hblank = '1' or vblank = '1') then
		-- red <= (others => '0');
		-- grn <= (others => '0');
		-- blu <= (others => '0');
	-- else
		-- red <= (others => '1');
		-- grn <= (others => '0');
		-- blu <= (others => '0');
	-- end if;
	-- end process;

   
--MMCME2_BASE: Base Mixed Mode Clock Manager
-- 7 Series
-- Xilinx HDL Libraries Guide, version 2012.2
    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 61.875, -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 83.333, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 1,
        CLKOUT2_DIVIDE => 1,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 5.000, -- Divide amount for CLKOUT0 (1.000-128.000).
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
        CLKOUT0 => clk_int, -- 1-bit output: CLKOUT0
        CLKOUT0B => open, -- 1-bit output: Inverted CLKOUT0
        CLKOUT1 => open, -- 1-bit output: CLKOUT1
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
        LOCKED => locked, -- 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => clk12M, -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0', -- 1-bit input: Power-down
        RST => '0', -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => clock_fb -- 1-bit input: Feedback clock
    );


	

end str;

 		