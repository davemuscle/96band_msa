library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
         
--Connects to a block ram of data (stereo2mono)
--Will downsample that data by 2
--Once finished, passes downstream ram signals through 
		
--Converts 48 KHz to 24 KHz
		

--15 bit fir taps (divide by 32768)
	
entity downsampler is
	generic(
		SIM : integer;
		inputorder : integer;
		outputorder : integer;
		downsample_factor : integer;
		firfile : string;
		firlenpow2 : integer;
		firlen  : integer
	);
	port(
		
		clk : in std_logic;
		rst : in std_logic;
		
		full_i : in std_logic;
		full_o : out std_logic;
		
		en_o : out std_logic;
		addr_o    : out unsigned(inputorder-1 downto 0);
		data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(outputorder-1 downto 0);
		data_o : out signed(31 downto 0)
		
	);
end downsampler;

architecture bhv of downsampler is 
    
	type rom_type is array(0 to 2**firlenpow2 - 1) of bit_vector(15 downto 0);
		
	
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : bit_vector(15 downto 0);
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
     
	type state_type is ( reset,
						 waitfull,
						 readupstream,
						 loadpipe,
						 runfir,
						 readfir,
						 mathfir,
						 storefir,
						 donefir,
						 finished
						);

	signal state : state_type := reset;
						
	signal upstream_read_addr : unsigned(inputorder-1 downto 0) := (others => '0');
						
	signal pipe_a_addr : unsigned(firlenpow2-1 downto 0) := (others => '0');
	signal pipe_b_addr : unsigned(firlenpow2-1 downto 0) := (others => '0');
	
	signal pipe_b_en : std_logic := '0';
	signal pipe_a_wr : std_logic := '0';
	signal pipe_read : signed(31 downto 0) := (others => '0');
	signal pipe_write : signed(31 downto 0) := (others => '0');
	
	signal fir_wr : std_logic := '0';
	signal fir_addr : unsigned(outputorder-1 downto 0) := (others => '0');
	signal fir_data : signed(31 downto 0) := (others => '0');
	
	signal accum : signed(47 downto 0) := (others => '0');
	
	signal tap : signed(15 downto 0) := (others => '0');
	signal tap_en : std_logic := '0';
	signal tap_addr : unsigned(firlenpow2-1 downto 0) := (others => '0');
	
	signal firlen_ones : unsigned(firlenpow2-1 downto 0) := (others => '1');
	signal firlen_zeros : unsigned(firlenpow2-1 downto 0) := (others => '0');
	
	signal inputorder_zeros  : unsigned(inputorder-1 downto 0)  := (others => '0');
	signal outputorder_zeros : unsigned(outputorder-1 downto 0) := (others => '0');
	 
	signal ram_addr_pres : unsigned(inputorder-1 downto 0) := (others => '0');
	signal ram_addr_shft : unsigned(inputorder-1 downto 0) := (others => '0');
	
	signal fir_cnt : integer  range 0 to firlen := 0;
	signal pipe_cnt : integer range 0 to downsample_factor := 0;
	
	signal done : std_logic := '0';
	
	
