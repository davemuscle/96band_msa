library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

--Reads block data and averages it with existing block ram
--Specifically made for FFT/CQT bins


entity bin_accumulator is
	generic(
		order : integer := 7
	);
	port(
		
		fft_clk : in std_logic;
		p_clk   : in std_logic;
		
		full_i : in std_logic;
		full_o : out std_logic;
		
		valid : out std_logic; --latched version of full_o
		
		en_o : out std_logic;
		addr_o    : out unsigned(order-1 downto 0);
		data_i : in unsigned(31 downto 0);
		

		en_i : in std_logic;
		addr_i : in unsigned(order - 1 downto 0);
		data_o : out unsigned(31 downto 0)
		
	);
end bin_accumulator;

architecture bhv of bin_accumulator is 
    
	--ram signals-------------------------------------------------------------
	signal ram_ena   : std_logic := '0';
	signal ram_wra   : std_logic := '0';
	signal ram_addra : unsigned(order - 1 downto 0) := (others => '0');
	signal ram_dia   : signed(31 downto 0) := (others => '0');
	signal ram_doa   : signed(31 downto 0) := (others => '0');
	
	signal ram_enb   : std_logic := '0';
	signal ram_addrb : unsigned(order - 1 downto 0) := (others => '0');
	signal ram_dob   : signed(31 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	--math signals---------------------------------------------------------------------
	signal sum : unsigned(31 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------
	
	
	--control signals------------------------------------------------------------------
	constant pipe_length : integer range 0 to 15 := 8;
	signal   pipe   : std_logic_vector(pipe_length - 1 downto 0) := (others => '0');
	-----------------------------------------------------------------------------------

	signal write_en : std_logic := '0';
	
begin


	process(fft_clk)
	begin
		if(fft_clk'event and fft_clk = '1') then
			
			full_o <= '0';
			
			pipe(pipe_length-1 downto 1) <= pipe(pipe_length-2 downto 0);

			sum <= ('0' & unsigned(ram_doa(31 downto 1))) + 
				   ('0' & data_i(31 downto 1));

			if(full_i = '1') then
				pipe(0) <= '1';
				ram_ena <= '1';
				en_o <= '1';
				valid <= '0';
				--reset addresses
				ram_addra <= (others => '0');
			end if;
			
			--clock one setup read from both rams
			
			--clock two calculate average, setup write
			if(pipe(1) = '1') then
				ram_wra <= '1';
			end if;
			
			--clock three increment address, check if finished
			if(pipe(2) = '1') then
				
				pipe <= (others => '0');
				
				ram_wra <= '0';
				
				ram_addra <= ram_addra + 1;
				if(ram_addra = to_unsigned(2**order - 1, order)) then
					pipe(0) <= '0';
					full_o <= '1';
					valid <= '1';
					
					en_o <= '0';
					ram_ena <= '0';
					
				else
					pipe(0) <= '1';

				end if;
				
			end if;
		
		end if;
	end process;
	
	addr_o <= ram_addra;
	ram_dia <= signed(sum);
   
    data_o <= unsigned(ram_dob);
	ram_addrb <= addr_i;
	ram_enb <= en_i;
   
   
	--ram for averaging bin data
	bin_ram : entity work.fft_bram
	generic map(
		order => order
	)
	port map(
		clka => fft_clk,
		wea => ram_wra,
		ena => ram_ena,
		dia => ram_dia,
		doa => ram_doa,
		addra => ram_addra,

		clkb => p_clk,
		web => '0',
		enb => ram_enb,
		dib => (others => '0'),
		dob => ram_dob,
		addrb => ram_addrb
	);
   
   
end bhv;