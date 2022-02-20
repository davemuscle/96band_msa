library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

--8 Octave Decomposition
--Takes in a number of samples at one sample rate, downsamples sequentially 
--similar to a wavelet transform, and buffers up the data to be read by some transform or post-processing
--Will require a simple external controller to manage the output reading

--Input: x number of samples at 48KHz
--Output: x number of samples at 24KHz, 12KHz, 6KHz, 3KHz, 1.5KHz, 750Hz, 375Hz, 187.5Hz

--Block memories: (x = 256) 
--DELAYLINES (FIRLEN x 8 by 32)
--BUFFERS(x * 8 by 32)


entity octave_bufferer is
	generic(
		order : integer := 8; --minimum 8, 256 input samples required for 8 octaves
		octaves_order : integer := 3;
		firfile : string;
		firlenpow2 : integer
	);
	port(
		
		clk : in std_logic;
		
		full_i : in std_logic;
		full_o : out std_logic;
		
		en_o : out std_logic;
		addr_o    : out unsigned(order-1 downto 0);
		data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(order + octaves_order - 1 downto 0);
		data_o : out signed(31 downto 0)
		
	);
end octave_bufferer;

architecture bhv of octave_bufferer is 
    
	--constants------------------------------------------------------------------------
	--constant octaves_order    : integer range 0 to 15 := 1;
	constant delay_line_order : integer range 0 to 15 := firlenpow2 + octaves_order;
	constant bufferer_order   : integer range 0 to 15 := order + octaves_order;
	-----------------------------------------------------------------------------------
	
	--state machine--------------------------------------------------------------------
	type state_type is (idle, load_delay_line, run_fir );
	signal state : state_type := idle;
	-----------------------------------------------------------------------------------

	--ROM for FIR lowpass--------------------------------------------------------------
	type rom_type is array(0 to 2**firlenpow2 - 1) of bit_vector(31 downto 0);
		
	--text file reader function
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : bit_vector(31 downto 0);
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**firlenpow2 - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	
	constant fir : rom_type := rom_init(filename => firfile);
	-----------------------------------------------------------------------------------
		
	--fir reader signals --------------------------------------------------------------
	signal tap : signed(31 downto 0) := (others => '0');
	signal tap_en : std_logic := '0';
	signal tap_addr : unsigned(firlenpow2-1 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	--bufferer ram signals-------------------------------------------------------------
	signal bufferer_ena   : std_logic := '0';
	signal bufferer_wra   : std_logic := '0';
	signal bufferer_addra : unsigned(bufferer_order - 1 downto 0) := (others => '0');
	signal bufferer_dia   : signed(31 downto 0) := (others => '0');
	signal bufferer_doa   : signed(31 downto 0) := (others => '0');
	
	signal bufferer_enb   : std_logic := '0';
	signal bufferer_wrb   : std_logic := '0';
	signal bufferer_addrb : unsigned(bufferer_order - 1 downto 0) := (others => '0');
	signal bufferer_dib   : signed(31 downto 0) := (others => '0');
	signal bufferer_dob   : signed(31 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------
	
	--delay line ram signals-----------------------------------------------------------
	signal delay_line_ena   : std_logic := '0';
	signal delay_line_wra   : std_logic := '0';
	signal delay_line_addra : unsigned(delay_line_order - 1 downto 0) := (others => '0');
	signal delay_line_dia   : signed(31 downto 0) := (others => '0');
	signal delay_line_doa   : signed(31 downto 0) := (others => '0');
	
	signal delay_line_enb   : std_logic := '0';
	signal delay_line_wrb   : std_logic := '0';
	signal delay_line_addrb : unsigned(delay_line_order - 1 downto 0) := (others => '0');
	signal delay_line_dib   : signed(31 downto 0) := (others => '0');
	signal delay_line_dob   : signed(31 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------
	
	--process signals------------------------------------------------------------------
	
	type data_addr is array(0 to 2**octaves_order - 1) of unsigned(order - 1 downto 0);

	signal data_read_addr  : data_addr := (others => (others => '0'));
	signal data_read_en    : std_logic := '0';
	signal data_write_addr : data_addr := (others => (others => '0'));
	signal data_write_en   : std_logic := '0';
	
	signal data_read : signed(31 downto 0) := (others => '0');
	signal data_write : signed(31 downto 0) := (others => '0');
	
	type delay_line_addr is array(0 to 2**octaves_order - 1) of unsigned(firlenpow2 - 1 downto 0);
	
	signal delay_line_write_addr : delay_line_addr := (others => (others => '0'));
	signal delay_line_write_en   : std_logic := '0';
	
	signal delay_line_read_addr : delay_line_addr := (others => (others => '0'));
	signal delay_line_read_en   : std_logic := '0';
	
	
	signal oct_read_select  : unsigned(octaves_order - 1 downto 0) := (others => '0');
	signal oct_write_select : unsigned(octaves_order - 1 downto 0) := (others => '0');
	
	-----------------------------------------------------------------------------------
	
	--math signals---------------------------------------------------------------------
	signal accumulator : signed(63 downto 0) := (others => '0');
	signal mult : signed(63 downto 0) := (others => '0');
	
	signal overflow : std_logic := '0';
	-----------------------------------------------------------------------------------
	
	
	--control signals------------------------------------------------------------------
	constant pipe_length : integer range 0 to 15 := 8;
	signal   load_pipe   : std_logic_vector(pipe_length - 1 downto 0) := (others => '0');
	signal   math_pipe   : std_logic_vector(pipe_length - 1 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	signal load_count : integer range 0 to 7 := 0;
	
	signal fir_done : std_logic := '0';
	signal final_calc : std_logic := '0';
	signal final_octave : std_logic := '0';
	
	signal tap_addr_dly : unsigned(firlenpow2 - 1 downto 0) := (others => '0');
	signal tap_addr_reg : unsigned(firlenpow2 - 1 downto 0) := (others => '0');
	
	signal math_cnt : integer range 0 to 1023 := 0;
	signal math_cmp : integer range 0 to 1023 := 0;
	signal math_cmp_shft : unsigned(15 downto 0) := (others => '0');
	constant max_fir_cmp : unsigned(15 downto 0) := to_unsigned((2**(order)),16);

	constant tap_addr_ones : unsigned(firlenpow2 -1 downto 0) := (others => '1');
	
	--change to array later
	signal ext_read_addr : data_addr := (others => (others => '0'));
	signal en_i_dly : std_logic := '0';
	
	signal octave_switch : std_logic := '0';
	signal active_octave : integer range 0 to (2**octaves_order)-1 := 0;
	
	signal octave_write : unsigned(octaves_order -1 downto 0) := (others => '0');
	signal octave_read  : unsigned(octaves_order -1 downto 0) := (others => '0');
	
	signal done : std_logic := '0';
	
	signal temp_data : signed(31 downto 0) := (others => '0');
	signal ext_read_cs : integer range 0 to 15 := 0;
	
	signal load_en, load_wr : std_logic := '0';
	signal load_en_dly : std_logic := '0';
	signal load_en_dly2 : std_logic := '0';
	signal load_addr : unsigned(bufferer_order-1 downto 0) := (others => '0');
	constant load_addr_cmp : unsigned(bufferer_order-1 downto 0) := (others => '1');
	signal load_data : signed(31 downto 0) := (others => '0');
	signal load_done : std_logic := '0';
	
begin


	ext_read_cs <= to_integer(load_addr(order + octaves_order - 1 downto order));

	process(clk)
	begin
		if(clk'event and clk = '1') then
			
			final_calc <= '0';
			final_octave <= '0';
			fir_done <= '0';
			full_o <= '0';
			delay_line_write_en <= '0';
			delay_line_read_en <= '0';
			data_read_en <= '0';
			data_write_en <= '0';
		
			--shift vectors for pipeline control
			load_pipe(pipe_length - 1 downto 1) <= load_pipe(pipe_length - 2 downto 0);
			math_pipe(pipe_length - 1 downto 1) <= math_pipe(pipe_length - 2 downto 0);
		
			--data movement into delayline pipeline
				--first clock setup read
				if(load_pipe(1) = '1') then
					data_read_en <= '1';
				end if;
				--second clock increment read + setup write
				if(load_pipe(2) = '1') then
					data_read_addr(active_octave) <= data_read_addr(active_octave) + 1;
					delay_line_write_en <= '1';
				end if;
				--third clock increment write
				if(load_pipe(3) = '1') then
					delay_line_write_addr(active_octave) <= delay_line_write_addr(active_octave) + 1;
				end if;
				
			--fir pipeline, calculates one value from the tapped delay line
				--first clock setup read
				if(math_pipe(1) = '1') then
					delay_line_read_en <= '1';
					tap_en <= '1';
				end if;
				--second clock increment read + multiply + delay tap addr
				if(math_pipe(2) = '1') then
					delay_line_read_addr(active_octave) <= delay_line_read_addr(active_octave) - 1;
					tap_addr <= tap_addr + 1;
									
				end if;
				
				--third clock run multiplier
				if(math_pipe(3) = '1') then
					mult <= tap * data_read;
				end if;
				
				tap_addr_reg <= tap_addr;
				tap_addr_dly <= tap_addr_reg;
				
				--fourth clock accumulator
				if(math_pipe(4) = '1') then
					accumulator <= accumulator + mult;
				end if;
				
				--fifth clock check if fir done
				if(math_pipe(5) = '1') then
					if(tap_addr_dly = tap_addr_ones) then
						fir_done <= '1';
						data_write_en <= '1';
						
						if(math_cnt = math_cmp - 1) then
							final_calc <= '1';
							
							math_cnt <= 0;
							
							if(active_octave = (2**octaves_order)-1) then
								final_octave <= '1';
							end if;
						else
							math_cnt <= math_cnt + 1;
						end if;
					end if;
				
				end if;
				
				if(fir_done = '1') then
					data_write_addr(active_octave) <= data_write_addr(active_octave) + 1;
					delay_line_write_addr(active_octave) <= delay_line_write_addr(active_octave) + 1;
					ext_read_addr(active_octave) <= data_write_addr(active_octave) + 1;
				end if;
				
			load_en_dly <= load_en;
			load_en_dly2 <= load_en_dly;
			--load_en_dly3 <= load_en_dly2;
			
			if(load_en = '1') then
				ext_read_addr(ext_read_cs) <= 
					ext_read_addr(ext_read_cs) + 1;
					
			    load_wr <= '1';
				load_en <= '0';
			end if;
			
			if(load_wr = '1') then
				load_addr <= load_addr + 1;
				if(load_addr = load_addr_cmp) then
					load_done <= '1';
				end if;
				
				load_wr <= '0';
				load_en <= '1';
			end if;
			
			if(load_done = '1') then
				load_en <= '0';
				load_wr <= '0';
				load_en_dly <= '0';
				load_en_dly2 <= '0';
				load_done <= '0';
				full_o <= '1';
			end if;
					
			--pipeline control via state machine
			case state is 
			--idle state wait for full signal
			when idle =>
				
				if(full_i = '1') then
					state <= load_delay_line;
					load_pipe(0) <= '1';
					math_cnt <= 0;
					
					--math_cmp <= to_integer(max_fir_cmp(15 downto active_octave + 1));
					math_cmp <= to_integer(max_fir_cmp(15 downto 0 + 1));
					math_cmp_shft <= '0' & max_fir_cmp(15 downto 1);
					
					--reset address
					data_read_addr(active_octave) <= (others => '0');
					
					octave_read <= (others => '0');
					octave_write <= (others => '0');
					
					done <= '0';
					
				end if;
				
			--loading into delay line state
			when load_delay_line =>
			
				if(load_pipe(3) = '1') then
					--reset accumulator
					accumulator <= (others => '0');
					state <= run_fir;
					load_pipe <= (others => '0');
					
					--transfer address to read from delay line at correct spot

					delay_line_read_addr(active_octave) <= delay_line_write_addr(active_octave) + 1;
					
					--delay_line_read_addr(active_octave + 1) <= delay_line_write_addr(active_octave) + 1;
					
					--reset tap addr
					tap_addr <= (others => '0');
				end if;
			
			--doing math state
			when run_fir =>
			
				math_pipe(0) <= '1';
				
				if(fir_done = '1') then
					math_pipe <= (others => '0');
					
					if(final_octave = '1') then
						state <= idle;
						active_octave <= 0;
						done <= '1';
						load_en <= '1';
						load_addr <= (others => '0');
						octave_write <= (others => '0');
						octave_read  <= (others => '0');
					else
						if(final_calc = '1') then
							--transition octave work
							octave_write <= octave_write + 1;
							octave_read <= octave_write;
							--math_cmp <= to_integer(max_fir_cmp(15 downto active_octave + 2));
							math_cmp <= to_integer('0' & math_cmp_shft(15 downto 1));
							math_cmp_shft <= '0' & math_cmp_shft(15 downto 1);
							
							active_octave <= active_octave + 1;
							
						end if;
						state <= load_delay_line;
						load_pipe(0) <= '1';
							
					end if;
					
				end if;
				
				
			when others =>
			end case;
		
		end if;
	end process;
	
	--temp
	addr_o <= data_read_addr(0);
	en_o   <= data_read_en when active_octave = 0 else '0';
	
	delay_line_wra <= delay_line_write_en;
	delay_line_ena <= delay_line_write_en;
	

	
	delay_line_addra <= octave_write & delay_line_write_addr(active_octave);
	delay_line_addrb <= octave_write & delay_line_read_addr(active_octave);
	
	bufferer_addra <= octave_write & data_write_addr(active_octave);
	
	bufferer_addrb <= load_addr(order + octaves_order - 1 downto order) & ext_read_addr(ext_read_cs) when done = '1' 
					  else octave_read & data_read_addr(active_octave);
						  
						 
	delay_line_dia <= data_i when active_octave = 0 else temp_data;
	
	
	delay_line_wrb <= '0';
	delay_line_enb <= delay_line_read_en;

	
	data_read <= delay_line_dob;
	
	bufferer_wra <= data_write_en;
	bufferer_ena <= data_write_en;

	bufferer_dia <= data_write;
	
	bufferer_wrb <= '0';
	bufferer_enb <= load_en when done = '1' else data_read_en;

	temp_data <= bufferer_dob;
	

	data_write <= accumulator(62 downto 31);
	
	
	--rom fir taps
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(tap_en = '1') then
				tap <= signed(to_StdLogicVector(fir(to_integer(tap_addr))));
			end if;
		end if;
	end process;

	--dual port ram for delay lines
	delay_lines : entity work.fft_bram
	generic map(
		order => delay_line_order
	)
	port map(
   		clka => clk,
		wea => delay_line_wra,
		ena => delay_line_ena,
		dia => delay_line_dia,
		doa => delay_line_doa,
		addra => delay_line_addra,

		clkb => clk,
		web => delay_line_wrb,
		enb => delay_line_enb,
		dib => delay_line_dib,
		dob => delay_line_dob,
		addrb => delay_line_addrb
	);
   
   --ram for buffering downsampled data
   bufferer : entity work.fft_bram
   generic map(
		order => bufferer_order
   )
   port map(
   		clka => clk,
		wea => bufferer_wra,
		ena => bufferer_ena,
		dia => bufferer_dia,
		doa => bufferer_doa,
		addra => bufferer_addra,

		clkb => clk,
		web => bufferer_wrb,
		enb => bufferer_enb,
		dib => bufferer_dib,
		dob => bufferer_dob,
		addrb => bufferer_addrb
   );
   
   load_data <= bufferer_dob;
   
   --ram for buffering again to easily read it
   external_bufferer : entity work.fft_bram
   generic map(
		order => bufferer_order
   )
   port map(
   		clka => clk,
		wea => load_wr,
		ena => load_wr,
		dia => load_data,
		doa => open,
		addra => load_addr,

		clkb => clk,
		web => '0',
		enb => en_i,
		dib => (others => '0'),
		dob => data_o,
		addrb => addr_i
   );
   
   
end bhv;