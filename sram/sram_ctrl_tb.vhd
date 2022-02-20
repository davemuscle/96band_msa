-- Code your fft_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sram_ctrl_tb is 

end sram_ctrl_tb;

architecture test of sram_ctrl_tb is
    
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	
	signal in_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal out_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal in_addr : unsigned(15 downto 0) := (others => '0');
	signal in_wr : std_logic := '0';
	signal in_rd : std_logic := '0';
	signal wr_done : std_logic := '0';
	signal rd_done : std_logic := '0';
	

	signal MemDB : std_logic_vector(7 downto 0) := (others => '0');
	signal MemAdr : unsigned(18 downto 0) := (others => '0');
	signal RamOEn : std_logic := '0';
	signal RamWEn : std_logic := '0';
	signal RamCEn : std_logic := '0';
	
	
begin
	SRAM : entity work.sram_ctrl
	port map(
		
		clk => clk, --max of 100 MHz? minimum 8 ns read/write times
		rst => rst,
		
		in_data_reg => in_data_reg,
		out_data_reg => out_data_reg,
		in_addr => in_addr,
		in_wr => in_wr, 
		in_rd => in_rd, 
		wr_done => wr_done,
		rd_done => rd_done,
		
		MemDB => MemDB,
		MemAdr => MemAdr,
		RamOEn => RamOEn,
		RamWEn => RamWEn,
		RamCEn => RamCEn
	
	);

	SRAM_model : entity work.sram_model
	port map(
		
		MemDB => MemDB,
		MemAdr => MemAdr,
		RamOEn => RamOEn,
		RamWEn =>  RamWEn,
		RamCEn =>  RamCEn
	
	);

	
    process
    begin
    
    clk <= '0';
	in_wr <= '0';
	in_rd <= '0';

	in_data_reg <= x"37375555AAAA3737";
	in_data_reg <= (others => '0');
	
	in_addr <= (others => '0');
	
	rst <= '1';
	
	wait for 5 ns;
	
	clk <= '1';
	wait for 5 ns;
	clk <= '0';
	wait for 5 ns;
	rst <= '0';
	wait for 5 ns;
	
	in_wr <= '1';
	
		for i in 0 to 10 loop
		--in_data_reg <= std_logic_vector(unsigned(in_data_reg) + 1);
		in_data_reg <= not in_data_reg;
		
		for i in 0 to 30 loop
			clk <= not clk;
			wait for 5 ns;
			clk <= not clk;
			wait for 5 ns;
			
		end loop;

	end loop;

    in_wr <= '0';
	
	
	for i in 0 to 30 loop
        clk <= not clk;
        wait for 5 ns;
        clk <= not clk;
        wait for 5 ns;
		
    end loop;
	
	in_rd <= '1';
	
	for i in 0 to 30 loop
        clk <= not clk;
        wait for 5 ns;
        clk <= not clk;
        wait for 5 ns;
		
    end loop;
	
	
	
    wait;
    
    end process;
    
end test;