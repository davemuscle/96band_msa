-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is 

end testbench;

architecture test of testbench is
    
  signal clk : std_logic := '0';
  
 
begin
  DUT : entity work.vga_timing_gen

  port map(
		pclk => clk,
		hsync => open,
		hsync_n => open,
		vsync => open,
		vsync_n => open,
		hblank => open,
		vblank => open
    );
    
    process
    begin

    clk <= '0';
    wait for 1 ns;

	for i in 1 to 85000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;

    wait for 1 ns;
	for i in 1 to 500 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
    

	for i in 1 to 85000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
           

    
   
    wait;
    
    end process;
    
end test;