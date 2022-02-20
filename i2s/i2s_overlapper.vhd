
   
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Buffers up three buffers of mono data (size 256)
--The full buffer is then read out, and the third buffer stored is moved to the first position
--Three more buffers are stored, and the cycle repeats

--This will convert 256 samples -> 768 samples -> 1024 samples with overlap for FFT/CQT

entity i2s_overlapper is
	generic(
		recordNumBuffs : integer; --record this many buffers then pulse done
		monobuffersizelog2 : integer;
		totalbuffersizelog2 : integer
	);
	port(
	
		clk_i : in std_logic := '0';

		full_i : in std_logic;
		full_o : out std_logic;
		read_done : out std_logic;

		en_o : out std_logic;
		addr_o : out unsigned(monobuffersizelog2 - 1 downto 0);
		mono_data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(totalbuffersizelog2 - 1 downto 0);
		mono_data_o : out signed(31 downto 0)
		
        );
end i2s_overlapper;

architecture str of i2s_overlapper is 
	
	type state_type is (
						idle,
						storebuffer,
						checkbuffer,
						readbuffers,
						finished
					   );
					   
	signal state : state_type := idle;

	constant cs_size : integer := totalbuffersizelog2-monobuffersizelog2;

	signal bram_data_i : signed(31 downto 0) := (others => '0');
	signal bram_data_o : signed(31 downto 0) := (others => '0');

	signal mono_addr : unsigned(monobuffersizelog2 - 1 downto 0) := (others => '0');
	signal out_addr : unsigned(monobuffersizelog2 - 1 downto 0) := (others => '0');
	
	signal write_addr : unsigned(totalbuffersizelog2 - 1 downto 0) := (others => '0');
	signal read_addr : unsigned(totalbuffersizelog2 - 1 downto 0) := (others => '0');
	
	signal read_buffer_num : unsigned(cs_size - 1 downto 0) := (others => '0');
	signal write_buffer_num : unsigned(cs_size - 1 downto 0) := (others => '0');
	signal buffer_num_check : unsigned(cs_size - 1 downto 0) := (others => '1');
	
	signal read_buffer_cnt : integer := 0;
	
	signal write_buffer_cnt : integer := 0;
	
	signal read_buffer_inc : unsigned(totalbuffersizelog2 - monobuffersizelog2 downto 0) := to_unsigned(recordNumBuffs, totalbuffersizelog2 - monobuffersizelog2 + 1);
	
	signal wra : std_logic := '0';
	signal ena : std_logic := '0';
	
	signal done : std_logic := '0';
	
	signal clk_dly : std_logic := '0';
	
	
	begin
	
	process(clk_i)
	begin
	
		if(clk_i'event and clk_i = '1') then
			
			full_o <= '0';
			read_done <= '0';
		
			case state is
			when idle =>
				
				wra <= '0';
				ena <= '0';
				
				if(full_i = '1') then
				
					done <= '0';
					
					mono_addr <= (others => '0');
					
					state <= storebuffer;
					clk_dly <= '0';
					
				end if;
			
			when storebuffer =>
			
				if(wra = '1') then
				
					clk_dly <= '1';
				
					if(mono_addr = to_unsigned((2**monobuffersizelog2)-1, monobuffersizelog2)) then

						--an input buffer size of data has been loaded
						--check if recordNumBuffs have been saved
						
						read_done <= '1';
						
						if(write_buffer_cnt = recordNumBuffs-1) then
							write_buffer_cnt <= 0;
							full_o <= '1';
							state <= readbuffers;
							wra <= '0';
							ena <= '0';
						else
							write_buffer_cnt <= write_buffer_cnt + 1;
							wra <= '0';
							ena <= '0';
							state <= idle; --wait for next buffer
						end if;
						
						--increment and mask the write buffer chipselect
						if(write_buffer_num = buffer_num_check) then
							write_buffer_num <= (others => '0');
							read_buffer_num <= (others => '0');
						else
							write_buffer_num <= write_buffer_num + 1;
							read_buffer_num <= write_buffer_num + 1;
						end if;
					
					else
				
						--read next sample
						if(clk_dly = '1') then
							mono_addr <= mono_addr + 1;
						end if;
						
						if(out_addr = to_unsigned((2**monobuffersizelog2)-1, monobuffersizelog2)) then
							out_addr <= (others => '0');
						else
							out_addr <= out_addr + 1;
						end if;
					end if;
				
				else
				
					wra <= '1';
					ena <= '1';
				end if;
			

			
			when readbuffers =>
			
				--if input address is the max size of the mono buffer
				if(addr_i(monobuffersizelog2 - 1 downto 0) = to_unsigned((2**monobuffersizelog2)-1, monobuffersizelog2)) then
				
					--if have read the total number of mono buffers
					if(read_buffer_cnt = ((2**totalbuffersizelog2) / (2** monobuffersizelog2)) - 1) then
						read_buffer_cnt <= 0;
						done <= '1';
						state <= finished;
					else
						read_buffer_cnt <= read_buffer_cnt + 1;
						

					end if;
	
					--increment read chipselect
					if(read_buffer_num = buffer_num_check) then
						read_buffer_num <= (others => '0');
					else
						read_buffer_num <= read_buffer_num + 1;
					end if;
						
	
				end if;
			
			when finished =>
			
				done <= '0';
				if(full_i = '0') then
					state <= idle;
					--increment read by recordNumBuffs
					read_buffer_inc <= ('0' & read_buffer_num) + to_unsigned(recordNumBuffs, totalbuffersizelog2 - monobuffersizelog2 + 1);

				end if;
			
			when others =>
			end case;
		
		end if;
	
	end process;
	
	-- --sign extend mono data into bram
	-- process(mono_data_i)
	-- begin
	
		-- for i in 1 to 8 loop
		
			-- bram_data_i(23 + i) <= mono_data_i(23);
		
		-- end loop;
	
		-- bram_data_i(23 downto 0) <= mono_data_i(23 downto 0);
	
	-- end process;
	
	bram_data_i <= mono_data_i;
	
	en_o <= ena;

	addr_o <= out_addr;
	
	-- mono_data_o <= bram_data_o(23 downto 0);
	mono_data_o <= bram_data_o;
	
	process(mono_addr, write_buffer_num)
	begin
		write_addr <= write_buffer_num & mono_addr;
	end process;
	
	process(addr_i, read_buffer_num)
	begin
	
		read_addr <= read_buffer_num & addr_i(monobuffersizelog2 - 1 downto 0);
	
	end process;
	
	--bram instantations
	ram : entity work.i2s_bram
	generic map(
		order => totalbuffersizelog2
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
		addrb => read_addr
	);

	
end str;

 		