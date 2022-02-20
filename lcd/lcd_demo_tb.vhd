-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is 

end testbench;

architecture test of testbench is
    
  signal clk : std_logic := '0';
  signal tick : std_logic := '0';

  signal valid : std_logic := '0';
  signal ready : std_logic := '1';
  signal valid_reg : std_logic := '0';
  
begin
  DUT : entity work.lcd_demo

  port map(
		clk => clk,
		tick => tick,
		col_sta => open,
		col_end => open,
		row_sta => open,
		row_end => open,
		
		pixel => open,
		pixel_strobe => '0',
		
		valid => valid, 
		ready => ready
		
    );
   
	
    process
    begin
	
	for i in 1 to 10000 loop
	
		for i in 1 to 10 loop
			clk <= not clk;
			wait for 1 ns;
			clk <= not clk;
			wait for 1 ns;
		end loop;
		
		tick <= '1';
		for i in 1 to 1 loop
			clk <= not clk;
			wait for 1 ns;
			clk <= not clk;
			wait for 1 ns;
		end loop;
		
		tick <= '0';

		
		for i in 1 to 4 loop
		

			clk <= not clk;
			wait for 1 ns;
			clk <= not clk;
			wait for 1 ns;
			
			if(valid = '1') then
				ready <= '0';
			else
				ready <= '1';
			end if;
		end loop;	
	end loop;
    wait;
    
    end process;
    
end test;