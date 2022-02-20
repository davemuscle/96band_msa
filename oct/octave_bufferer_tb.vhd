-- Code your downsampler_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity octave_bufferer_tb is 

end octave_bufferer_tb;

architecture test of octave_bufferer_tb is
    
	constant inputorder : integer := 10;
	constant order : integer := 8;
	constant octaves_order : integer := 3;

	signal rom_addr : unsigned(inputorder-1 downto 0) := (others => '0');
	signal rom_en : std_logic := '0';
	signal addr_sel : unsigned(inputorder - order - 1 downto 0) := (others => '0');
	

	
	signal clk : std_logic := '0';
	signal en : std_logic := '0';
	
	signal rst : std_logic := '0';
	signal full : std_logic := '0';
	
	signal read_en : std_logic := '0';
	signal write_en : std_logic := '0';
	
	signal read_addr : unsigned(order-1 downto 0) := (others => '0');
	signal write_addr : unsigned(order + octaves_order - 1 downto 0) := (others => '0');
	signal ones : unsigned(order + octaves_order - 1 downto 0) := (others => '1');
	signal data_i : signed(31 downto 0) := (others => '0');
	signal data_i_int : integer := 0;
	signal data_o : signed(31 downto 0) := (others => '0');
	
	type rom_type is array(0 to 2**inputorder - 1) of integer;

	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : integer;
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**inputorder - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;


	constant inputdata : rom_type := rom_init(filename => "sinwav440.txt");
	--constant romrom : rom_type := rom_init(filename => "test_data.txt");
	
	signal read_time : std_logic := '0';
	file out_file : text open write_mode is "output_file.txt";
	signal read_done : std_logic := '0';

	constant cmp : unsigned(order + octaves_order - 1 downto 0) := to_unsigned(255, order + octaves_order);
		
begin
	
	downsampler : entity work.octave_bufferer
	generic map(
		order => order,
		octaves_order => octaves_order,
		firfile => "./lowpass_32bit.data",
		firlenpow2 => 7
	)
	port map(
		clk => clk,
		full_i => en,
		full_o => full,
		
		en_o => rom_en,
		addr_o => read_addr,
		data_i => data_i,
		
		en_i => write_en,
		addr_i => write_addr,
		data_o => data_o
		
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