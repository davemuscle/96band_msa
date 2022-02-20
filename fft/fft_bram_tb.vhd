-- Code your fft_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fft_bram_tb is 

end fft_bram_tb;

architecture test of fft_bram_tb is
    
	signal clk : std_logic;
	signal wea  : std_logic;
	signal ena  : std_logic;
	signal dia :  signed(31 downto 0);
	signal doa : signed(31 downto 0);
	signal addra :  unsigned(9 downto 0);

	signal web  : std_logic;
	signal enb  : std_logic;
	signal dib : signed(31 downto 0);
	signal dob : signed(31 downto 0);
	signal addrb : unsigned(9 downto 0);
	
	
begin
  DUT : entity work.fft_bram port map(
		clka => clk,
		wea  => wea,
		ena  => ena,
		dia => dia,
		doa => doa,
		addra => addra,

        clkb => clk,
		web  => web,
		enb  => enb,
		dib => dib,
		dob => dob,
		addrb => addrb
    );
    
	enb <= ena;
	web <= wea;
	
    process
    begin
    
    clk <= '0';
	wea <= '1';
	ena <= '1';
	
	dia <= x"00000037";
	dib <= x"00000073";
	
	addra <= (others => '0');
	addrb <= (others => '0');
	addrb(0) <= '1';
	
	wait for 5 ns;
	
	
	
    for i in 0 to 2000 loop
        clk <= not clk;
        wait for 5 ns;
        clk <= not clk;
        wait for 5 ns;
		
    end loop;

    
    
	
	
	
    wait;
    
    end process;
    
end test;