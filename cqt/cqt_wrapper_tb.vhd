-- Code your cqt_wrapper_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity cqt_wrapper_tb is 

end cqt_wrapper_tb;

architecture test of cqt_wrapper_tb is
    
	signal rst : std_logic := '0';
	
	signal inputorder : integer := 10;
	signal order : integer := 8;
	signal binorder : integer := 4;
	signal numbins : integer := 12;
	
	signal rom_addr : unsigned(inputorder-1 downto 0) := (others => '0');
	signal addr_sel : unsigned(inputorder - order - 1 downto 0) := (others => '0');
	
    signal en : std_logic := '0';
    signal clk : std_logic := '0';
    signal qdata_rd : signed(31 downto 0) := (others => '0');
	signal idata_rd : signed(31 downto 0) := (others => '0');
	
    signal addr_rd : unsigned(order - 1 downto 0) := (others => '0');
	
	signal addr_rd_c : unsigned(order-1 downto 0) := (others => '0');
	
	signal rom_en : std_logic;
	signal addr_wr_c : unsigned(order-1 downto 0) := (others => '0');
	
    signal addr_wr : unsigned(order - 1 downto 0) := (others => '0');
	
	signal out_wr_en : std_logic := '0';
	signal out_en : std_logic := '0';
	signal qdata_wr : signed(31 downto 0) := (others => '0');
	signal idata_wr : signed(31 downto 0) := (others => '0');
	signal done : std_logic;
	signal addr_int : integer range 0 to 1 := 0;

	signal fft_start : std_logic := '0';
	
	signal fft_done : std_logic := '0';
	signal mag_done : std_logic := '0';
	
	signal max_bin : unsigned(order-1 downto 0) := (others => '0');
	signal max_freq : unsigned(15 downto 0) := (others => '0');

    type rom_type is array(0 to 2**inputorder - 1) of integer;
	
	--Function below taken from:
	--Joe Sugar / CEworkbench.com / May 2014
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
	--end Joe Sugar
	
	constant inputdata : rom_type := rom_init(filename => "sinwav440.txt");
	
	signal fft_addr : unsigned(order-1 downto 0) := (others => '0');
	signal fft_en : std_logic := '0';
	signal fft_input : signed(31 downto 0) := (others => '0');
	

	signal fft_load : std_logic := '0';
	signal fft_busy : std_logic := '0';
	
	signal read_start : std_logic := '0';
	signal read_en : std_logic := '0';
	signal read_addr : unsigned(order -1 downto 0) := (others => '0');
	
	signal kernel_load : std_Logic := '0';
	
	signal cqt_en : std_logic := '0';
	signal cqt_addr : unsigned(order-1 downto 0) := (others => '0');
	signal cqt_data : signed(63 downto 0) := (others => '0');
	
	signal kernel_ready : std_logic := '0';
	
	signal cqt_input : signed(63 downto 0) := (others => '0');
	
	signal cqt_read_en : std_logic := '0';
	signal cqt_read_addr : unsigned(binorder - 1 downto 0) := (others => '0');
	signal cqt_read_data : signed(63 downto 0) := (others => '0');
	
	signal cqt_done : std_logic := '0';
	

	file out_real : text open write_mode is "output_real.txt";
	file out_imag : text open write_mode is "output_imag.txt";

	
	
begin
	

	
	--input stream
    process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				qdata_rd <= to_signed(inputdata(to_integer(rom_addr)), 32);
			end if;
        end if;
    end process;
	
	rom_addr <= addr_sel & addr_rd;
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(cqt_done = '1') then
				addr_sel <= addr_sel + 1;
			end if;
		end if;
	end process;
	
	
	
	CQT_WRAPWRAP : entity work.cqt_wrapper
	generic map(
		order => order,
		binorder => binorder,
		numbins => numbins,
		coslutfile => "../fft/twids/cos256.data",
		kernel_order => 6,
		kernel => "./kernel.data",
		kernel_elements => 64
		
	)
	port map(
		fft_clk => clk,
		rst => rst,
		
		fft_start => fft_start,
		fft_read_en => rom_en,
		fft_read_addr => addr_rd,
		fft_read_data => qdata_rd,
		
		fft_overflow => open,
		cqt_overflow => open,
		
		cqt_done => cqt_done,
		cqt_read_en => cqt_read_en,
		cqt_read_addr => cqt_read_addr,
		cqt_read_data => cqt_read_data

	);
	


	fft_start <= en;

    process
		variable out_line_imag : line;
		variable out_line_real : line;
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
	
	for i in 0 to 1000 loop
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
	end loop;
	
	
	for i in 1 to 2**(inputorder-order) loop
	
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
	
    for i in 0 to 200000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
		
		if(cqt_done = '1') then

			cqt_read_addr <= (others => '0');
			cqt_read_en <= '1';
			wait for 1 ns;
			exit;
		end if;	
		
    end loop;
	
	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
	

	
	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
		
	--read from fft
	for i in 0 to 20000 loop
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		
		write(out_line_real, to_integer(cqt_read_data(63 downto 32)));
		writeline(out_real, out_line_real);
	
		write(out_line_imag, to_integer(cqt_read_data(31 downto 0)));
		writeline(out_imag, out_line_imag);
			
			
		if(cqt_read_addr = to_unsigned(numbins-1, binorder)) then

			cqt_read_addr <= (others => '0');
			cqt_read_en <= '0';
			exit;
		else
			cqt_read_addr <= cqt_read_addr + 1;
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