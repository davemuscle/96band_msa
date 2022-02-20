library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

--Mutliresolution CQT frequency analysis
--For 8 octave decomposed (buffered) data
--Particularly suited for an 88 key piano
--The same FFT/CQT pair is used 8 times (sequentially) for each octave

entity mra_piano_keys is
	generic(
		order : integer := 8; --minimum 8, 256 input samples required for 8 octave decomp
		binorder : integer := 7;
		numbins : integer := 88;
		coslutfile : string;
		kernel_order : integer;
		kernel_elements : integer;
		kernel : string;
		firfile : string;
		firlenpow2 : integer
	);
	port(
		
		fft_clk : in std_logic;
		p_clk : in std_logic;
		
		full_i : in std_logic;
		full_o : out std_logic;
		valid  : out std_logic;
		
		fft_overflow : out std_logic;
		cqt_overflow : out std_logic;
		mag_overflow : out std_logic;
		
		en_o : out std_logic;
		addr_o    : out unsigned(order-1 downto 0);
		data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(binorder-1 downto 0);
		data_o : out unsigned(31 downto 0)
		
	);
end mra_piano_keys;

architecture bhv of mra_piano_keys is 
	
	signal bin_wr   : std_logic := '0';
	signal bin_addr : unsigned(binorder-1 downto 0) := (others => '0');
	signal bin_data : signed(63 downto 0) := (others => '0');
	
	signal octave_buffer_full : std_logic := '0';
	
	signal octave_sel       : unsigned(2 downto 0) := (others => '1');
	signal octave_read_addr : unsigned(7 downto 0) := (others => '0');
	signal octave_read_en   : std_logic := '0';
	signal octave_read_data : signed(31 downto 0) := (others => '0');
	
	signal cqt_ready : std_logic := '1';
	signal error : std_logic := '0';
	
	signal cqt_start : std_logic := '0';
	signal cqt_done : std_logic := '0';
	signal cqt_read_en : std_logic := '0';
	signal cqt_read_addr : unsigned(4-1 downto 0) := (others => '0');
	signal cqt_read_data : signed(63 downto 0) := (others => '0');
	
	signal downstream_state : std_logic_vector(7 downto 0) := (others => '0');
	signal read_count : integer range 0 to 15 := 0;
	signal read_done : std_logic := '0';
	
	signal octave_addr : unsigned(10 downto 0) := (others => '0');
	
	signal mra_done : std_logic := '0';
	
	signal mag_read_en : std_logic := '0';
	signal mag_read_data : signed(63 downto 0) := (others => '0');
	signal mag_read_q : signed(31 downto 0) := (others => '0');
	signal mag_read_i : signed(31 downto 0) := (others => '0');
	signal mag_read_addr : unsigned(binorder - 1 downto 0) := (others => '0');
	
	signal mag_done : std_logic := '0';
	
	signal bin_a_en : std_logic := '0';
	signal bin_a_addr : unsigned(binorder -1 downto 0) := (others => '0');
	signal bin_a_data : unsigned(31 downto 0) := (others => '0');
	
