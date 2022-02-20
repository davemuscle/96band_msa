-- Code your downsampler_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity bin_accumulator_tb is 

end bin_accumulator_tb;

architecture test of bin_accumulator_tb is
    
	
	
	signal clk : std_logic := '0';
	signal start : std_logic := '0';
	signal done : std_logic := '0';
	
	signal data_in : unsigned(31 downto 0) := (others => '0');
	signal data_out : unsigned(31 downto 0) := (others => '0');
	
	signal addr_in : unsigned(1 downto 0) := (others => '0');
	signal addr_out : unsigned(1 downto 0) := (others => '0');
	
	signal en_i, en_o : std_logic := '0';

begin
	
	bin_summer : entity work.bin_accumulator 
	generic map(
		order => 7
	)
	port map(
		fft_clk => clk,
		p_clk   => clk,
		
		full_i => start,
		full_o => done,
		
		valid => bins_valid,
		
		en_o => cqt_en,
		addr_o  => cqt_addr,
		data_i => cqt_data,
	
		en_i => bin_en,
		addr_i => bin_addr,
		data_o => bin_data
	);

	--input stream
    process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				data_i <= to_signed(inputdata(to_integer(rom_addr)), 32);
			end if;
        end if;
    end process;
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(full = '1') then
				addr_sel <= addr_sel + 1;
			end if;
		end if;
	end process;
	
	rom_addr <= addr_sel & read_addr;
	
    process
		variable out_line : line;
    begin
    
	for i in 1 to 2**(inputorder-order) loop
	
	for i in 0 to 20 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
	end loop;
	
	for i in 0 to 20 loop
	
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
	
	end loop;
	
	
	
	en <= '1';
	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
	en <= '0';
	
    for i in 0 to 200000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
		
		if(full = '1') then
			write_en <= '1';
			write_addr <= (others => '0');
			
			wait for 1 ns;
		
			exit;
		end if;
    end loop;

	for i in 0 to 200000 loop
		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		
		write(out_line, to_integer(data_o));
		writeline(out_file, out_line);

		if(write_addr = cmp) then
			write_en <= '0';
			wait for 1 ns;
			exit;
		else
			write_addr <= write_addr + 1;
			wait for 1 ns;
		end if;
	

	
		
	end loop;
	
	for i in 0 to 50 loop clk <= not clk; wait for 1 ns; clk <= not clk; wait for 1 ns; end loop;
	
	end loop;
    wait;
    
    end process;
    
end test;