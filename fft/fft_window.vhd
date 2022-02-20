
   
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity fft_window is
	generic(
		buffersizelog2 : integer;
		windowfile : string
	);
	port(
	
		clk_i : in std_logic := '0';

		full_i : in std_logic;
		full_o : out std_logic;

		en_o : out std_logic;
		addr_o : out unsigned(buffersizelog2 - 1 downto 0);
		data_i : in signed(23 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(buffersizelog2 - 1 downto 0);
		data_o : out signed(23 downto 0)
		
        );
end fft_window;

architecture str of fft_window is 
	
	type state_type is (
						idle,
						read_pipe,
						math_pipe,
						nth_pipe,
						finished
					   );
					   
	signal state : state_type := idle;

    type rom_type is array(0 to 2**buffersizelog2 - 1) of bit_vector(15 downto 0);

	 
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : bit_vector(15 downto 0);
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**buffersizelog2 - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	
	constant window : rom_type := rom_init(filename => windowfile);
	
	signal mult_result : signed(40 downto 0) := (others => '0');
	signal window_val : unsigned(15 downto 0) := (others => '0');
	signal window_cast : signed(16 downto 0) := (others => '0');
	
	signal bram_data_i : signed(31 downto 0) := (others => '0');
	signal bram_data_o : signed(31 downto 0) := (others => '0');

	signal read_addr : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	
	signal write_addr : unsigned(buffersizelog2 - 1 downto 0) := (others => '0');
	
	signal wra : std_logic := '0';
	signal ena : std_logic := '0';
	
	signal done : std_logic := '0';
	
	
	
	begin
	
	process(clk_i)
	begin
	
		if(clk_i'event and clk_i = '1') then
			
			full_o <= '0';
		
			case state is
			when idle =>
			
				read_addr <= (others => '0');
				write_addr <= (others => '0');
				wra <= '0';
				ena <= '0';
					
				if(full_i = '1') then
				
					done <= '0';
					
					ena <= '1';
				
					state <= read_pipe;
				
				
				end if;
				
			when read_pipe =>
			
				state <= math_pipe;
				read_addr <= read_addr + 1;
				
			when math_pipe =>
			
				--read finished
			

				read_addr <= read_addr + 1;

			
				mult_result <= data_i * window_cast;
				
				--throw write enable
				
				wra <= '1';
				
				state <= nth_pipe;
				
			when nth_pipe =>
							
			
				--check address
				if(read_addr = to_unsigned((2**buffersizelog2)-1, buffersizelog2)) then
					read_addr <= (others => '0');
				else
					read_addr <= read_addr + 1;
				end if;
			
				mult_result <= data_i * window_cast;
				
				--throw write enable
				
				wra <= '1';
				
				if(write_addr = to_unsigned((2**buffersizelog2)-1, buffersizelog2)) then
					write_addr <= (others => '0');
					wra <= '0';
					ena <= '0';
					full_o <= '1';
					state <= finished;
				else
					write_addr <= write_addr + 1;
					state <= nth_pipe;
				end if;
			

			when finished =>
			
				if(full_i = '0') then
				
					state <= idle;
				
				end if;
			
			when others =>
			end case;
		
		end if;
	
	end process;
	
	--shift multiplication result 
	process(mult_result)
	begin
	
		for i in 1 to 8 loop
		
			bram_data_i(23 + i) <= mult_result(38);
		
		end loop;
	
		--shift right 15 times
		bram_data_i(23 downto 0) <= mult_result(38 downto 15);
	
	end process;
	
	en_o <= ena;

	addr_o <= read_addr;
	
	data_o <= bram_data_o(23 downto 0);
	
	--bram instantations
	bram : entity work.i2s_bram
	generic map(
		order => buffersizelog2
	)
	port map(
		clka => clk_i,
		wea  => wra, --only writing to port A
		ena  => wra,
		dia  => bram_data_i,
		doa  => open,
		addra => write_addr,

        clkb  => clk_i,
		web  => '0', --only reading port B
		enb  => en_i,
		dib  => x"00000000",
		dob  => bram_data_o,
		addrb => addr_i
	);

	--read from window rom
	process(clk_i)
	begin
	
		if(clk_i'event and clk_i = '1') then
		
			if(ena = '1') then
			
				window_val <= unsigned(to_StdLogicVector(window(to_integer(read_addr))));
			
			end if;

		end if;
	
	end process;
	

	window_cast(16) <= '0';
	window_cast(15 downto 0) <= signed(window_val);


end str;

 		