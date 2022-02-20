-- Code your fft_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rotary_encoder_tb is 

end rotary_encoder_tb;

architecture test of rotary_encoder_tb is
	
	signal clk : std_logic := '0';

	signal rot_a : std_logic := '0';
	signal rot_b : std_Logic := '0';
	
begin

	rotary : entity work.rotary_encoder
	generic map(
		top => 15,
		bottom => 0,
		tick => 1
	)
	port map(
		clk => clk,
		a => rot_a,
		b => rot_b,
		count => open,
		count_sat => open
	);
	
    process
    begin
    
	
	clk <= '0';
	rot_a <= '1';
	rot_b <= '1';
	
	for i in 1 to 10 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;
    
	for i in 1 to 20 loop
	
	--count down
	rot_a <= '0';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;	
    
	rot_b <= '0';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;

	rot_a <= '1';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;	
    
	rot_b <= '1';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;
	
	--wait a bit
	for i in 1 to 4 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;
	
	end loop;
	
	--count up
	
	for i in 1 to 20 loop
	
	rot_b <= '0';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;	
    
	rot_a <= '0';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;

	rot_b <= '1';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;	
    
	rot_a <= '1';
	for i in 1 to 1 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;
	
	for i in 1 to 4 loop
		clk <= not clk after 1 ns;
		wait for 1 ns;
		clk <= not clk after 1 ns;
		wait for 1 ns;
	end loop;

	end loop;


	
    wait;
    
    end process;
    
end test;