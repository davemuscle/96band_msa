-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity dual_cqt is
	port(
	    clk : in std_logic;

		full_i : in std_logic;
		full_o : out std_logic;
		
		en_o : out std_logic;
		addr_o : out unsigned(7 downto 0);
		data_i : in signed(31 downto 0);
		
		en_i : in std_logic;
		addr_i : in unsigned(6 downto 0);
		data_o : out signed(63 downto 0)


        );
end dual_cqt;

architecture str of dual_cqt is 

	type state_type is ( reset,
						 write_upper,
						 write_lower,
						 wait_upper,
						 wait_lower
						);
						
	signal state : state_type := reset;

	signal dwnstream_sel : std_logic := '0';
	signal upstream_sel :  std_logic := '0';
	
	signal high_cqt_ov_start : std_logic := '0';
	signal high_cqt_ov_start_dly : std_logic := '0';
	
	signal low_cqt_ov_full : std_logic := '0';
	signal high_cqt_ov_full : std_logic := '0';
	
	signal mono_full_dly : std_logic := '0';
	
	signal low_cqt_dwn_en : std_logic := '0';
	signal low_cqt_dwn_addr : unsigned(8 - 1 downto 0) := (others => '0');
	
	signal high_cqt_ov_en : std_logic := '0';
	signal high_cqt_ov_addr : unsigned(8 - 1 downto 0) := (others => '0');
	
	signal low_cqt_ov_data : signed(31 downto 0) := (others => '0');
	signal high_cqt_ov_data : signed(31 downto 0) := (others => '0');
	
	signal high_cqt_ov_full_reg : std_logic := '0';
	signal high_cqt_ov_full_pulse : std_logic := '0';
	
	
	signal cqt_done : std_logic := '0';
	signal cqt_done_reg : std_logic := '0';
	signal high_cqt_ov_full_pulse_dly : std_logic := '0';

	signal mag_start : std_logic := '0';
	
	signal low_ov_read_done : std_logic := '0';
	signal high_ov_read_done : std_logic := '0';
	
	signal bin_en : std_logic := '0';
	signal bin_addr : unsigned(7 - 1 downto 0) := (others => '0');
	signal bin_data : signed(63 downto 0) := (others => '0');
	
	signal downsample_full : std_logic := '0';
	signal dwn_en : std_logic := '0';
	signal dwn_addr : unsigned(4 - 1 downto 0) := (others => '0');
	signal dwn_data : signed(31 downto 0) := (others => '0');
	
	signal fft_start : std_logic := '0';
	signal fft_read_en : std_logic := '0';
	signal fft_read_addr : unsigned(10 - 1 downto 0) := (others => '0');
	signal fft_read_data : signed(31 downto 0) := (others => '0');

	signal low_cqt_ov_read_en : std_logic := '0';
	signal low_cqt_ov_read_addr : unsigned(10 - 1 downto 0) := (others => '0');
	
	signal high_cqt_ov_read_en : std_logic := '0';
	signal high_cqt_ov_read_addr : unsigned(10 - 1 downto 0) := (others => '0');
	
	
	signal cqt_read_en : std_logic := '0';
	signal cqt_read_addr : unsigned(6 - 1 downto 0) := (others => '0');
	signal cqt_read_data : signed(63 downto 0) := (others => '0');

