-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity vga_2d_bin_render_basic_tb is 

end vga_2d_bin_render_basic_tb;

architecture testbench of vga_2d_bin_render_basic_tb is
    
	signal clk : std_logic := '0';
	signal tick : std_logic := '0';

	signal valid : std_logic := '0';
	signal ready : std_logic := '1';
	signal valid_reg : std_logic := '0';

	signal hblank, vblank, hsync_int, vsync_int, vsync, hsync : std_logic := '0';
	
	type rom_type is array(0 to 2**7 - 1) of integer;

	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : integer;
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**7 - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	--end Joe Sugar

	constant inputdata : rom_type := rom_init("screenInput.txt");
	signal rom_en : std_logic;
	signal rom_addr : unsigned(7 - 1 downto 0) := (others => '0');
	signal rom_rd : unsigned(31 downto 0) := (others => '0');
	
begin

	--vga timing gen
	vtc : entity work.vga_timing_gen
	port map(
		pclk => clk,
		hsync => hsync_int,
		hsync_n => open,
		vsync => vsync_int,
		vsync_n => open,
		hblank => hblank,
		vblank => vblank
	);

	
	--vga renderer
	screen_render : entity work.vga_2d_bin_render_basic
	generic map(
		order => 7,
		numbins => 96
	)
	port map(
		clk => clk,
		
		hblank => hblank,
		vblank => vblank,
		hsync => hsync_int,
		vsync => vsync_int,
		
		valid => '1',
		en_o => rom_en,
		addr_o => rom_addr,
		data_i => rom_rd,
		
		red => open,
		grn => open,
		blu => open,
		
		vsync_dly => vsync,
		hsync_dly => hsync
		
	);
	
	--input stream
    process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				rom_rd <= to_unsigned(inputdata(to_integer(rom_addr)), 32);
			end if;
        end if;
    end process;
	
	
    process
    begin
	

	for i in 1 to 10000000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;

    wait;
    
    end process;
    
end testbench;