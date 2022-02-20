
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sqrt_tb is 

end sqrt_tb;

architecture test of sqrt_tb is
    
	signal clk : std_logic := '0';
	signal load : std_logic := '0';
	signal done : std_logic := '0';
	signal busy : std_logic := '0';
	signal sum : unsigned(15 downto 0) := (others => '0');
	signal res : unsigned(15 downto 0) := (others => '0');
	
begin
  DUT : entity work.sqrt 
		port map(
		clk => clk,
		load => load,
	    done => done,
		busy => open,
		input => sum,
		output => res
    );
    
	
	
    process
    begin

	wait for 1 ns;
	
	--sum <= to_unsigned(400, 32);
	sum <= x"0019";
	load <= '1';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	clk <= '0';
	load <= '0';
	wait for 5 ns;
	
	for i in 0 to 50 loop
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end loop;
	
	--sum <= to_unsigned(x"0000130E", 32);
	sum <= x"C000";
	load <= '1';
	clk <= '1';
	wait for 5 ns;
	clk <= '0';
	load <= '0';
	wait for 5 ns;
	
	for i in 0 to 50 loop
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end loop;

    wait;
    
    end process;
    
end test;