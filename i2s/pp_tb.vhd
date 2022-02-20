-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity pp_tb is 

end pp_tb;

architecture test of pp_tb is
  signal rst : std_logic := '0';
  signal clk12M : std_logic := '0';
  signal sclk : std_logic := '0';
  signal lrclk : std_logic := '0';
  signal sound_rec : signed(23 downto 0) := (others => '0');
  signal sound_tra : signed(23 downto 0) := (others => '0');
  signal stb : std_logic := '0';
  signal sd : std_logic := '0';
  signal stb_tb : std_logic := '0';
  
  signal baba : signed(23 downto 0) := (0 => '1', others => '0');
  
	signal proc_en : std_logic := '0';
	signal proc_wr : std_logic := '0';
	signal proc_addr : unsigned(1 downto 0) := (others => '0');
	signal proc_data : signed(23 downto 0) := (others => '0');
	
	signal full : std_logic := '0';
	signal mono_full : std_logic := '0';
	signal ov_en : std_logic := '0';
	signal ov_addr : unsigned(0 downto 0) := (others => '0');
	signal mono_data : signed(23 downto 0) := (others => '0');
	
	signal ov_full : std_logic := '0';
	signal read_addr : unsigned(2 downto 0) := (others => '0');
	signal read_en : std_logic := '0';
	signal read_start : std_logic := '0';
	signal ov_data : signed(23 downto 0) := (others => '0');
	
begin
  i2s : entity work.i2s_master port map(
    	mclk_i => clk12M,
		sclk_o => sclk,
		lrclk_o => lrclk,
		
     	sd_i => sd,
    	sd_o => open,

		rec_reg_o => open,
		tra_reg_i => sound_tra,
		
		stb_o => stb
    );
    
	pingpong : entity work.i2s_stereo_pingpong 
	generic map(
		buffersizelog2 => 2
	)
	port map(
		rst_i => rst,
    	sclk_i => sclk,
		lrclk_i => lrclk,
		rec_reg_i => sound_rec,
		tra_reg_o => sound_tra,
		stb_i => stb,
		full_o => full,
		proc_clk_i => clk12M,
		proc_en_i => proc_en,
		proc_wr_i => proc_wr,
		proc_addr_i => proc_addr,
		proc_data_i => x"000000",
		proc_data_o => proc_data
		);
		
	mono : entity work.i2s_stereo2mono
	generic map(
		stereobuffersizelog2 => 2,
		monobuffersizelog2 => 1
	)
	port map(
		clk_i => clk12M,
		full_i => full,
		full_o => mono_full,
		en_o => proc_en,
		addr_o => proc_addr,
		stereo_data_i => proc_data,
		en_i => ov_en,
		addr_i => ov_addr,
		mono_data_o => mono_data
	
	);
	
	ov : entity work.i2s_overlapper
	generic map(
		monobuffersizelog2 => 1,
		totalbuffersizelog2 => 3
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
				if(read_addr = to_unsigned(7, 3)) then
				
					read_start <= '0';
					read_en <= '0';
					read_addr <= (others => '0');
				else
					read_addr <= read_addr + 1;
				end if;
			end if;
		end if;
	
	end process;
	
	stb_tb <= stb;
	process(stb_tb)
	begin
		if(stb_tb'event and stb_tb = '1') then
			baba <= baba + 1;
			if(baba = to_signed(16, 24)) then
			
				baba <= (others => '0');
				baba(0) <= '1';
			end if;
		end if;
	end process;
	
	sound_rec <= baba;
	
    process
    begin


    clk12M <= '0';
	for iii in 1 to 100 loop
		sd <= '0';
		for ii in 1 to 32 loop
			for i in 1 to 8 loop
				clk12M <= not clk12M;
				wait for 2 ns;
				clk12M <= not clk12M;
				wait for 2 ns;
			end loop;
			sd <= not sd;
		end loop;
	   
		sd <= '1';
		for ii in 1 to 32 loop
			for i in 1 to 8 loop
				clk12M <= not clk12M;
				wait for 2 ns;
				clk12M <= not clk12M;
				wait for 2 ns;
			end loop;
			sd <= not sd;
		end loop;	
	end loop;

   
    wait;
    
    end process;
    
end test;