begin

	process(clk)
	begin
	
		if(clk'event and clk = '1') then
			full_o <= '0';
			
			if(rst = '1') then
				state <= reset;
			else
			
				case state is
				when reset =>
					state <= waitfull;
				when waitfull =>
					
					if(full_i = '1') then
						state <= readupstream;
						done <= '0';
						--setup first write
						en_o <= '1';
						upstream_read_addr <= (others => '0');
						pipe_a_addr <= (others => '0');
						pipe_cnt <= 0;
					end if;
			
				when readupstream =>
					en_o <= '0';
					pipe_a_wr <= '1';
					--increment upstream address or note completion
					if(upstream_read_addr = to_unsigned((2**inputorder)-1, inputorder)) then
						upstream_read_addr <= (others => '0');
						done <= '1';
					else
						upstream_read_addr <= upstream_read_addr + 1;
					end if;
					state <= loadpipe;
					
				when loadpipe =>
					pipe_a_wr <= '0';
					
					--load DOWNSAMPLE_FACTOR number of samples into pipe
					if(pipe_cnt = downsample_factor-1) then
						pipe_cnt <= 0;
						state <= runfir;
						--reset accumulator
						accum <= (others => '0');
						pipe_b_addr <= pipe_a_addr;
						tap_addr <= (others => '0');
					else
						en_o <= '1';
						state <= readupstream;
						pipe_cnt <= pipe_cnt + 1;
					end if;
					
					--increment or wrap around pipe address
					if(pipe_a_addr = to_unsigned(firlen-1, firlenpow2)) then
						pipe_a_addr <= (others => '0');
					else
						pipe_a_addr <= pipe_a_addr + 1;
					end if;
			
				when runfir =>
					
					--read from pipe and fir taps

					pipe_b_en <= '1';
					tap_en <= '1';
					if(pipe_b_en = '1') then
						state <= readfir;
					end if;
					
				when readfir =>

					--do math on fir
					accum <= accum + pipe_read * tap;
					
					pipe_b_en <= '0';
					tap_en <= '0';
					state <= runfir;
					if(fir_cnt = firlen-1) then
						fir_cnt <= 0;
						state <= storefir;
					else
						fir_cnt <= fir_cnt + 1;
						--increment addresses
						if(pipe_b_addr = firlen_zeros) then
							pipe_b_addr <= to_unsigned(firlen-1, firlenpow2);
						else	
							pipe_b_addr <= pipe_b_addr - 1;
						end if;
						
						--increment tap address
						if(tap_addr = to_unsigned(firlen-1, firlenpow2)) then
							tap_addr <= (others => '0');
						else
							tap_addr <= tap_addr + 1;
						end if;
						
					end if;
					

					
				when storefir =>

					fir_wr <= '1';
					state <= donefir;
				
				when donefir =>
					accum <= (others => '0');
					fir_wr <= '0';
					if(done = '1') then
						state <= waitfull;
						full_o <= '1';
					else
						en_o <= '1';
						state <= readupstream;
					end if;
					
					if(fir_addr = to_unsigned(2**outputorder -1, outputorder)) then
						fir_addr <= (others => '0');
					else
						fir_addr <= fir_addr + 1;
					end if;
				
				
				when others =>
				
				end case;
			end if;
			
		end if;
	
	
	end process;
	
	addr_o <= upstream_read_addr;
	pipe_write <= data_i;
	
	fir_data <= accum(46 downto 15) when SIM = 0 else accum(31 downto 0);
	
	--rom fir taps
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(tap_en = '1') then
				tap <= signed(to_StdLogicVector(fir(to_integer(tap_addr))));
			end if;
		end if;
	end process;
	
	--dual port ram for fir process
	downsampler_pipe : entity work.fft_bram
	generic map(
		order => firlenpow2
	)
	port map(
		--port A used for loading data upstream into pipe
		clka => clk,
		wea  => pipe_a_wr,
		ena  => pipe_a_wr,
		dia => pipe_write,
		doa => open,
		addra => pipe_a_addr,

		--port B used for reading data into filter
        clkb => clk,
		web  => '0',
		enb  => pipe_b_en,
		dib  => x"00000000",
		dob => pipe_read,
		addrb => pipe_b_addr
	);
   
   --output ram to read downstream
   downsampler_ram : entity work.fft_bram
   generic map(
		order => outputorder
   )
   port map(
		--write downsampled data into this port
   		clka => clk,
		wea => fir_wr,
		ena => fir_wr,
		dia => fir_data,
		doa => open,
		addra => fir_addr,
		
		--read downstream from this port
		clkb => clk,
		web => '0',
		enb => en_i,
		dib => x"00000000",
		dob => data_o,
		addrb => addr_i
   );
   
   
end bhv;