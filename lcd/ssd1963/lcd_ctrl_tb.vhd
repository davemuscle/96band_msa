-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is 

end testbench;

architecture test of testbench is
    
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal col_sta : std_logic_vector(9 downto 0);
  signal col_end : std_logic_vector(9 downto 0);
  signal row_sta : std_logic_vector(8 downto 0);
  signal row_end : std_logic_vector(8 downto 0);
  signal pixel : std_logic_vector(15 downto 0);
  signal valid : std_logic;
  signal ready : std_logic;
  signal lcd_rst : std_logic;
  signal lcd_wr : std_logic;
  signal lcd_rs : std_logic;
  signal lcd_cs : std_logic;
  signal lcd_db : std_logic_vector(15 downto 0);
  
  
begin
  DUT : entity work.lcd_ctrl
  generic map(
		clock_rate => 1000
  )
  port map(
		clk => clk,
		rst => rst,
		
		
		col_sta => col_sta,
		col_end => col_end,
		row_sta => row_sta,
		row_end => row_end,
		
		pixel => pixel,
		pixel_strobe => open,
		
		valid => valid, 
		ready => ready, 
		
		lcd_rst => lcd_rst, 
		
		lcd_wr => lcd_wr,
		lcd_cs  => lcd_cs,
		lcd_rs => lcd_rs,
		lcd_db => lcd_db
    );
    
    process
    begin

    clk <= '0';
    rst <= '0';
    wait for 1 ns;
    rst <= '1';
    wait for 1 ns;
    rst <= '0';
    
    valid <= '1';
    pixel <= x"F800";
    col_sta <= (others => '0');
    row_sta <= (others => '0');
    col_end <= "0000000010";
    row_end <= "000000010";
    

	for i in 1 to 85000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;

           
    rst <= '1';
    wait for 1 ns;
	for i in 1 to 500 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
    
    rst <= '0';
    wait for 1 ns;

	for i in 1 to 85000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
           

    
   
    wait;
    
    end process;
    
end test;