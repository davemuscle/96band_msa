-- Code your dual_cqt_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity dual_cqt_tb is 

end dual_cqt_tb;

architecture test of dual_cqt_tb is
    
	
	signal order : integer := 8;
	
    signal en : std_logic;
    signal clk : std_logic;
	
    signal addr_rd : unsigned(order - 1 downto 0) := (others => '0');
	
	signal rom_addr0 : unsigned(order - 1 downto 0) := (others => '0');
    signal rom_addr1 : unsigned(order - 1 downto 0) := (others => '0');
    signal rom_data0 : signed(31 downto 0) := (others => '0');
    signal rom_data1 : signed(31 downto 0) := (others => '0');
	signal rom_en0 : std_logic;
	signal rom_en1 : std_logic;

    type rom_type is array(0 to 2**order - 1) of integer;
	
	--Function below taken from:
	--Joe Sugar / CEworkbench.com / May 2014
	impure function rom_init(filename : string) return rom_type is
	  file rom_file : text open read_mode is filename;
	  variable rom_line : line;
	  variable rom_value : integer;
	  variable temp : rom_type;
	begin
	  for rom_index in 0 to 2**order - 1 loop
		readline(rom_file, rom_line);
		read(rom_line, rom_value);
		temp(rom_index) := (rom_value);
	  end loop;
	  return temp;
	end function;
	--end Joe Sugar
	
	--output file
	file out_real : text open write_mode is "output_real.txt";
	file out_imag : text open write_mode is "output_imag.txt";
	
	constant inputdata : rom_type := rom_init(filename => "sinwav440.txt");

	
	signal cqt_read_en : std_logic := '0';
	signal cqt_read_addr : unsigned(7-1 downto 0) := (others => '0');
	signal cqt_read_data : signed(63 downto 0);
	
	signal cqt_done : std_logic := '0';
	signal cqt_done_reg : std_logic := '0';
	
	signal en1 : std_logic := '0';
	
begin
	
	--rom for test data, sim only
	process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en0 = '1') then
				rom_data0 <= to_signed(inputdata(to_integer(rom_addr0)), 32);
			end if;
        end if;
    end process;


	dual_cqt_inst : entity work.dual_cqt 
	port map(
			clk => clk,

			full_i => en,
			full_o => cqt_done,
			
			en_o => rom_en0,
			addr_o => rom_addr0,
			data_i => rom_data0,
			
			en_i => cqt_read_en,
			addr_i => cqt_read_addr,
			data_o => cqt_read_data

			);


	
    process
		variable out_line_imag : line;
		variable out_line_real : line;
		
    begin
    
    clk <= '0';
	
	for i in 1 to 20 loop
	
    en <= '0';
    wait for 1 ns;
	for i in 0 to 2 loop
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
	
	
	for i in 0 to 1000 loop
		clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
	end loop;

	
    for i in 0 to 50000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
		
		if(cqt_done = '1') then

			cqt_done_reg <= '1';
			exit;
		end if;	
		
		
    end loop;

	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;

	if(cqt_done_reg = '1') then
		cqt_read_addr <= (others => '0');
		cqt_read_en <= '1';
	end if;

	--read from cqt
	for i in 0 to 20000 loop
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		
		if(cqt_done_reg = '1') then
		
			write(out_line_real, to_integer(cqt_read_data(63 downto 32)));
			writeline(out_real, out_line_real);
		
			write(out_line_imag, to_integer(cqt_read_data(31 downto 0)));
			writeline(out_imag, out_line_imag);
				
				
			if(cqt_read_addr = to_unsigned(96-1, 7)) then
			
			
				cqt_read_addr <= (others => '0');
				cqt_read_en <= '0';
				cqt_done_reg <= '0';
				exit;

			else

				cqt_read_addr <= cqt_read_addr + 1;
			end if;
		else
			exit;
		end if;
		
	end loop;

		
	--dummy clocks
	
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