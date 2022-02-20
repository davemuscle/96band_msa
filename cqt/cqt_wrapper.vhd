-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--In place kernel, in ROM

entity cqt_wrapper is
	generic(
		order : integer;
		binorder : integer;
		numbins : integer;
		coslutfile : string;
		kernel_order : integer;
		kernel : string;
		kernel_elements : integer
		
	);
	port(
		fft_clk : in std_logic;
		
		fft_start : in std_logic;
		fft_read_en : out std_logic;
		fft_read_addr : out unsigned(order-1 downto 0);
		fft_read_data : in signed(31 downto 0);
		
		fft_overflow : out std_logic;
		cqt_overflow : out std_logic;
		
		cqt_done : out std_logic;
		cqt_read_en : in std_logic;
		cqt_read_addr : in unsigned(binorder - 1 downto 0);
		cqt_read_data : out signed(63 downto 0)

        );
end cqt_wrapper;

architecture str of cqt_wrapper is 
	
	signal fft_done : std_logic := '0';

	signal cqt_input : signed(63 downto 0) := (others => '0');
	
	signal fft_load : std_logic := '0';
	signal fft_busy : std_logic := '0';
	
	signal read_start : std_logic := '0';
	signal read_en : std_logic := '0';
	signal read_addr : unsigned(order -1 downto 0) := (others => '0');
	
	signal cqt_en : std_logic := '0';
	signal cqt_addr : unsigned(kernel_order-1 downto 0) := (others => '0');
	signal cqt_data : signed(63 downto 0) := (others => '0');
	
	signal out_en : std_logic := '0';
	signal qdata_wr : signed(31 downto 0) := (others => '0');
	signal idata_wr : signed(31 downto 0) := (others => '0');
	
	
	signal zeros : unsigned(kernel_order-1 downto 0) := (others => '0');
	

begin
 

	
    FFT : entity work.fft 
		generic map(
		order => order,
		coslutfile => coslutfile,
		scale_on_stage => "NONE",
		ram_loc => "INT"
		)
		port map(
		clk => fft_clk,
	    
		start => fft_start,
		done => fft_done,
		loading => open,
		busy => fft_busy,
		
		overflow => fft_overflow,
		
		in_qdata => fft_read_data,
		in_idata => x"00000000",
		in_addr => fft_read_addr,
		in_en   => fft_read_en,
		
		out_qdata => qdata_wr,
		out_idata => idata_wr,
		out_addr => read_addr,
		out_en => read_en,
		
		ext_ram_wra   => open,
		ext_ram_ena   => open,
		ext_ram_dia   => open,
		ext_ram_doa   => (others => '0'),
		ext_ram_addra => open,
		
		ext_ram_wrb   => open,
		ext_ram_enb   => open,
		ext_ram_dib   => open,
		ext_ram_dob   => (others => '0'),
		ext_ram_addrb => open
    );
	

	--scale by fft length
	-- process(qdata_wr, idata_wr)
	-- begin
		-- cqt_input(63 - order downto 32 ) <= qdata_wr(31 downto order);
		-- cqt_input(63 downto 63 - order + 1 ) <= (others => qdata_wr(31));
		
		-- cqt_input(31 - order downto 0) <= idata_wr(31 downto order);
		-- cqt_input(31 downto 31 - order + 1 ) <= (others => idata_wr(31));
	-- end process;
	
	cqt_input(63 downto 32) <= qdata_wr;
	cqt_input(31 downto 0) <= idata_wr;

	CQT: entity work.cqt
	generic map(
		SIM => 0,
		order => order,
		kernel_order => kernel_order,
		kernel_elements => kernel_elements,
		numbinslog2 => binorder,
		numbins => numbins
	)
	port map(
		clk => fft_clk,
		cqt_start => fft_done,
		cqt_busy => open,
		cqt_done => cqt_done,
		
		kernel_load => open,
		kernel_ready => '1',
		
		overflow => cqt_overflow,
		
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

	CQT_KERNEL : entity work.kernel_bram
	generic map(
		order => kernel_order,
		initfile => kernel
	)
	port map(
		clka => fft_clk,
		wea  => '0',
		ena  => cqt_en,
		dia => x"0000000000000000",
		doa => cqt_data,
		addra => cqt_addr,

        clkb => '0',
		web  => '0',
		enb  => '0',
		dib => x"0000000000000000",
		dob => open,
		addrb => zeros
	);
	

end str;