begin

	--instantiate octave bufferer
	
	oct_buf : entity work.octave_bufferer
	generic map(
		order => order,
		octaves_order => 3,
		firfile => firfile,
		firlenpow2 => firlenpow2
	)
	port map(
		clk => fft_clk,
		full_i => full_i,
		full_o => octave_buffer_full,
		
		en_o => en_o,
		addr_o => addr_o,
		data_i => data_i,
		
		en_i => octave_read_en,
		addr_i => octave_addr,
		data_o => octave_read_data
	);
	
	octave_addr <= octave_sel & octave_read_addr;

	
	--instantiate cqt wrapper
	transform : entity work.cqt_wrapper
	generic map(
		order => order,
		binorder => 4,
		numbins => 12,
		coslutfile => coslutfile,
		kernel_order => kernel_order,
		kernel => kernel,
		kernel_elements => kernel_elements
	)
	port map(
		fft_clk => fft_clk,
		
		fft_start => cqt_start,
		fft_read_en => octave_read_en,
		fft_read_addr => octave_read_addr,
		fft_read_data => octave_read_data,
		
		fft_overflow => fft_overflow,
		cqt_overflow => cqt_overflow,
		
		cqt_done => cqt_done,
		cqt_read_en => cqt_read_en,
		cqt_read_addr => cqt_read_addr,
		cqt_read_data => cqt_read_data
	);


	--logic to put cqt bins correctly into output buffer
	--when the cqt is done, put the bins in the buffer
	process(fft_clk)
	begin
		if(fft_clk'event and fft_clk = '1') then

			downstream_state(7 downto 1) <= downstream_state(6 downto 0);
			
			bin_wr <= '0';
			cqt_read_en <= '0';
			mra_done <= '0';
			read_done <= '0';
			cqt_start <= '0';
			
			if(cqt_done = '1') then
				downstream_state(0) <= '1';
			end if;
			
			if(downstream_state(1) = '1') then
				--setup read
				cqt_read_en <= '1';
				cqt_read_addr <= (others => '0');
			end if;
		
			if(downstream_state(2) = '1') then
				--increment read, setup write
				cqt_read_addr <= cqt_read_addr + 1;
				bin_wr <= '1';
			end if;
		
			if(downstream_state(3) = '1') then
				--increment write, check if done
				bin_addr <= bin_addr + 1;
				read_count <= read_count + 1;
				if(read_count = 12 - 1) then --12 bins per octave
					downstream_state <= (others => '0');
					read_done <= '1';
					read_count <= 0;
					--decrement octave select
					octave_sel <= octave_sel - 1;
					if(octave_sel = to_unsigned(0, 3)) then --if highest octave processed
						mra_done <= '1';
						read_done <= '0';
						bin_addr <= (others => '0');
						bin_wr <= '0';
					end if;
					
				end if;
			end if;		
			
			if(octave_buffer_full = '1') then
				cqt_start <= '1';
			end if;
			
			if(read_done = '1' and octave_sel /= to_unsigned(7, 3)) then
				cqt_start <= '1';
			end if;
		end if;
	end process;
	
	
	bin_data <= cqt_read_data;

	--ram for total CQT bins (numbins)
	binholder : entity work.fft_bram64
	generic map(
		order => binorder
	)
	port map(
		clka => fft_clk,
		wea => bin_wr,
		ena => bin_wr,
		dia => bin_data,
		doa => open,
		addra => bin_addr,

		clkb => fft_clk,
		web => '0',
		enb => mag_read_en,
		dib => (others => '0'),
		dob => mag_read_data,
		addrb => mag_read_addr
	);
	
	mag_read_q <= mag_read_data(63 downto 32);
	mag_read_i <= mag_read_data(31 downto 0);
	
	--instantiate magnitude calculation
	mags : entity work.fft_mag
	generic map(
		order => binorder
	)
	port map(
	    clk => fft_clk,
	    
		fft_done => mra_done,
		mag_done => mag_done,
		overflow  => mag_overflow,
		
		max_bin => open,
		
		in_qdata => mag_read_q,
		in_idata => mag_read_i,
		in_addr  => mag_read_addr,
		in_en    => mag_read_en,
		
		out_data => bin_a_data,
		out_addr => bin_a_addr,
		out_en   => bin_a_en
	   
	);

	--instantiate bin accumulator for vga crossing
	binsummer : entity work.bin_accumulator 
	generic map(
		order => 7
	)
	port map(
		fft_clk => fft_clk,
		p_clk   => p_clk,
		
		full_i => mag_done,
		full_o => full_o,
		
		valid => valid,
		
		en_o => bin_a_en,
		addr_o  => bin_a_addr,
		data_i => bin_a_data,
	
		en_i => en_i,
		addr_i => addr_i,
		data_o => data_o
	);
	
   
end bhv;