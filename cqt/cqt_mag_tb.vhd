-- Code your cqt_tb here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity cqt_mag_tb is 

end cqt_mag_tb;

architecture test of cqt_mag_tb is
    
	signal rst : std_logic := '0';
	
	signal order : integer := 12;
	signal binorder : integer := 7;
	
    signal en : std_logic;
    signal clk : std_logic;
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
	
	constant inputdata : rom_type := rom_init(filename => "sinwav440.txt");
	
	signal fft_addr : unsigned(order-1 downto 0) := (others => '0');
	signal fft_en : std_logic := '0';
	signal fft_input : signed(31 downto 0) := (others => '0');
	
	signal	ram0_ena   : std_logic := '0';
	signal	ram0_wra   :  std_logic := '0';
	signal	ram0_addra :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram0_dia   :  signed(63 downto 0) := (others => '0');
	signal	ram0_doa   :  signed(63 downto 0) := (others => '0');
		
	signal	ram0_enb   :  std_logic := '0';
	signal	ram0_wrb   :  std_logic := '0';
	signal	ram0_addrb :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram0_dib   :  signed(63 downto 0) := (others => '0');
	signal	ram0_dob   :  signed(63 downto 0) := (others => '0');	
		
	signal	ram1_ena   :  std_logic := '0';
	signal	ram1_wra   :  std_logic := '0';
	signal	ram1_addra :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram1_dia   :  signed(63 downto 0) := (others => '0');
	signal	ram1_doa   :  signed(63 downto 0) := (others => '0');
		
	signal	ram1_enb   :  std_logic := '0';
	signal	ram1_wrb   :  std_logic := '0';
	signal	ram1_addrb :  unsigned(order - 1 downto 0) := (others => '0');
	signal	ram1_dib   :  signed(63 downto 0) := (others => '0');
	signal	ram1_dob   :  signed(63 downto 0) := (others => '0');
	
	signal fft_load : std_logic := '0';
	signal fft_busy : std_logic := '0';
	
	signal in_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal out_data_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal in_addr : unsigned(15 downto 0) := (others => '0');
	signal in_wr : std_logic := '0';
	signal in_rd : std_logic := '0';
	signal wr_done : std_logic := '0';
	signal rd_done : std_logic := '0';
	
	signal MemDB : std_logic_vector(7 downto 0) := (others => '0');
	signal MemAdr : unsigned(18 downto 0) := (others => '0');
	signal RamOEn : std_logic := '0';
	signal RamWEn : std_logic := '0';
	signal RamCEn : std_logic := '0';
	
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
	
	signal cqt_done : std_logic := '0';
	
	
	signal cqt_read_data : signed(63 downto 0) := (others => '0');
	
	signal binzeros : unsigned(binorder-1 downto 0) := (others => '0');

	signal mag_q_scaled : signed(31 downto 0) := (others => '0');
	signal mag_i_scaled : signed(31 downto 0) := (others => '0');
	
