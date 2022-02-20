-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity top_tb is 

end top_tb;

architecture test of top_tb is
    
	
  constant stereo_buff_order : integer := 3;
	
	
  signal rst : std_logic := '0';
  signal clk12M : std_logic := '0';
  signal sclk : std_logic := '0';
  signal lrclk : std_logic := '0';
  signal sound_rec : signed(23 downto 0) := (others => '0');
  signal sound_tra : signed(23 downto 0) := (others => '0');
  signal stb : std_logic := '0';
  signal sd : std_logic := '0';
  
  signal zeros : unsigned(stereo_buff_order-1 downto 0) := (others => '0');
begin
  i2s : entity work.i2s_master port map(
    	mclk_i => clk12M,
		sclk_o => sclk,
		lrclk_o => lrclk,
		
     	sd_i => sd,
    	sd_o => open,

		rec_reg_o => sound_rec,
		tra_reg_i => sound_tra,
		
		stb_o => stb
    );
    
	pingpong : entity work.i2s_stereo_pingpong 
	generic map(
		buffersizelog2 => stereo_buff_order
	)
	port map(
		rst_i => rst,
    	sclk_i => sclk,
		lrclk_i => lrclk,
		rec_reg_i => sound_rec,
		tra_reg_o => sound_tra,
		stb_i => stb,
		full_o => open,
		proc_clk_i => '0',
		proc_en_i => '0',
		proc_wr_i => '0',
		proc_addr_i => zeros,
		proc_left_data_i => x"000000",
		proc_right_data_i => x"000000",
		proc_left_data_o => open,
		proc_right_data_o => open
		);
		
		
		
    process
    begin

	rst <= '1';
	clk12M <= '0';
	for i in 1 to 16 loop
		clk12M <= not clk12M;
		wait for 2 ns;
		clk12M <= not clk12M;
		wait for 2 ns;
	end loop;
	
	rst <= '0';
	clk12M <= '0';
	for i in 1 to 16 loop
		clk12M <= not clk12M;
		wait for 2 ns;
		clk12M <= not clk12M;
		wait for 2 ns;
	end loop;
	
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
	   
		sd <= '0';
		for ii in 1 to 32 loop
			for i in 1 to 8 loop
				clk12M <= not clk12M;
				wait for 2 ns;
				clk12M <= not clk12M;
				wait for 2 ns;
			end loop;
			--sd <= not sd;
			sd <= '0';
		end loop;	
	end loop;

   
    wait;
    
    end process;
    
end test;