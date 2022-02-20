-- Code your mra_piano_keys_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity mra_piano_keys_tb is 

end mra_piano_keys_tb;

architecture test of mra_piano_keys_tb is
    
	constant input_stream_order : integer := 16;
	
	signal en : std_logic := '0';
    signal clk : std_logic := '0';
	
	signal rom_en : std_logic;
	signal rom_addr : unsigned(input_stream_order - 1 downto 0) := (others => '0');
	signal rom_rd : signed(31 downto 0) := (others => '0');

    type rom_type is array(0 to 2**input_stream_order - 1) of integer;
	
	--Function below taken from:
	--Joe Sugar / CEworkbench.com / May 2014
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : integer;
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**input_stream_order - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	--end Joe Sugar
	
	constant inputdata : rom_type := rom_init("inputstream.txt");
	
	file out_file : text open write_mode is "out_file.txt";
	
	signal start : std_logic := '0';
	signal done : std_logic := '0';
		
	signal fft_addr : unsigned(7 downto 0) := (others => '0');
	signal fft_addr_sel : unsigned(input_stream_order - 8 - 1 downto 0) := (others => '0');
	
	signal cqt_en : std_logic := '0';
	signal cqt_addr : unsigned(6 downto 0) := (others => '0');
	signal cqt_data : unsigned(31 downto 0) := (others => '0');
	
	signal qdata_wr, idata_wr : signed(31 downto 0) := (others => '0');
	
begin


	--input stream
    process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				rom_rd <= to_signed(inputdata(to_integer(rom_addr)), 32);
			end if;
        end if;
    end process;
	
	DUT : entity work.mra_piano_keys
	generic map(
		order => 8,
		binorder => 7,
		numbins => 88,
		coslutfile => "../fft/twids/cos256.data",
		kernel_order => 6,
		kernel_elements => 64,
		kernel => "../cqt/kernel.data",
		firfile => "./lowpass_32bit_64.data",
		firlenpow2 => 6
	)
	port map(
		fft_clk => clk,
		p_clk => clk,
		full_i => en,
		full_o => done,
		valid => open,
		fft_overflow => open,
		cqt_overflow => open,
		mag_overflow => open,
		
		en_o => rom_en,
		addr_o => fft_addr,
		data_i => rom_rd,
		en_i => cqt_en,
		addr_i => cqt_addr,
		data_o => cqt_data
	);
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(done = '1') then
				fft_addr_sel <= fft_addr_sel + 1;
			end if;
		end if;
	end process;
	
	rom_addr <= fft_addr_sel & fft_addr;
	
	--qdata_wr <= cqt_data(63 downto 32);
	--idata_wr <= cqt_data(31 downto 0);
	
    process
		variable out_line : line;
    begin
    
    clk <= '0';
	
	for i in 0 to 20 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
	

	
	for i in 0 to 1000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
	
	
	for i in 1 to 2**(input_stream_order - 8) loop
	
    en <= '0';
    wait for 1 ns;
	for i in 0 to 0 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
	
    en <= '1'; 
	for i in 0 to 0 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;

	en <= '0';
	for i in 0 to 0 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
	
    for i in 0 to 200000000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
		
		if(done = '1') then

			cqt_addr <= (others => '0');
			cqt_en <= '1';
			exit;
		end if;	
		
    end loop;

	--read from process
	for i in 0 to 20000 loop
	
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		
		write(out_line, to_integer(cqt_data));
		writeline(out_file, out_line);
	
		--write(out_line_imag, to_integer(idata_wr));
		--writeline(out_imag, out_line_imag);
			
			
		if(cqt_addr = to_unsigned((12*8) -1, 7)) then --12 bins per octave (8 octaves)

			cqt_addr <= (others => '0');
			cqt_en <= '0';
			exit;
		else
			cqt_addr <= cqt_addr + 1;
		end if;
		
	end loop;

	for i in 0 to 50 loop
	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
	end loop;



	end loop;
	
	
	
    wait;
    
    end process;
    
end test;