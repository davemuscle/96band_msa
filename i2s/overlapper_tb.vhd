-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity overlapper_tb is 

end overlapper_tb;

architecture test of overlapper_tb is
  signal rst : std_logic := '0';
  signal clk12M : std_logic := '0';
  signal sclk : std_logic := '0';
  signal lrclk : std_logic := '0';
  signal sound_rec : signed(23 downto 0) := (others => '0');
  signal sound_tra : signed(23 downto 0) := (others => '0');
  signal stb : std_logic := '0';
  signal sd : std_logic := '0';
  signal stb_tb : std_logic := '0';
  

  
  signal baba : signed(31 downto 0) := (0 => '1', others => '0');
  
	signal proc_en : std_logic := '0';
	signal proc_wr : std_logic := '0';
	signal proc_addr : unsigned(1 downto 0) := (others => '0');
	signal proc_data : signed(31 downto 0) := (others => '0');
	
	
		
	constant inputsize : integer := 1;
	constant outputsize : integer := 3;
	constant recordsize : integer := 3;
	
	signal full : std_logic := '0';
	signal mono_full : std_logic := '0';
	signal ov_en : std_logic := '0';
	signal ov_addr : unsigned(inputsize-1 downto 0) := (others => '0');
	signal mono_data : signed(31 downto 0) := (others => '0');
	
	
	
	signal ov_full : std_logic := '0';
	signal read_addr : unsigned(outputsize-1 downto 0) := (others => '0');
	signal read_en : std_logic := '0';
	signal read_start : std_logic := '0';
	signal ov_data : signed(31 downto 0) := (others => '0');

	type ramram is array(0 to (2**inputsize) - 1) of signed(31 downto 0);
	
	shared variable ram : ramram := (others => (others => '0'));
	
  signal inputaddr : unsigned(inputsize - 1 downto 0) := (others => '0');
  signal inputen : std_logic := '0';
  signal inputwr : std_logic := '0';
  signal inputdata : signed(31 downto 0) := (others => '0');
	
begin
	
	ov : entity work.i2s_overlapper
	generic map(
		recordNumBuffs => recordsize,
		monobuffersizelog2 => inputsize,
		totalbuffersizelog2 => outputsize
	)
	port map(
		clk_i => clk12M,
		full_i => mono_full,
		full_o => ov_full,
		en_o => ov_en,
		addr_o => ov_addr,
		mono_data_i => mono_data,
		en_i => read_en,
		addr_i => read_addr,
		mono_data_o => ov_data
	);
	
	
	--read from overlapper
	process(clk12M)
	begin
		if(clk12M'event and clk12M = '1') then
			if(ov_full = '1') then
			
				read_start <= '1';
			
			end if;
		
			if(read_start = '1') then
			
				read_en <= '1';
				read_addr <= (others => '0');
			
			end if;
			
			if(read_en = '1') then
				if(read_addr = to_unsigned((2**outputsize)-1, outputsize)) then
				
					read_start <= '0';
					read_en <= '0';
					read_addr <= (others => '0');
				else
					read_addr <= read_addr + 1;
				end if;
			end if;
		end if;
	
	end process;
	
	--input ram
	process(clk12M)
	begin
		if(clk12M'event and clk12M = '1') then
			if(inputen = '1') then
				inputdata <= ram(to_integer(inputaddr));
				if(inputwr = '1') then
					ram(to_integer(inputaddr)) := baba;
				end if;
			end if;
			
			if(ov_en = '1') then
				mono_data <= ram(to_integer(ov_addr));
			end if;
		end if;
	end process;
	
	-- stb_tb <= stb;
	-- process(stb_tb)
	-- begin
		-- if(stb_tb'event and stb_tb = '1') then
			-- baba <= baba + 1;
			-- if(baba = to_signed(16, 24)) then
			
				-- baba <= (others => '0');
				-- baba(0) <= '1';
			-- end if;
		-- end if;
	-- end process;
	
	-- sound_rec <= baba;
	
    process
    begin

	clk12M <= '0';
	baba <= (others => '0');
	inputaddr <= (others => '0');

	for i in 1 to 20 loop

		inputwr <= '1';
		inputen <= '1';
			
		wait for 1 ns;

		for i in 0 to 2**inputsize - 1 loop
			

			
			baba <= baba + 1;

			
			clk12M <= '1';
			
			wait for 1 ns;
			
			clk12M <= '0';

			wait for 1 ns;
			
			if(inputaddr = to_unsigned(2**inputsize - 1, inputsize)) then
				mono_full <= '1';
				inputaddr <= (others => '0');
			else 
				mono_full <= '0';
				inputaddr <= inputaddr + 1;
			end if;
			

		end loop;

		inputwr <= '0';
		inputen <= '1';

		for i in 1 to 40 loop
			clk12M <= '1';
			wait for 1 ns;
			clk12M <= '0';
			wait for 1 ns;
			mono_full <= '0';
		end loop;
	   
    end loop;
   
    wait;
    
    end process;
    
end test;