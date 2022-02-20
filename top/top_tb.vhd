-- Code your fft_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_tb is 

end top_tb;

architecture test of top_tb is
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal adc_mclk : std_logic := '0';
	signal adc_lrclk : std_logic := '0';
	signal adc_sclk : std_logic := '0';
	signal dac_mclk : std_logic := '0';
	signal dac_lrclk : std_logic := '0';
	signal dac_sclk : std_logic := '0';	
	signal sdin : std_logic := '0';
	signal sdout : std_logic := '0';
	
begin

	DUT : entity work.top
	port map(
		clk12M => clk,
		rst => rst,
		adc_mclk => adc_mclk,
		adc_lrclk => adc_lrclk,
		adc_sclk => adc_sclk,
		dac_mclk => dac_mclk,
		dac_lrclk => dac_lrclk,
		dac_sclk => dac_sclk,
		sdin => sdin,
		sdout => sdout,

		max_bin => open
	);
	
	sdin <= '1';

    process
    begin
    
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
	wait for 1 ns;
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
	clk <= '0';
	wait for 1 ns;
	
	
	
    for i in 0 to 800000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
    end loop;

    
    
	
	
	
    wait;
    
    end process;
    
end test;