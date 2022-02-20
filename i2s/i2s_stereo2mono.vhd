
   
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Data is stored as L R L R in input BRAM
--Data will be stored as M M for output BRAM

--Input BRAM size should be twice the size of internal/output BRAM
--Does not write to external BRAMs

entity i2s_stereo2mono is
	generic(
		stereobuffersizelog2 : integer;
		monobuffersizelog2 : integer
	);
	port(
	
		clk_i : in std_logic := '0';

		full_i : in std_logic;
		full_o : out std_logic;

		en_o : out std_logic;
		addr_o : out unsigned(stereobuffersizelog2 - 1 downto 0);
		stereo_data_i : in signed(23 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(monobuffersizelog2 - 1 downto 0);
		mono_data_o : out signed(23 downto 0)
		
        );
end i2s_stereo2mono;

architecture str of i2s_stereo2mono is 
	
	type state_type is (
						idle,
						readleft,
						readright,
						storemono,
						finished
					   );
					   
	signal state : state_type := idle;

	signal stereo_left : signed(23 downto 0) := (others => '0');
	signal stereo_right : signed(23 downto 0) := (others => '0');
	signal mono_calculation : signed(23 downto 0) := (others => '0');
	signal bram_data_i : signed(31 downto 0) := (others => '0');
	signal bram_data_o : signed(31 downto 0) := (others => '0');
	signal stereo_addr : unsigned(stereobuffersizelog2 - 1 downto 0) := (others => '0');
	signal mono_addr : unsigned(monobuffersizelog2 - 1 downto 0) := (others => '0');
	
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
				
				if(full_i = '1') then
				
					done <= '0';
					stereo_addr <= (others => '0');
					mono_addr <= (others => '0');
					wra <= '0';
					ena <= '0';
				
					state <= readleft;
				
				end if;
				
			when readleft =>
			
				if(ena = '0') then
					--setup read
					ena <= '1';
					
				else
					--read done
					ena <= '0';
					stereo_addr <= stereo_addr + 1;
					state <= readright;
				
				end if;
				
			when readright =>
			
				if(ena = '0') then
				
					stereo_left <= stereo_data_i;
				
					--setup read
					ena <= '1';
					
					
				else
					
					--read done
					ena <= '0';
					
					if(stereo_addr = to_unsigned((2**stereobuffersizelog2) - 1, stereobuffersizelog2)) then
						done <= '1';
					else
						stereo_addr <= stereo_addr + 1;
					end if;
					
					state <= storemono;
						
				end if;
			
			when storemono =>
			
				if(wra = '0') then
					--calulate mono data
					mono_calculation <= stereo_left + stereo_data_i;
					wra <= '1';
					
				else
					--stored in bram
					wra <= '0';
					
					if(done = '1') then
					
						state <= finished;
						full_o <= '1';
						
					else
						mono_addr <= mono_addr + 1;
						state <= readleft;
					end if;
				end if;
			
			when finished =>
			
				if(full_i = '0') then
				
					state <= idle;
				
				end if;
			
			when others =>
			end case;
		
		end if;
	
	end process;
	
	--sign extend mono data into bram
	process(mono_calculation)
	begin
	
		for i in 1 to 8 loop
		
			bram_data_i(23 + i) <= mono_calculation(23);
		
		end loop;
	
		--sign extend bit 23 for shift right
		--bram_data_i(23) <= mono_calculation(23);
		--bram_data_i(22 downto 0) <= mono_calculation(23 downto 1);
		bram_data_i(23 downto 0) <= mono_calculation(23 downto 0);
	
	end process;
	
	en_o <= ena;

	addr_o <= stereo_addr;
	
	mono_data_o <= bram_data_o(23 downto 0);
	
	--bram instantations
	mono : entity work.i2s_bram
	generic map(
		order => monobuffersizelog2
	)
	port map(
		clka => clk_i,
		wea  => wra, --only writing to port A
		ena  => wra,
		dia  => bram_data_i,
		doa  => open,
		addra => mono_addr,

        clkb  => clk_i,
		web  => '0', --only reading port B
		enb  => en_i,
		dib  => x"00000000",
		dob  => bram_data_o,
		addrb => addr_i
	);

	
end str;

 		