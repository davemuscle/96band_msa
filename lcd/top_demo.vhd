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
    	
		lcd_rst : out std_logic;
		lcd_wr  : out std_logic;
		lcd_cs  : out std_logic;
		lcd_rs  : out std_logic;
		lcd_db  : out std_logic_vector(15 downto 0)

        );
end top;

architecture str of top is 

    signal column_sta : std_logic_vector(9 downto 0);
    signal column_end : std_logic_vector(9 downto 0);
    signal row_sta : std_logic_vector(8 downto 0);
    signal row_end : std_logic_vector(8 downto 0);
    
    signal pixel : std_logic_vector(15 downto 0) := (others => '0');
    
    signal valid_int : std_logic;
    signal ready_int : std_logic;
    
    signal count : std_logic_vector(5 downto 0);
    signal clk_int : std_logic := '0';
    
    signal red : std_logic_vector(4 downto 0) := (others => '0');
    
    signal frame_cnt : std_logic_vector(5 downto 0) := (others => '0');
    
    signal clock_fb : std_logic;
    
    signal rst_db_int : std_logic;
    signal rst_db : std_logic;
	
	signal clk_slow : std_logic := '0';
    
	signal tick : std_logic := '0';
	signal tick_cnt : integer := 0;

  begin
        

    
  --dual flop sync reset signal
  
  process(clk12M)
  begin
    if(clk12M'event and clk12M = '1') then
        rst_db <= rst_db_int;
        rst_db_int <= rst;
    end if;
  end process;
  
  --generate 60 Hz tick
  
  process(clk_int) 
  begin
	if(clk_int'event and clk_int = '1') then
		if(tick_cnt = 100000) then
			tick_cnt <= 0;
			tick <= '1';
		else
			tick_cnt <= tick_cnt + 1;
			tick <= '0';
		end if;
	end if;
	
  end process;
    
	
--MMCME2_BASE: Base Mixed Mode Clock Manager
-- 7 Series
-- Xilinx HDL Libraries Guide, version 2012.2
    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 50.0, -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 83.333, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 1,
        CLKOUT2_DIVIDE => 1,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 20.000, -- Divide amount for CLKOUT0 (1.000-128.000).
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
        LOCKED => open, -- 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => clk12M, -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0', -- 1-bit input: Power-down
        RST => '0', -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => clock_fb -- 1-bit input: Feedback clock
    );

    DUT : entity work.lcd_demo

    port map(
		clk => clk_int,
		tick => tick,
		col_sta => column_sta,
		col_end => column_end,
		row_sta => row_sta,
		row_end => row_end,
		
		pixel => pixel,
		pixel_strobe => '0',
		
		valid => valid_int, 
		ready => ready_int
		
    );

    lcd : entity work.lcd_ctrl 
	generic map(
		clock_rate => 30000000	
	)
	port map(
    
		clk => clk_int,
		rst => rst_db,
		
		
		col_sta => column_sta,
		col_end => column_end,
		row_sta => row_sta,
		row_end => row_end,
		
		pixel => pixel,
		pixel_strobe => open,
		
		valid => valid_int, 
		ready => ready_int, 
		
		lcd_rst => lcd_rst, 
		
		lcd_wr => lcd_wr,
		lcd_cs  => lcd_cs,
		lcd_rs => lcd_rs,
		lcd_db => lcd_db
    
    );
    
end str;

 		