begin

	--mux mono addr and enable signal 
	addr_o <= low_cqt_dwn_addr when upstream_sel = '0' else high_cqt_ov_addr;
	en_o   <= low_cqt_dwn_en   when upstream_sel = '0' else high_cqt_ov_en;
	
	

	--when the downsampler is done, switch upstream_sel and let high_overlapper run
	--also switch dwnstream_sel for the fft reader
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(low_ov_read_done = '1') then
				upstream_sel <= '1';
				high_cqt_ov_start <= '1';
			else
				high_cqt_ov_start <= '0';
			end if;
			
			if(full_i = '1') then
				upstream_sel <= '0';
			end if;
			
			high_cqt_ov_start_dly <= high_cqt_ov_start;
			
			mono_full_dly <= full_i;
			
			
		end if;
	end process;

	low_cqt_downsampler : entity work.downsampler
	generic map(
		SIM => 0,
		inputorder => 8,
		outputorder => 4,
		downsample_factor => 16,
		firfile => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/cqt/fir/downsampler_fir_256_3KHZ.data",
		firlenpow2 => 8,
		firlen => 256
	)
	port map(
		clk => clk,
		rst => '0',
		full_i => mono_full_dly,
		full_o => downsample_full,
		
		en_o => low_cqt_dwn_en,
		addr_o => low_cqt_dwn_addr,
		data_i => data_i,
		
		en_i => dwn_en,
		addr_i => dwn_addr,
		data_o => dwn_data
		
	);

	low_cqt_overlapper : entity work.i2s_overlapper
	generic map(
		recordNumBuffs => 3,
		monobuffersizelog2 => 4,
		totalbuffersizelog2 => 10
	)
	port map(
		clk_i => clk,
		full_i => downsample_full,
		full_o => low_cqt_ov_full,
		read_done => low_ov_read_done,
		en_o => dwn_en,
		addr_o => dwn_addr,
		mono_data_i => dwn_data,
		en_i => low_cqt_ov_read_en,
		addr_i => low_cqt_ov_read_addr,
		mono_data_o => low_cqt_ov_data
	);

	high_cqt_overlapper : entity work.i2s_overlapper
	generic map(
		recordNumBuffs => 3,
		monobuffersizelog2 => 8,
		totalbuffersizelog2 => 10
	)
	port map(
		clk_i => clk,
		full_i => high_cqt_ov_start_dly,
		full_o => high_cqt_ov_full,
		read_done => high_ov_read_done,
		en_o => high_cqt_ov_en,
		addr_o => high_cqt_ov_addr,
		mono_data_i => data_i,
		en_i => high_cqt_ov_read_en,
		addr_i => high_cqt_ov_read_addr,
		mono_data_o => high_cqt_ov_data
	);
	
	process(clk)
	begin
		if(clk'event and clk = '1') then
			--register high_cqt_ov_full
			if(high_cqt_ov_full = '1') then
				high_cqt_ov_full_reg <= '1';
			end if;
			
			if(cqt_done_reg = '1' and high_cqt_ov_full_reg = '1') then
				high_cqt_ov_full_pulse <= '1';
				high_cqt_ov_full_reg <= '0';
				cqt_done_reg <= '0';
			else
				high_cqt_ov_full_pulse <= '0';
			end if;
			
			--if the lower cqt is done
			if(cqt_done = '1' and dwnstream_sel = '0') then
				cqt_done_reg <= '1';
			end if;
			
			--delay
			high_cqt_ov_full_pulse_dly <= high_cqt_ov_full_pulse;
			
		end if;
	end process;
	
	
	--mux data going into fft
	fft_start <= low_cqt_ov_full when dwnstream_sel = '0' else high_cqt_ov_full_pulse_dly;
	fft_read_data <=  low_cqt_ov_data when dwnstream_sel = '0' else high_cqt_ov_data;
	
	--mux address too because I coded overlapper poorly
	low_cqt_ov_read_addr <= fft_read_addr when dwnstream_sel = '0' else (others => '0');
	low_cqt_ov_read_en   <= fft_read_en   when dwnstream_sel = '0' else '0';
	
	high_cqt_ov_read_addr <= fft_read_addr when dwnstream_sel = '1' else (others => '0');
	high_cqt_ov_read_en <= fft_read_en when dwnstream_sel = '1' else '0';
	
	--fft_start <= low_cqt_ov_full;
	
	--mux enable signal
	--low_cqt_ov_read_en <= fft_read_en when dwnstream_sel = '0' else '0';
	--high_cqt_ov_read_en <= fft_read_en when dwnstream_sel = '1' else '0';
	
	--low_cqt_ov_read_en <= fft_read_en;
	
	
	CQT_WRAPPER : entity work.cqt_wrapper
	generic map(
		order => 10,
		binorder => 6,
		numbins => 48,
		coslutfile => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/fft/twids/cos1024.data",
		kernel_order => 11,
		kernel => "C:/Users/Dave/Desktop/FPGA/Projects/Bababooey/cqt/kernel.data",
		kernel_elements => 1927
		
	)
	port map(
		fft_clk => clk,
		rst => '0',
		
		fft_start => fft_start,
		fft_read_en => fft_read_en,
		fft_read_addr => fft_read_addr,
		fft_read_data => fft_read_data,
		
		cqt_done => cqt_done,
		cqt_read_en => cqt_read_en,
		cqt_read_addr => cqt_read_addr,
		cqt_read_data => cqt_read_data

	);
	

	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(cqt_done = '1') then
				dwnstream_sel <= not dwnstream_sel;
			end if;
		end if;
	end process;
	
	--dwnstream_sel <= '1';
	
	-- --read CQT bins into ram
	dual_bin_inst : entity work.dual_bins
	generic map(
		inputorder => 6,
		inputnumbins => 48,
		outputorder => 7,
		outputnumbins => 96
	)
	port map(
		clk => clk,
		start => cqt_done,
		done => full_o,
		cqt_en => cqt_read_en,
		cqt_addr => cqt_read_addr,
		cqt_data => cqt_read_data,
		
		read_en => en_i,
		read_addr => addr_i,
		read_data => data_o
	
	);

end str;
