-- Code your fft_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity fft_mag_tb is 

end fft_mag_tb;

architecture test of fft_mag_tb is
    
	signal rst : std_logic := '0';
	
	--signal inputorder : integer := 10;
	--signal order : integer := 8;
	--constant lut : string := "./twids/cos256.data";
	--constant loadfile : string := "sinwav440.txt";
	
	signal inputorder : integer := 3;
	signal order : integer := 3;
	constant lut : string := "./twids/cos8.data";
	constant loadfile : string := "count16bit.txt";
	
	signal rom_addr : unsigned(inputorder-1 downto 0) := (others => '0');
	signal addr_sel : unsigned(inputorder - order - 1 downto 0) := (others => '0');
	

	
    signal en : std_logic;
    signal clk : std_logic;
    signal qdata_rd : signed(31 downto 0) := (others => '0');
	signal idata_rd : signed(31 downto 0) := (others => '0');
	
    signal addr_rd : unsigned(order - 1 downto 0) := (others => '0');
	
	signal addr_rd_c : unsigned(9 downto 0) := (others => '0');
	
	signal rom_en : std_logic;
	signal addr_wr_c : unsigned(9 downto 0) := (others => '0');
	
    signal addr_wr : unsigned(order - 1 downto 0) := (others => '0');
	
	signal out_wr_en : std_logic := '0';
	signal out_en : std_logic := '0';
	signal qdata_wr : signed(31 downto 0) := (others => '0');
	signal idata_wr : signed(31 downto 0) := (others => '0');
	signal done : std_logic;
	signal addr_int : integer range 0 to 1 := 0;

	signal fft_start : std_logic := '0';
	
	signal fft_done : std_logic := '0';
	
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
	
	
	file out_file : text open write_mode is "output_mags.txt";
	--file out_imag : text open write_mode is "output_imag.txt";
	
	--constant inputdata : rom_type := rom_init(filename => "count16bit.txt");
	constant inputdata : rom_type := rom_init(filename => loadfile);

	signal rect_ready : std_logic := '0';
	signal rect_done : std_logic := '0';
	
	signal pix_addr : unsigned(8 downto 0) := (others => '0');
	signal pix_data : unsigned(31 downto 0) := (others => '0');
	signal pix_en : std_logic := '0';
	
	signal column_sta : std_logic_vector(8 downto 0) := (others => '0');
	signal column_end : std_logic_vector(8 downto 0) := (others => '0');
	signal row_sta : std_logic_vector(8 downto 0) := (others => '0');
	signal row_end : std_logic_vector(8 downto 0) := (others => '0');
	signal pixel : std_logic_vector(15 downto 0) := (others => '0');
	
	signal mag_addr_conn : unsigned(order - 2 downto 0) := (others => '0');
	
	signal lcd_rst : std_logic;
	signal lcd_wr  : std_logic;
	signal lcd_cs  : std_logic;
	signal lcd_rs  : std_logic;
	signal lcd_db  : std_logic_vector(15 downto 0);
	

	signal windowed_data : signed(23 downto 0) := (others => '0');
	
	signal fft_addr : unsigned(9 downto 0) := (others => '0');
	signal fft_en : std_logic := '0';
	signal fft_input : signed(31 downto 0) := (others => '0');
	

	
	signal mag_load : std_logic := '0';
	
	signal dnstrm_en : std_logic := '0';
	signal dnstrm_wr : std_logic := '0';
	signal dnstrm_addr : unsigned(order - 2 downto 0) := (others => '0');
	signal dnstrm_di : signed(31 downto 0) := (others => '0');
	signal dnstrm_do : signed(31 downto 0) := (others => '0');
	
	signal upstrm_en : std_logic := '0';
	signal upstrm_wr : std_logic := '0';
	signal upstrm_addr : unsigned(order - 1 downto 0) := (others => '0');
	signal upstrm_di : signed(31 downto 0) := (others => '0');
	signal upstrm_do : signed(31 downto 0) := (others => '0');
	
	signal dnstrm_addr_c : unsigned(order-1 downto 0) := (others => '0');
	
	signal start : std_logic := '0';
	
	signal initial_fill : std_logic := '0';
	
	signal clk_cnt : integer := 0;
	
	signal rom_wr : std_logic := '0';
	
	signal fft_temp : signed(31 downto 0) := (others => '0');
	
	signal a_tw : unsigned(order-1 downto 0) := (others => '0');
	signal b_tw : unsigned(order-1 downto 0) := (others => '0');
	signal in_a_en : std_logic := '0';
	
	signal in_a_qtwid : signed(15 downto 0) := (others => '0');
	signal in_a_itwid : signed(15 downto 0) := (others => '0');
	
	signal in_b_qtwid : signed(15 downto 0) := (others => '0');
	signal in_b_itwid : signed(15 downto 0) := (others => '0');
	
	signal ram_wra, ram_wrb : std_logic := '0';
	signal ram_ena, ram_enb : std_logic := '0';
	signal ram_dia, ram_dib : signed(63 downto 0) := (others => '0');
	signal ram_doa, ram_dob : signed(63 downto 0) := (others => '0');
	signal ram_addra, ram_addrb : unsigned(order-1 downto 0) := (others => '0');
		
	signal mag_read_en : std_logic := '0';
	signal mag_read_data : signed(63 downto 0) := (others => '0');
	signal mag_read_q : signed(31 downto 0) := (others => '0');
	signal mag_read_i : signed(31 downto 0) := (others => '0');
	signal mag_read_addr : unsigned(order - 1 downto 0) := (others => '0');
	
	signal mag_data : unsigned(31 downto 0) := (others => '0');
	signal mag_done : std_logic := '0';
	
