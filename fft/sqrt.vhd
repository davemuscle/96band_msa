library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sqrt is
	port(
		clk : in std_logic;
		load : in std_logic;
	    done : out std_logic;
		busy : out std_logic;
		input : in unsigned(63 downto 0);
		output : out unsigned(31 downto 0)
	   
        );
end sqrt;

architecture str of sqrt is 

	signal zeros : unsigned(63 downto 0) := (others => '0');
	
	signal busy_sig : std_logic := '0';

begin

	busy <= busy_sig;

	--takes 9 clocks (including load) to get result -> FOR 16 bits

	process(clk)
		variable mask : unsigned(63 downto 0) := (others => '0');
		variable remainder : unsigned(63 downto 0) := (others => '0');
		variable root : unsigned(63 downto 0) := (others => '0');
	begin
		
	
		if(clk'event and clk = '1') then
		
			if(load = '1') then
			
				--proc_sum_sig <= proc_in;
				done <= '0';
				busy_sig <= '1';
				root := (others => '0');
				remainder := input;
				mask := (62 => '1', others => '0');
				
			
			else
			
				if(busy_sig = '1') then
				
					if((root + mask) <= remainder) then
					
						remainder := remainder - (root + mask);
						root := root + (mask(62 downto 0) & '0');
					
					end if;
				
					root := '0' & root(63 downto 1);
					mask := "00" & mask(63 downto 2);
					
					if(mask = zeros) then
					
						output <= root(31 downto 0);
						done <= '1';
						busy_sig <= '0';
					
					end if;
				
				else
				
					done <= '0';
					
				end if;
			
			
			end if;
			




		end if;
	end process;
	
end str;