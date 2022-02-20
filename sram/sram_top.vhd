-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity sram_top is
	port(
		
		clk : in std_logic; --max of 100 MHz? minimum 8 ns read/write times
		rst : in std_logic;
		
		MemDB : inout std_logic_vector(7 downto 0);
		MemAdr : out unsigned(18 downto 0);
		RamOEn : out std_logic;
		RamWEn : out std_logic;
		RamCEn : out std_logic;
		
		pio26 : out std_logic;
		pio27 : out std_logic;
		pio28 : out std_logic;
		pio29 : out std_logic
		
	);
end sram_top;

architecture bhv of sram_top is 

	signal in_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal out_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal in_addr : unsigned(15 downto 0) := (others => '0');
	signal in_wr : std_logic := '0';
	signal in_rd : std_logic := '0';
	signal wr_done : std_logic := '0';
	signal rd_done : std_logic := '0';
	
	signal wr_latch : std_logic := '0';
	
	signal bigval : unsigned(63 downto 0) := (others => '0');
	signal cnt : integer := 0;
	
	signal clock_fb : std_logic := '0';
	
	signal clk_int : std_logic := '0';
	
begin

	SRAM : entity work.sram_ctrl
	port map(
		
		clk => clk_int, --max of 100 MHz? minimum 8 ns read/write times
		rst => rst,
		
		in_data_reg => in_data_reg,
		out_data_reg => out_data_reg,
		in_addr => in_addr,
		in_wr => in_wr, 
		in_rd => in_rd, 
		wr_done => wr_done,
		rd_done => rd_done,
		
		MemDB => MemDB,
		MemAdr => MemAdr,
		RamOEn => RamOEn,
		RamWEn => RamWEn,
		RamCEn => RamCEn
	
	);

	pio26 <= out_data_reg(0);
	pio27 <= out_data_reg(1);
	pio28 <= out_data_reg(2);
	pio29 <= out_data_reg(3);

	process(clk_int)
	begin
		if(clk_int'event and clk_int = '1') then
			cnt <= cnt + 1;
			in_wr <= '0';
			in_rd <= '0';
			in_data_reg <= std_logic_vector(bigval);
		
			if(wr_latch = '0' or cnt = 10000) then
			
				bigval <= bigval + 1;
				wr_latch <= '1';
				in_wr <= '1';
				cnt <= 0;
				
			end if;
		
			if(wr_done = '1') then
			
				in_rd <= '1';
			
			end if;
			
			if(rd_done = '1') then
				wr_latch <= '0';
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
        CLKOUT1_DIVIDE => 25,
        CLKOUT2_DIVIDE => 50,
        CLKOUT3_DIVIDE => 13,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 7.5, -- Divide amount for CLKOUT0 (1.000-128.000).
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
        CLKIN1 => clk, -- 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => '0', -- 1-bit input: Power-down
        RST => rst, -- 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => clock_fb -- 1-bit input: Feedback clock
    );


end bhv;