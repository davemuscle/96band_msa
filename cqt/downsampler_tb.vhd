-- Code your downsampler_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity downsampler_tb is 

end downsampler_tb;

architecture test of downsampler_tb is
    
	constant inputorder : integer := 8;
	constant outputorder : integer := 7;
	constant downsample_factor : integer := 2;
	
	signal clk : std_logic := '0';
	signal en : std_logic := '0';
	
	signal rst : std_logic := '0';
	signal full : std_logic := '0';
	
	signal read_en : std_logic := '0';
	signal write_en : std_logic := '0';
	
	signal read_addr : unsigned(inputorder-1 downto 0) := (others => '0');
	signal write_addr : unsigned(outputorder-1 downto 0) := (others => '0');
	
	signal data_i : signed(31 downto 0) := (others => '0');
	signal data_i_int : integer := 0;
	signal data_o : signed(31 downto 0) := (others => '0');
	
	 type rom_type is array(0 to 2**inputorder - 1) of integer;
	
	-- constant romrom : rom_type := (
		-- 1,
		-- 2,
		-- 3,
		-- 4,
		-- 5,
		-- 6,
		-- 7,
		-- 8
	-- );
	

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


	constant romrom : rom_type := rom_init(filename => "sinwav440.txt");
	
	signal read_time : std_logic := '0';
	file out_file : text open write_mode is "output_file.txt";
	signal read_done : std_logic := '0';
		
begin
	
	downsampler : entity work.downsampler
	generic map(
		SIM => 0,
		inputorder => inputorder,
		outputorder => outputorder,
		downsample_factor => downsample_factor,
		firfile => "./downsampler_fir.data",
		firlenpow2 => 6,
		firlen => 51
	)
	port map(
		clk => clk,
		rst => rst,
		full_i => en,
		full_o => full,
		
		en_o => read_en,
		addr_o => read_addr,
		data_i => data_i,
		
		en_i => write_en,
		addr_i => write_addr,
		data_o => data_o
		
	);

	data_i <= to_signed(data_i_int, 32);
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(read_en = '1') then
				data_i_int <= romrom(to_integer(read_addr));
			end if;
		end if;
	end process;
	
	process(clk)
		variable out_line : line;
	begin
		if(clk'event and clk = '1') then
			if(full = '1') then
				write_en <= '1';
				write_addr <= (others => '0');
				read_time <= '1';
			end if;
			
			if(read_time = '1') then
				read_done <= '1';
		
				if(write_addr = to_unsigned(2**(outputorder)-1,(outputorder))) then
					write_addr <= (others => '0');
					read_time <= '0';
				else
					write_addr <= write_addr + 1;
				end if;
				
			end if;
			
			if(read_done = '1') then
				write(out_line, to_integer(data_o));
				writeline(out_file, out_line);
				if(read_time = '0') then
					read_done <= '0';
				end if;
			end if;
		end if;
	end process;
	
    process
    begin
    
    clk <= '0';
	
	rst <= '0';
	wait for 5 ns;
	rst <= '1';
	wait for 5 ns;
	
	for i in 0 to 20 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
	end loop;
	
	rst <= '0';
	
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
    end loop;

	
	
	
    wait;
    
    end process;
    
end test;