begin
	
	--rom for test data, sim only
	process(clk)
    begin
        if(clk'event and clk = '1') then
			if(rom_en = '1') then
				qdata_rd <= to_signed(inputdata(to_integer(addr_rd)), 32);
				--idata_rd <= imagrom(to_integer(addr_rd));
				idata_rd <= (others => '0');
			end if;
        end if;
    end process;


	
    FFT : entity work.fft 
		generic map(
		order => order,
		coslutfile => "../fft/twids/cos4096.data",
		sinlutfile => "../fft/twids/cos4096.data"
		)
		port map(
	    clk => clk,
	    
		fft_start => en,
		fft_done => fft_done,
		fft_pulse => open,
		fft_load => fft_load,
		fft_busy => fft_busy,
		
		in_qdata => qdata_rd,
		in_idata => x"00000000",
		in_addr => addr_rd,
		in_en   => rom_en,
		
		out_qdata => qdata_wr,
		out_idata => idata_wr,
		out_addr => read_addr,
		out_en => read_en,
		out_wr => '0',
		
		ram0_ena   => ram0_ena,
		ram0_wra  => ram0_wra,
		ram0_addra => ram0_addra,
		ram0_dia  => ram0_dia,
		ram0_doa  => ram0_doa,
		
		ram0_enb  => ram0_enb,
		ram0_wrb  => ram0_wrb,
		ram0_addrb => ram0_addrb,
		ram0_dib   => ram0_dib,
		ram0_dob   => ram0_dob,	
		
		ram1_ena   => ram1_ena,
		ram1_wra  => ram1_wra,
		ram1_addra => ram1_addra,
		ram1_dia  => ram1_dia,
		ram1_doa  => ram1_doa,
		
		ram1_enb  => ram1_enb,
		ram1_wrb  => ram1_wrb,
		ram1_addrb => ram1_addrb,
		ram1_dib   => ram1_dib,
		ram1_dob   => ram1_dob	
    );
    
	KERNEL : entity work.kernel_manager
	generic map(
		order => order,
		kernel_elements => 6523,
		kernel0 => "./kernel/speckernel0.data",
		kernel1 => "./kernel/speckernel1.data"
	)
	port map(
	    clk => clk,
		rst => rst,
		
		fft_busy => fft_busy,
		cqt_busy => fft_load,
		
		kernel_load => kernel_load,
		kernel_ready => kernel_ready,
		
	
		--for FFT
		fft_ram0_ena   => ram0_ena,
		fft_ram0_wra  => ram0_wra,
		fft_ram0_addra => ram0_addra,
		fft_ram0_dia  => ram0_dia,
		fft_ram0_doa  => ram0_doa,
		
		fft_ram0_enb  => ram0_enb,
		fft_ram0_wrb  => ram0_wrb,
		fft_ram0_addrb => ram0_addrb,
		fft_ram0_dib   => ram0_dib,
		fft_ram0_dob   => ram0_dob,	
		
		fft_ram1_ena   => ram1_ena,
		fft_ram1_wra  => ram1_wra,
		fft_ram1_addra => ram1_addra,
		fft_ram1_dia  => ram1_dia,
		fft_ram1_doa  => ram1_doa,
		
		fft_ram1_enb  => ram1_enb,
		fft_ram1_wrb  => ram1_wrb,
		fft_ram1_addrb => ram1_addrb,
		fft_ram1_dib   => ram1_dib,
		fft_ram1_dob   => ram1_dob,	
		
		--for CQT kernel
		cqt_ram_en => cqt_en,
		cqt_ram_addr => cqt_addr,
		cqt_ram_do   => cqt_data,

		--for external SRAM		
		ext_in_data_reg => in_data_reg,
		ext_out_data_reg => out_data_reg,
		ext_in_addr => in_addr,
		ext_in_wr => in_wr, 
		ext_in_rd => in_rd, 
		ext_wr_done => wr_done,
		ext_rd_done => rd_done
	
	
	);

	EXT_SRAM : entity work.sram_ctrl
	port map(
		
		clk => clk, --max of 100 MHz? minimum 8 ns read/write times
		rst => rst,
		
		in_data_reg => in_data_reg,
		out_data_reg => out_data_reg,
		in_addr => in_addr,
		in_wr => in_wr, 
		in_rd => in_rd, 
		wr_done => wr_done,
		rd_done => rd_done,
		
		MemDB => MemDB,
		MemAdr => MemAdr,
		RamOEn => RamOEn,
		RamWEn => RamWEn,
		RamCEn => RamCEn
	
	);

	EXT_SRAM_model : entity work.sram_model
	port map(
		
		MemDB => MemDB,
		MemAdr => MemAdr,
		RamOEn => RamOEn,
		RamWEn =>  RamWEn,
		RamCEn =>  RamCEn
	
	);


	cqt_input(63 downto 32) <= qdata_wr;
	cqt_input(31 downto 0) <= idata_wr;

	CQT: entity work.cqt
	generic map(
		order => order,
		kernel_elements => 6523,
		numbinslog2 => binorder,
		numbins => 80
	)
	port map(
		clk => clk,
		cqt_start => fft_done,
		cqt_busy => fft_load,
		cqt_done => cqt_done,
		kernel_load => kernel_load,
		kernel_ready => kernel_ready,
		fft_en => read_en,
		fft_addr => read_addr,
		fft_data => cqt_input,
		kernel_en => cqt_en,
		kernel_addr => cqt_addr,
		kernel_data => cqt_data,
		cqt_en => cqt_read_en,
		cqt_addr => cqt_read_addr,
		cqt_data => cqt_read_data
	);
	
	--divide by input length
	process(cqt_read_data)
	begin
		--9 is 2**9 for divide by 512
		for i in 1 to 9 loop
			mag_q_scaled(32 - i) <= cqt_read_data(63);
			mag_i_scaled(32 - i) <= cqt_read_data(31);
		end loop;
		
		mag_q_scaled(31 - 9 downto 0) <= cqt_read_data(63 downto 32+9);
		mag_i_scaled(31 - 9 downto 0) <= cqt_read_data(31 downto 0+9);
	end process;
	
	--mag_q_scaled <= cqt_read_data(63 downto 32);
	--mag_i_scaled <= cqt_read_data(31 downto 0);
	
	MAG : entity work.fft_mag
	generic map(
		order => binorder
	)
	port map(
		clk => clk,
		fft_done => cqt_done,
		mag_done => mag_done,
		mag_load => open,
		max_bin => open,
		max_freq => open,
		in_qdata => mag_q_scaled, --scaling by input length
		in_idata => mag_i_scaled, --scaling by input length
		in_addr => cqt_read_addr,
		in_en => cqt_read_en,
		in_wr => open,
		out_data => open,
		out_addr => binzeros,
		out_en => '0'
		
	);
	
	
    process
    begin
    
    clk <= '0';
	
	rst <= '0';
	wait for 5 ns;
	rst <= '1';
	wait for 5 ns;
	
	for i in 0 to 20 loop
		clk <= '1';
		wait for 1 ns;
		clk <= '0';
		wait for 1 ns;
	end loop;
	
	rst <= '0';
	
	--give time for kernels to load
	for i in 0 to 200000 loop
	
		clk <= '1';
		wait for 1 ns;
		clk <= '0';
		wait for 1 ns;
	
	end loop;
	
	
	for i in 0 to 1 loop
	
    en <= '0';
    wait for 1 ns;
    en <= '1'; 
    clk <= '1';
	wait for 1 ns;
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
	en <= '0';
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
	clk <= '0';
	wait for 1 ns;
	
	
	-- clk <= not clk;
	-- wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
	

	--read from cqt
	for i in 0 to 800000 loop
		

		
		clk <= not clk;
		wait for 1 ns;
		clk <= not clk;
		wait for 1 ns;
		
		if(mag_done = '1') then
			exit;
		end if;
			
	end loop;
	
	--dummy clocks
	
	for i in 0 to 200 loop
	clk <= not clk;
	wait for 1 ns;
	clk <= not clk;
	wait for 1 ns;
	end loop;
	

	
	end loop;
	
	
    wait;
    
    end process;
    
end test;