begin

	
    FFT : entity work.fft 
		generic map(
		order => order,
		coslutfile => lut,
		scale_on_stage => "NONE",
		ram_loc => "INT"
		)
		port map(
	    clk => clk,
	    
		start => en,
		done => fft_done,
		loading => open,
		busy => open,
		
		overflow => open,
		
		in_qdata => qdata_rd,
		in_idata => x"00000000",
		in_addr => addr_rd,
		in_en   => rom_en,
		
		out_qdata => mag_read_q,
		out_idata => mag_read_i,
		out_addr => mag_read_addr,
		out_en => mag_read_en,
		
		ext_ram_wra   => ram_wra,
		ext_ram_ena   => ram_ena,
		ext_ram_dia   => ram_dia,
		ext_ram_doa   => ram_doa,
		ext_ram_addra => ram_addra,
		
		ext_ram_wrb   => ram_wrb,
		ext_ram_enb   => ram_enb,
		ext_ram_dib   => ram_dib,
		ext_ram_dob   => ram_dob,
		ext_ram_addrb => ram_addrb
		

    );
	
	--instantiate magnitude calculation
	mags : entity work.fft_mag
	generic map(
		order => order
	)
	port map(
	    clk => clk,
	    
		fft_done => fft_done,
		mag_done => mag_done,
		
		overflow  => open,
		
		max_bin => open,

		in_qdata => mag_read_q,
		in_idata => mag_read_i,
		in_addr  => mag_read_addr,
		in_en    => mag_read_en,
		
		out_data => mag_data,
		out_addr => addr_wr,
		out_en   => out_en
	   
	);
		
	--input stream
    process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				qdata_rd <= to_signed(inputdata(to_integer(rom_addr)), 32);
				idata_rd <= (others => '0');
			end if;
        end if;
    end process;
	
	rom_addr <= addr_sel & addr_rd;
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(fft_done = '1') then
				addr_sel <= addr_sel + 1;
			end if;
		end if;
	end process;
	
	
    process
		variable out_line : line;
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
	
    for i in 0 to 2000000 loop
        clk <= not clk;
        wait for 1 ns;
        clk <= not clk;
        wait for 1 ns;
		
		if(mag_done = '1') then

			addr_wr <= (others => '0');
			out_en <= '1';
			wait for 1 ns;
			exit;
		end if;	
		
    end loop;

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
		
		write(out_line, to_integer(mag_data));
		writeline(out_file, out_line);
	
			
			
		if(addr_wr = to_unsigned(2**order - 1, order)) then

			addr_wr <= (others => '0');
			out_en <= '0';
			exit;
		else
			addr_wr <= addr_wr + 1;
			wait for 1 ns;
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